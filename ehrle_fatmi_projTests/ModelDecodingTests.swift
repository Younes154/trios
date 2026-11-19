//
//  ModelDecodingTests.swift
//  ehrle_fatmi_projTests
//
//  Vérifie le décodage JSON des modèles de citations.
//

import XCTest
@testable import ehrle_fatmi_proj

final class ModelDecodingTests: XCTestCase {

    private let decoder = JSONDecoder()

    // MARK: - Kanye

    func testKanyeQuoteDecodesQuote() throws {
        let json = Data(#"{"quote":"I am a god"}"#.utf8)
        let quote = try decoder.decode(KanyeQuote.self, from: json)
        XCTAssertEqual(quote.quote, "I am a god")
    }

    func testKanyeQuoteMissingFieldThrows() {
        let json = Data(#"{"text":"oops"}"#.utf8)
        XCTAssertThrowsError(try decoder.decode(KanyeQuote.self, from: json))
    }

    // MARK: - Chuck Norris

    func testChuckQuoteDecodesSnakeCaseIconUrl() throws {
        let json = Data("""
        {
          "id": "abc123",
          "value": "Chuck Norris counted to infinity. Twice.",
          "icon_url": "https://example.com/icon.png",
          "url": "https://example.com/jokes/abc123",
          "categories": [],
          "created_at": "2020-01-05 13:42:19.324003"
        }
        """.utf8)
        let joke = try decoder.decode(ChuckQuote.self, from: json)
        XCTAssertEqual(joke.id, "abc123")
        XCTAssertEqual(joke.value, "Chuck Norris counted to infinity. Twice.")
        XCTAssertEqual(joke.iconUrl, "https://example.com/icon.png")
        XCTAssertEqual(joke.url, "https://example.com/jokes/abc123")
    }

    func testChuckQuoteCamelCaseIconUrlIsNotAccepted() {
        let json = Data(#"{"id":"1","value":"v","iconUrl":"i","url":"u"}"#.utf8)
        XCTAssertThrowsError(try decoder.decode(ChuckQuote.self, from: json))
    }

    func testChuckQuoteEncodesBackToSnakeCase() throws {
        let json = Data(#"{"id":"1","value":"v","icon_url":"i","url":"u"}"#.utf8)
        let joke = try decoder.decode(ChuckQuote.self, from: json)
        let encoded = try JSONEncoder().encode(joke)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: String])
        XCTAssertEqual(object["icon_url"], "i")
        XCTAssertNil(object["iconUrl"])
    }

    // MARK: - Breaking Bad

    func testBreakingBadResponseDecodesList() throws {
        let json = Data("""
        {"data":[
          {"quote":"I am the one who knocks.","author":"Walter White"},
          {"quote":"Yeah, science!","author":"Jesse Pinkman"}
        ]}
        """.utf8)
        let response = try decoder.decode(BreakingBadResponse.self, from: json)
        XCTAssertEqual(response.data.count, 2)
        XCTAssertEqual(response.data[0].quote, "I am the one who knocks.")
        XCTAssertEqual(response.data[0].author, "Walter White")
        XCTAssertEqual(response.data[1].author, "Jesse Pinkman")
    }

    func testBreakingBadResponseEmptyList() throws {
        let json = Data(#"{"data":[]}"#.utf8)
        let response = try decoder.decode(BreakingBadResponse.self, from: json)
        XCTAssertTrue(response.data.isEmpty)
    }

    func testBreakingBadQuoteMissingAuthorThrows() {
        let json = Data(#"{"data":[{"quote":"Say my name."}]}"#.utf8)
        XCTAssertThrowsError(try decoder.decode(BreakingBadResponse.self, from: json))
    }
}
