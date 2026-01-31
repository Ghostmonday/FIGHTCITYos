//
//  CircuitBreakerTests.swift
//  FightCityFoundationTests
//
//  Unit tests for CircuitBreaker
//

import XCTest
@testable import FightCityFoundation

@MainActor
final class CircuitBreakerTests: XCTestCase {
    var sut: CircuitBreaker!
    
    override func setUp() {
        super.setUp()
        sut = CircuitBreaker(
            failureThreshold: 3,
            successThreshold: 2,
            timeout: 1.0
        )
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialStateIsClosed() async {
        // When
        let state = await sut.getState()
        
        // Then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(await sut.canAttempt())
    }
    
    func testOpensAfterFailureThreshold() async {
        // Given
        let threshold = 3
        
        // When
        for _ in 0..<threshold {
            await sut.recordFailure()
        }
        
        // Then
        let state = await sut.getState()
        XCTAssertEqual(state, .open)
        XCTAssertFalse(await sut.canAttempt())
    }
    
    func testHalfOpenAfterTimeout() async {
        // Given
        // Open the circuit
        for _ in 0..<3 {
            await sut.recordFailure()
        }
        XCTAssertEqual(await sut.getState(), .open)
        
        // When - wait for timeout
        try? await Task.sleep(nanoseconds: 1_100_000_000) // 1.1 seconds
        
        // Then - should be half-open
        let canAttempt = await sut.canAttempt()
        XCTAssertTrue(canAttempt)
        let state = await sut.getState()
        XCTAssertEqual(state, .halfOpen)
    }
    
    func testClosesAfterSuccessThreshold() async {
        // Given - open circuit, then timeout
        for _ in 0..<3 {
            await sut.recordFailure()
        }
        try? await Task.sleep(nanoseconds: 1_100_000_000)
        _ = await sut.canAttempt() // Moves to half-open
        
        // When - record successes
        for _ in 0..<2 {
            await sut.recordSuccess()
        }
        
        // Then
        let state = await sut.getState()
        XCTAssertEqual(state, .closed)
    }
    
    func testReset() async {
        // Given - open circuit
        for _ in 0..<3 {
            await sut.recordFailure()
        }
        XCTAssertEqual(await sut.getState(), .open)
        
        // When
        await sut.reset()
        
        // Then
        let state = await sut.getState()
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(await sut.canAttempt())
    }
}
