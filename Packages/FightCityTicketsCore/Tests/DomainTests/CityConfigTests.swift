//
//  CityConfigTests.swift
//  FightCityTicketsCoreTests
//
//  Unit tests for city configuration and pattern matching
//

import XCTest
@testable import FightCityTicketsCore

final class CityConfigTests: XCTestCase {
    
    var config: AppConfig!
    
    override func setUp() {
        super.setUp()
        config = AppConfig.shared
    }
    
    override func tearDown() {
        config = nil
        super.tearDown()
    }
    
    // MARK: - City Count Tests
    
    func testSupportedCitiesCount() {
        XCTAssertEqual(config.supportedCities.count, 4)
    }
    
    // MARK: - Pattern Matching Tests
    
    func testSanFranciscoPatternMatch() {
        let sfConfig = config.cityConfig(for: "us-ca-san_francisco")
        XCTAssertNotNil(sfConfig)
        
        // Valid SFMTA patterns
        XCTAssertTrue(sfConfig!.matches(citationNumber: "SFMTA12345678"))
        XCTAssertTrue(sfConfig!.matches(citationNumber: "MT12345678"))
        
        // Invalid patterns
        XCTAssertFalse(sfConfig!.matches(citationNumber: "12345678"))
        XCTAssertFalse(sfConfig!.matches(citationNumber: "SF12345678"))
    }
    
    func testLosAngelesPatternMatch() {
        let laConfig = config.cityConfig(for: "us-ca-los_angeles")
        XCTAssertNotNil(laConfig)
        
        // Valid LA patterns (6-11 alphanumeric)
        XCTAssertTrue(laConfig!.matches(citationNumber: "123456"))
        XCTAssertTrue(laConfig!.matches(citationNumber: "ABC123DEF"))
        XCTAssertTrue(laConfig!.matches(citationNumber: "A1B2C3D4E5F"))
        
        // Invalid - too short
        XCTAssertFalse(laConfig!.matches(citationNumber: "12345"))
    }
    
    func testNewYorkPatternMatch() {
        let nyConfig = config.cityConfig(for: "us-ny-new_york")
        XCTAssertNotNil(nyConfig)
        
        // Valid NYC patterns (exactly 10 digits)
        XCTAssertTrue(nyConfig!.matches(citationNumber: "1234567890"))
        XCTAssertTrue(nyConfig!.matches(citationNumber: "0000000000"))
        
        // Invalid - not 10 digits
        XCTAssertFalse(nyConfig!.matches(citationNumber: "12345"))
        XCTAssertFalse(nyConfig!.matches(citationNumber: "12345678901"))
        XCTAssertFalse(nyConfig!.matches(citationNumber: "ABCDEFGHIJ"))
    }
    
    func testDenverPatternMatch() {
        let denverConfig = config.cityConfig(for: "us-co-denver")
        XCTAssertNotNil(denverConfig)
        
        // Valid Denver patterns (5-9 digits)
        XCTAssertTrue(denverConfig!.matches(citationNumber: "12345"))
        XCTAssertTrue(denverConfig!.matches(citationNumber: "123456789"))
        
        // Invalid
        XCTAssertFalse(denverConfig!.matches(citationNumber: "1234"))
        XCTAssertFalse(denverConfig!.matches(citationNumber: "1234567890"))
    }
    
    // MARK: - City Lookup Tests
    
    func testCityLookupById() {
        let sf = config.cityConfig(for: "us-ca-san_francisco")
        XCTAssertEqual(sf?.name, "San Francisco")
        
        let la = config.cityConfig(for: "us-ca-los_angeles")
        XCTAssertEqual(la?.name, "Los Angeles")
    }
    
    func testCityLookupByCitationNumber() {
        // San Francisco
        let sfResult = config.cityConfig(for: "SFMTA12345678")
        XCTAssertEqual(sfResult?.id, "us-ca-san_francisco")
        
        // New York
        let nyResult = config.cityConfig(for: "1234567890")
        XCTAssertEqual(nyResult?.id, "us-ny-new_york")
    }
    
    // MARK: - Target Length Tests
    
    func testTargetLengthSanFrancisco() {
        let range = config.targetLength(for: "us-ca-san_francisco")
        XCTAssertEqual(range?.min, 10)
        XCTAssertEqual(range?.max, 11)
    }
    
    func testTargetLengthNewYork() {
        let range = config.targetLength(for: "us-ny-new_york")
        XCTAssertEqual(range?.min, 10)
        XCTAssertEqual(range?.max, 10)
    }
    
    // MARK: - Pattern Priority Tests
    
    func testPatternPriority() {
        XCTAssertEqual(config.patternPriority(for: "us-ca-san_francisco"), 1)
        XCTAssertEqual(config.patternPriority(for: "us-ny-new_york"), 2)
        XCTAssertEqual(config.patternPriority(for: "us-co-denver"), 3)
        XCTAssertEqual(config.patternPriority(for: "us-ca-los_angeles"), 4)
        XCTAssertNil(config.patternPriority(for: "unknown"))
    }
    
    // MARK: - City Properties Tests
    
    func testAppealDeadlines() {
        XCTAssertEqual(config.cityConfig(for: "us-ca-san_francisco")?.appealDeadlineDays, 21)
        XCTAssertEqual(config.cityConfig(for: "us-ny-new_york")?.appealDeadlineDays, 30)
        XCTAssertEqual(config.cityConfig(for: "us-co-denver")?.appealDeadlineDays, 21)
    }
    
    func testOnlineAppealAvailability() {
        XCTAssertTrue(config.cityConfig(for: "us-ca-san_francisco")?.canAppealOnline ?? false)
        XCTAssertTrue(config.cityConfig(for: "us-ca-los_angeles")?.canAppealOnline ?? false)
    }
    
    func testPhoneConfirmationRequirements() {
        XCTAssertTrue(config.cityConfig(for: "us-ca-san_francisco")?.phoneConfirmationRequired ?? false)
        XCTAssertFalse(config.cityConfig(for: "us-co-denver")?.phoneConfirmationRequired ?? true)
    }
}
