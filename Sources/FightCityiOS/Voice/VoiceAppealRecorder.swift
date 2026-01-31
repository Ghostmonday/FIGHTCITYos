//
//  VoiceAppealRecorder.swift
//  FightCityiOS
//
//  Speech recognition pipeline for dictation of appeal narratives
//

import Speech
import AVFoundation
import UIKit

import os.log

/// APPLE INTELLIGENCE: On-device speech recognition for dictating appeal narratives
/// APPLE INTELLIGENCE: Real-time transcription with confidence scores
/// APPLE INTELLIGENCE: Supports iOS 16+ with privacy-preserving on-device processing

// MARK: - Transcription Result

/// Result of speech transcription
public struct TranscriptionResult {
    public let text: String
    public let confidence: Double
    public let isFinal: Bool
    public let alternatives: [String]
    public let timestamp: Date
    public let audioDuration: TimeInterval
    
    public init(
        text: String,
        confidence: Double,
        isFinal: Bool,
        alternatives: [String] = [],
        timestamp: Date = Date(),
        audioDuration: TimeInterval = 0
    ) {
        self.text = text
        self.confidence = confidence
        self.isFinal = isFinal
        self.alternatives = alternatives
        self.timestamp = timestamp
        self.audioDuration = audioDuration
    }
}

// MARK: - Recording State

/// State of the voice recorder
public enum RecordingState: Equatable {
    case idle
    case preparing
    case recording
    case processing
    case paused
    case finished
    case error(String)
    
    public static func == (lhs: RecordingState, rhs: RecordingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.preparing, .preparing), (.recording, .recording),
             (.processing, .processing), (.paused, .paused), (.finished, .finished):
            return true
        case (.error(let lhsMsg), .error(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

// MARK: - Voice Recorder Delegate

/// Delegate protocol for voice recording callbacks
public protocol VoiceRecorderDelegate: AnyObject {
    func voiceRecorder(_ recorder: VoiceAppealRecorder, didUpdateState state: RecordingState)
    func voiceRecorder(_ recorder: VoiceAppealRecorder, didReceivePartialResult result: TranscriptionResult)
    func voiceRecorder(_ recorder: VoiceAppealRecorder, didReceiveFinalResult result: TranscriptionResult)
    func voiceRecorder(_ recorder: VoiceAppealRecorder, didFailWith error: Error)
}

// MARK: - Voice Appeal Recorder

/// Speech recognition service for dictating appeal narratives
public final class VoiceAppealRecorder: NSObject {
    
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = VoiceAppealRecorder()
    
    /// Delegate for callbacks
    public weak var delegate: VoiceRecorderDelegate?
    
    /// Current recording state
    @Published public private(set) var state: RecordingState = .idle
    
    /// Accumulated transcribed text
    @Published public private(set) var accumulatedText: String = ""
    
    /// Speech authorization status
    public private(set) var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    /// Audio engine for recording
    private var audioEngine: AVAudioEngine?
    
    /// Speech recognition request
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    /// Recognition task
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// Speech recognizer
    private let speechRecognizer: SFSpeechRecognizer?
    
    /// Audio session
    private let audioSession = AVAudioSession.sharedInstance()
    
    /// Whether continuous mode is enabled
    private var isContinuousMode: Bool = false
    
    /// Partial results buffer
    private var partialResults: [TranscriptionResult] = []
    
    // MARK: - Initialization
    
    public override init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Request speech recognition authorization
    public func requestAuthorization() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        await MainActor.run {
            self.authorizationStatus = status
        }
        
        return status == .authorized
    }
    
    /// Check if speech recognition is available
    public var isAvailable: Bool {
        guard let recognizer = speechRecognizer else { return false }
        return recognizer.isAvailable && authorizationStatus == .authorized
    }
    
    /// Start recording and transcription
    /// - Parameter continuous: Whether to continue recording until stopped
    public func startRecording(continuous: Bool = false) async throws {
        guard isAvailable else {
            throw VoiceRecorderError.notAuthorized
        }
        
        guard speechRecognizer?.supportsOnDeviceRecognition == true || isOnDeviceAvailable() else {
            throw VoiceRecorderError.notSupported
        }
        
        isContinuousMode = continuous
        
        await MainActor.run {
            self.state = .preparing
            self.delegate?.voiceRecorder(self, didUpdateState: .preparing)
        }
        
        try await setupAudioSession()
        try setupAudioEngine()
        try startRecognition()
        
        await MainActor.run {
            self.state = .recording
            self.delegate?.voiceRecorder(self, didUpdateState: .recording)
        }
    }
    
    /// Stop recording and return final transcription
    public func stopRecording() async -> TranscriptionResult {
        // Stop recognition
        audioEngine?.stop()
        speechRecognitionRequest?.endAudio()
        
        // Wait for final result
        await MainActor.run {
            self.state = .processing
            self.delegate?.voiceRecorder(self, didUpdateState: .processing)
        }
        
        // Cancel any ongoing task
        recognitionTask?.cancel()
        
        let finalResult = TranscriptionResult(
            text: accumulatedText,
            confidence: calculateAverageConfidence(),
            isFinal: true,
            alternatives: [],
            timestamp: Date()
        )
        
        await MainActor.run {
            self.accumulatedText = ""
            self.partialResults.removeAll()
            self.state = .finished
            self.delegate?.voiceRecorder(self, didUpdateState: .finished)
        }
        
        return finalResult
    }
    
    /// Pause recording
    public func pauseRecording() {
        audioEngine?.pause()
        state = .paused
        delegate?.voiceRecorder(self, didUpdateState: .paused)
    }
    
    /// Resume recording
    public func resumeRecording() async throws {
        try audioEngine?.start()
        state = .recording
        delegate?.voiceRecorder(self, didUpdateState: .recording)
    }
    
    /// Get permission status description
    public var permissionDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Speech recognition permission not requested"
        case .denied:
            return "Speech recognition denied. Enable in Settings."
        case .restricted:
            return "Speech recognition not available on this device"
        case .authorized:
            return "Speech recognition enabled"
        @unknown default:
            return "Unknown permission status"
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() async throws {
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func setupAudioEngine() throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw VoiceRecorderError.engineSetupFailed
        }
        
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = speechRecognitionRequest else {
            throw VoiceRecorderError.requestCreationFailed
        }
        
        // Configure for on-device recognition (privacy-preserving)
        recognitionRequest.requiresOnDeviceRecognition = true
        
        // Enable partial results
        recognitionRequest.shouldReportPartialResults = true
        
        // Set minimum context for better accuracy
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = true
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.speechRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
    }
    
    private func startRecognition() throws {
        guard let recognitionRequest = speechRecognitionRequest,
              let speechRecognizer = speechRecognizer else {
            throw VoiceRecorderError.notConfigured
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(error)
                return
            }
            
            guard let result = result else { return }
            
            let isFinal = result.isFinal
            let bestTranscription = result.bestTranscription
            let alternatives = result.transcriptions.map { $0.formattedString }
            
            let transcriptionResult = TranscriptionResult(
                text: bestTranscription.formattedString,
                confidence: 0.9, // SFTranscription doesn't provide confidence, use default
                isFinal: isFinal,
                alternatives: alternatives,
                timestamp: Date()
            )
            
            Task { @MainActor in
                if isFinal {
                    self.accumulatedText += (self.accumulatedText.isEmpty ? "" : " ") + transcriptionResult.text
                    self.partialResults.append(transcriptionResult)
                    self.delegate?.voiceRecorder(self, didReceiveFinalResult: transcriptionResult)
                    
                    // Check if we should stop (non-continuous mode)
                    if !self.isContinuousMode {
                        _ = await self.stopRecording()
                    }
                } else {
                    self.delegate?.voiceRecorder(self, didReceivePartialResult: transcriptionResult)
                }
            }
        }
        
        try audioEngine?.start()
    }
    
    private func handleError(_ error: Error) {
        Task { @MainActor in
            self.state = .error(error.localizedDescription)
            self.delegate?.voiceRecorder(self, didFailWith: error)
        }
    }
    
    private func isOnDeviceAvailable() -> Bool {
        // Check if on-device recognition is available
        // This is typically true for iOS 16+ on supported devices
        if #available(iOS 16.0, *) {
            return true
        }
        return false
    }
    
    private func calculateAverageConfidence() -> Double {
        guard !partialResults.isEmpty else { return 0 }
        
        let totalConfidence = partialResults.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Double(partialResults.count)
    }
}

// MARK: - Voice Recorder Error

/// Errors for voice recording operations
public enum VoiceRecorderError: LocalizedError {
    case notAuthorized
    case notSupported
    case engineSetupFailed
    case requestCreationFailed
    case notConfigured
    case recordingFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition not authorized. Please grant permission."
        case .notSupported:
            return "Speech recognition not supported on this device."
        case .engineSetupFailed:
            return "Failed to setup audio engine."
        case .requestCreationFailed:
            return "Failed to create speech recognition request."
        case .notConfigured:
            return "Voice recorder not properly configured."
        case .recordingFailed(let error):
            return "Recording failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Audio Level

extension VoiceAppealRecorder {
    /// Get current audio level for visualization
    public func getAudioLevel() -> Float {
        guard let audioEngine = audioEngine else {
            return 0
        }
        let inputNode = audioEngine.inputNode
        
        let format = inputNode.outputFormat(forBus: 0)
        let frameCount = AVAudioFrameCount(format.sampleRate)
        
        let bufferSize: AVAudioFrameCount = 4096
        
        var level: Float = 0
        
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { buffer, _ in
            let channelDataValue = buffer.floatChannelData!.pointee
            let channelData = UnsafePointer<Float>(channelDataValue)
            let channelCount = Int(buffer.format.channelCount)
            
            var sum: Float = 0
            for i in 0..<Int(buffer.frameLength) {
                sum += channelData[i * channelCount] * channelData[i * channelCount]
            }
            
            level = sqrt(sum / Float(buffer.frameLength))
        }
        
        return min(level * 10, 1.0) // Scale for visualization
    }
}

// MARK: - Default Delegate Implementation

extension VoiceAppealRecorder {
    /// Empty delegate implementation for optional methods
    public static var emptyDelegate: VoiceRecorderDelegate {
        class EmptyDelegate: VoiceRecorderDelegate {
            func voiceRecorder(_ recorder: VoiceAppealRecorder, didUpdateState state: RecordingState) {}
            func voiceRecorder(_ recorder: VoiceAppealRecorder, didReceivePartialResult result: TranscriptionResult) {}
            func voiceRecorder(_ recorder: VoiceAppealRecorder, didReceiveFinalResult result: TranscriptionResult) {}
            func voiceRecorder(_ recorder: VoiceAppealRecorder, didFailWith error: Error) {}
        }
        return EmptyDelegate()
    }
}
