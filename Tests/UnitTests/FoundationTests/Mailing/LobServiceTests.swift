//
//  LobServiceTests.swift
//  FightCityFoundationTests
//
//  Unit tests for LobService (stub implementation)
//

import XCTest
@testable import FightCityFoundation

@MainActor
final class LobServiceTests: XCTestCase {
    var sut: LobService!
    
    override func setUp() {
        super.setUp()
        sut = LobService.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSendCertifiedLetterThrowsApiDocsRequired() async {
        // Given
        let toAddress = LobAddress(
            addressLine1: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zip: "94102"
        )
        let fromAddress = LobAddress(
            addressLine1: "456 Oak Ave",
            city: "Los Angeles",
            state: "CA",
            zip: "90001"
        )
        let pdfData = Data()
        
        // When/Then
        do {
            _ = try await sut.sendCertifiedLetter(
                to: toAddress,
                from: fromAddress,
                pdfData: pdfData,
                description: "Test appeal"
            )
            XCTFail("Should have thrown LobAPIError.apiDocsRequired")
        } catch let error as LobAPIError {
            switch error {
            case .apiDocsRequired:
                // Expected
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testCheckLetterStatusThrowsApiDocsRequired() async {
        // Given
        let letterId = "test-letter-id"
        
        // When/Then
        do {
            _ = try await sut.checkLetterStatus(letterId)
            XCTFail("Should have thrown LobAPIError.apiDocsRequired")
        } catch let error as LobAPIError {
            switch error {
            case .apiDocsRequired:
                // Expected
                break
            default:
                XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
