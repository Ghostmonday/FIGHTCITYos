//
//  FightCityUITests.swift
//  FightCityUITests
//
//  UI tests for FightCityTickets app.
//

import XCTest

final class FightCityUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
