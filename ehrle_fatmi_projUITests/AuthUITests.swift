//
//  AuthUITests.swift
//  ehrle_fatmi_projUITests
//
//  Vérifie l'écran de connexion Firebase et la déconnexion.
//

import XCTest

final class AuthUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(authState: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-UITestAuthState", authState]
        app.launch()
        return app
    }

    @MainActor
    func testLoginScreenIsShownWhenSignedOut() {
        let app = launch(authState: "signedOut")

        XCTAssertTrue(app.staticTexts["Bienvenue"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Adresse email"].exists)
        XCTAssertTrue(app.secureTextFields["Mot de passe"].exists)
        XCTAssertTrue(app.buttons["Se connecter"].exists)
        XCTAssertTrue(app.buttons["Créer un compte"].exists)
        XCTAssertFalse(app.buttons["pagePicker"].exists, "L'app ne doit pas être accessible sans connexion")
    }

    @MainActor
    func testSignOutReturnsToLoginScreen() {
        let app = launch(authState: "signedIn")

        let signOut = app.buttons["signOutButton"]
        XCTAssertTrue(signOut.waitForExistence(timeout: 5))
        signOut.tap()

        XCTAssertTrue(app.staticTexts["Bienvenue"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["pagePicker"].exists)
    }
}
