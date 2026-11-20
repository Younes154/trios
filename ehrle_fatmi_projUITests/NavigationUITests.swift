//
//  NavigationUITests.swift
//  ehrle_fatmi_projUITests
//
//  Vérifie la navigation entre les pages Kanye / Chuck / Breaking Bad via le menu.
//

import XCTest

final class NavigationUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // On saute l'écran de connexion Firebase : ces tests portent sur la navigation.
        app.launchArguments += ["-UITestAuthState", "signedIn"]
        app.launch()
    }

    @MainActor
    private func select(_ page: String) {
        let picker = app.buttons["pagePicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Le menu de navigation est introuvable")
        picker.tap()
        let option = app.buttons[page]
        XCTAssertTrue(option.waitForExistence(timeout: 5), "Option « \(page) » introuvable")
        option.tap()
    }

    @MainActor
    func testKanyePageIsShownAtLaunch() {
        XCTAssertTrue(app.staticTexts["Kanye a déjà dit ..."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateToChuckPage() {
        select("Chuck")
        XCTAssertTrue(app.staticTexts["le saviez-vous ?"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Kanye a déjà dit ..."].exists)
    }

    @MainActor
    func testNavigateToBreakingBadPage() {
        select("Breaking Bad")
        // « Breaking Bad » est aussi le libellé du menu : on cherche le titre de la page.
        let title = app.staticTexts.matching(identifier: "Breaking Bad").firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Kanye a déjà dit ..."].exists)
    }

    @MainActor
    func testNavigateBackToKanyePage() {
        select("Chuck")
        XCTAssertTrue(app.staticTexts["le saviez-vous ?"].waitForExistence(timeout: 5))
        select("Kanye")
        XCTAssertTrue(app.staticTexts["Kanye a déjà dit ..."].waitForExistence(timeout: 5))
    }
}
