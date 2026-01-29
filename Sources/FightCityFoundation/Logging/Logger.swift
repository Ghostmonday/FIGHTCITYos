//
//  Logger.swift
//  FightCityFoundation
//
//  Production-ready logging with levels and OS integration
//

import Foundation
import os.log

/// Log levels for filtering and configuration
public enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}

/// Logger protocol for testability
public protocol LoggerProtocol {
    func debug(_ message: String, file: String, function: String, line: Int)
    func info(_ message: String, file: String, function: String, line: Int)
    func warning(_ message: String, file: String, function: String, line: Int)
    func error(_ message: String, file: String, function: String, line: Int)
    func error(_ error: Error, file: String, function: String, line: Int)
}

/// Production logger using OSLog
public final class Logger: LoggerProtocol {
    public static let shared = Logger()
    
    private let subsystem: String
    private let logger: os.Logger
    
    public init(subsystem: String = "com.fightcitytickets.app") {
        self.subsystem = subsystem
        self.logger = os.Logger(subsystem: subsystem, category: "App")
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    public func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: error.localizedDescription, file: file, function: function, line: line)
    }
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        let formattedMessage = "[\(level.rawValue)] \(filename):\(line) \(function) - \(message)"
        print(formattedMessage)
        #endif
        
        logger.log(level: level.osLogType, "\(message, privacy: .public)")
    }
}

/// Mock logger for testing
public final class MockLogger: LoggerProtocol {
    public var logs: [(level: LogLevel, message: String, file: String, function: String, line: Int)] = []
    
    public init() {}
    
    public func debug(_ message: String, file: String, function: String, line: Int) {
        logs.append((.debug, message, file, function, line))
    }
    
    public func info(_ message: String, file: String, function: String, line: Int) {
        logs.append((.info, message, file, function, line))
    }
    
    public func warning(_ message: String, file: String, function: String, line: Int) {
        logs.append((.warning, message, file, function, line))
    }
    
    public func error(_ message: String, file: String, function: String, line: Int) {
        logs.append((.error, message, file, function, line))
    }
    
    public func error(_ error: Error, file: String, function: String, line: Int) {
        logs.append((.error, error.localizedDescription, file, function, line))
    }
    
    public func clear() {
        logs.removeAll()
    }
}
