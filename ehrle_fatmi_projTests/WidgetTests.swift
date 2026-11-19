//
//  WidgetTests.swift
//  ehrle_fatmi_projTests
//
//  Teste la logique du widget : sources de citations, cycle des personnages,
//  état mémorisé et intents des boutons.
//

import SwiftUI
import XCTest
@testable import ehrle_fatmi_proj

final class QuoteSourceTests: XCTestCase {

    private let all: [QuoteSource] = [.kanye, .chuck, .breakingBad]

    // MARK: - Cycle des personnages

    func testNextCyclesThroughAllCharacters() {
        XCTAssertEqual(QuoteSource.kanye.next, .chuck)
        XCTAssertEqual(QuoteSource.chuck.next, .breakingBad)
        XCTAssertEqual(QuoteSource.breakingBad.next, .kanye)
    }

    func testThreeNextCallsComeBackToStart() {
        for source in all {
            XCTAssertEqual(source.next.next.next, source)
        }
    }

    func testNextVisitsEveryCharacterOnce() {
        var visited: [QuoteSource] = []
        var current = QuoteSource.kanye
        for _ in all {
            visited.append(current)
            current = current.next
        }
        XCTAssertEqual(Set(visited), Set(all))
        XCTAssertEqual(visited.count, all.count)
    }

    // MARK: - Affichage

    func testTitles() {
        XCTAssertEqual(QuoteSource.kanye.title, "Kanye a déjà dit...")
        XCTAssertEqual(QuoteSource.chuck.title, "Le saviez-vous ?")
        XCTAssertEqual(QuoteSource.breakingBad.title, "Breaking Bad")
    }

    func testImageNames() {
        XCTAssertEqual(QuoteSource.kanye.imageName, "kanye")
        XCTAssertEqual(QuoteSource.chuck.imageName, "chuck")
        XCTAssertEqual(QuoteSource.breakingBad.imageName, "walter")
    }

    func testColorsAreTwoColorGradientEndingInBlack() {
        for source in all {
            XCTAssertEqual(source.colors.count, 2, "\(source)")
            XCTAssertEqual(source.colors.last, .black, "\(source)")
        }
        XCTAssertEqual(QuoteSource.kanye.colors.first, .gray)
        XCTAssertEqual(QuoteSource.chuck.colors.first, .orange)
        XCTAssertEqual(QuoteSource.breakingBad.colors.first, .green)
    }

    func testEverySourceHasADisplayRepresentation() {
        for source in all {
            XCTAssertNotNil(QuoteSource.caseDisplayRepresentations[source], "\(source)")
        }
    }

    // MARK: - Identifiants et liens

    func testRawValuesRoundTrip() {
        for source in all {
            XCTAssertEqual(QuoteSource(rawValue: source.rawValue), source)
        }
        XCTAssertNil(QuoteSource(rawValue: "inconnu"))
    }

    func testURLs() {
        XCTAssertEqual(QuoteSource.kanye.url.absoluteString, "ehrlefatmi://kanye")
        XCTAssertEqual(QuoteSource.chuck.url.absoluteString, "ehrlefatmi://chuck")
        XCTAssertEqual(QuoteSource.breakingBad.url.absoluteString, "ehrlefatmi://breakingBad")
    }

    /// Le lien du widget doit ouvrir la bonne page de l'app.
    func testWidgetURLOpensMatchingAppPage() {
        XCTAssertEqual(AppPage(url: QuoteSource.kanye.url), .kanye)
        XCTAssertEqual(AppPage(url: QuoteSource.chuck.url), .chuck)
        XCTAssertEqual(AppPage(url: QuoteSource.breakingBad.url), .breakingBad)
    }
}

final class WidgetStateTests: XCTestCase {

    private let all: [QuoteSource] = [.kanye, .chuck, .breakingBad]

    private func clearState() {
        for source in all {
            UserDefaults.standard.removeObject(forKey: "currentSource.\(source.rawValue)")
        }
    }

    override func setUp() {
        super.setUp()
        clearState()
    }

    override func tearDown() {
        clearState()
        super.tearDown()
    }

    // MARK: - WidgetState

    func testDefaultsToConfiguredSource() {
        for source in all {
            XCTAssertEqual(WidgetState.currentSource(for: source), source)
        }
    }

    func testStoresCurrentSource() {
        WidgetState.setCurrentSource(.breakingBad, for: .kanye)
        XCTAssertEqual(WidgetState.currentSource(for: .kanye), .breakingBad)
    }

    func testStateIsSeparatePerConfiguredSource() {
        WidgetState.setCurrentSource(.chuck, for: .kanye)
        WidgetState.setCurrentSource(.kanye, for: .breakingBad)
        XCTAssertEqual(WidgetState.currentSource(for: .kanye), .chuck)
        XCTAssertEqual(WidgetState.currentSource(for: .breakingBad), .kanye)
        XCTAssertEqual(WidgetState.currentSource(for: .chuck), .chuck)
    }

    func testInvalidStoredValueFallsBackToConfiguredSource() {
        UserDefaults.standard.set("valeur-corrompue", forKey: "currentSource.chuck")
        XCTAssertEqual(WidgetState.currentSource(for: .chuck), .chuck)
    }

    // MARK: - Intents des boutons

    func testNextCharacterIntentAdvancesOneStep() async throws {
        _ = try await NextCharacterIntent(configuredSource: .kanye).perform()
        XCTAssertEqual(WidgetState.currentSource(for: .kanye), .chuck)
    }

    func testNextCharacterIntentFullCycle() async throws {
        let intent = NextCharacterIntent(configuredSource: .chuck)
        var seen: [QuoteSource] = []
        for _ in all {
            _ = try await intent.perform()
            seen.append(WidgetState.currentSource(for: .chuck))
        }
        XCTAssertEqual(seen, [.breakingBad, .kanye, .chuck])
    }

    func testNextCharacterIntentOnlyChangesItsOwnWidget() async throws {
        _ = try await NextCharacterIntent(configuredSource: .breakingBad).perform()
        XCTAssertEqual(WidgetState.currentSource(for: .breakingBad), .kanye)
        XCTAssertEqual(WidgetState.currentSource(for: .kanye), .kanye)
        XCTAssertEqual(WidgetState.currentSource(for: .chuck), .chuck)
    }

    func testRefreshIntentDoesNotChangeCharacter() async throws {
        WidgetState.setCurrentSource(.chuck, for: .kanye)
        _ = try await RefreshQuoteIntent().perform()
        XCTAssertEqual(WidgetState.currentSource(for: .kanye), .chuck)
    }

    func testIntentsAreHiddenFromShortcuts() {
        XCTAssertFalse(RefreshQuoteIntent.isDiscoverable)
        XCTAssertFalse(NextCharacterIntent.isDiscoverable)
    }
}
