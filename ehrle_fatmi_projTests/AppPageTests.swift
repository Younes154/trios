//
//  AppPageTests.swift
//  ehrle_fatmi_projTests
//
//  Vérifie la navigation par lien profond (tap sur le widget).
//

import XCTest
@testable import ehrle_fatmi_proj

final class AppPageTests: XCTestCase {

    private func page(_ string: String) -> AppPage? {
        AppPage(url: URL(string: string)!)
    }

    func testKanyeLinkOpensKanyePage() {
        XCTAssertEqual(page("ehrlefatmi://kanye"), .kanye)
    }

    func testChuckLinkOpensChuckPage() {
        XCTAssertEqual(page("ehrlefatmi://chuck"), .chuck)
    }

    func testBreakingBadLinkOpensBreakingBadPage() {
        XCTAssertEqual(page("ehrlefatmi://breakingBad"), .breakingBad)
    }

    func testUnknownHostIsIgnored() {
        XCTAssertNil(page("ehrlefatmi://inconnu"))
    }

    func testLinkWithoutHostIsIgnored() {
        XCTAssertNil(page("ehrlefatmi:"))
    }

    func testHostIsCaseSensitive() {
        // Le widget génère exactement « breakingBad » (rawValue de QuoteSource).
        XCTAssertNil(page("ehrlefatmi://breakingbad"))
    }
}
