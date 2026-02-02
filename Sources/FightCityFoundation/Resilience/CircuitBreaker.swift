//
//  CircuitBreaker.swift
//  FightCityFoundation
//
//  Circuit breaker pattern for resilient API calls
//

import Foundation

/// Circuit breaker for resilient API calls with automatic recovery
///
/// APP STORE READINESS: Circuit breaker prevents cascade failures
/// ERROR HANDLING: Protects app from repeatedly hitting failing services
/// TODO APP STORE: Monitor circuit breaker trips to detect backend issues
/// TODO ENHANCEMENT: Add telemetry/logging for circuit state changes
/// RELIABILITY: Improves app resilience under adverse network conditions
/// PERFORMANCE: Prevents wasted requests to known-failing services
/// USER EXPERIENCE: Faster fallback when services are down
/// NOTE: This is production-grade reliability pattern used by major apps
public actor CircuitBreaker {
    public enum State {
        case closed    // Normal operation
        case open      // Failures exceed threshold, use fallback
        case halfOpen  // Testing if service recovered
    }
    
    private var state: State = .closed
    private var failureCount = 0
    private var lastFailureTime: Date?
    private var successCount = 0
    
    private let failureThreshold: Int
    private let successThreshold: Int
    private let timeout: TimeInterval
    
    public init(
        failureThreshold: Int = 5,
        successThreshold: Int = 2,
        timeout: TimeInterval = 60.0
    ) {
        self.failureThreshold = failureThreshold
        self.successThreshold = successThreshold
        self.timeout = timeout
    }
    
    /// Records a successful API call
    public func recordSuccess() {
        switch state {
        case .halfOpen:
            successCount += 1
            if successCount >= successThreshold {
                state = .closed
                failureCount = 0
                successCount = 0
            }
        case .closed:
            failureCount = 0
        case .open:
            break
        }
    }
    
    /// Records a failed API call
    public func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()
        
        if failureCount >= failureThreshold {
            state = .open
        }
    }
    
    /// Checks if an API call can be attempted
    ///
    /// - Returns: True if call can be attempted, false if circuit is open
    public func canAttempt() -> Bool {
        switch state {
        case .closed:
            return true
        case .open:
            // Check if timeout elapsed
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) >= timeout {
                state = .halfOpen
                successCount = 0
                return true
            }
            return false
        case .halfOpen:
            return true
        }
    }
    
    /// Gets the current state (for debugging)
    public func getState() -> State {
        return state
    }
    
    /// Resets the circuit breaker to closed state
    public func reset() {
        state = .closed
        failureCount = 0
        successCount = 0
        lastFailureTime = nil
    }
}
