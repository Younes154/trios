//
//  ServiceTests.swift
//  ehrle_fatmi_projTests
//
//  Teste les services réseau avec un faux URLProtocol (aucun appel Internet).
//

import XCTest
@testable import ehrle_fatmi_proj

final class ServiceTests: XCTestCase {

    private var session: URLSession!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        session = MockURLProtocol.makeSession()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        session = nil
        super.tearDown()
    }

    private func respond(status: Int = 200, json: String) {
        MockURLProtocol.handler = { _ in (status, Data(json.utf8)) }
    }

    private func assertThrowsURLError(
        _ code: URLError.Code,
        file: StaticString = #filePath, line: UInt = #line,
        _ block: () async throws -> Void
    ) async {
        do {
            try await block()
            XCTFail("Une erreur \(code) était attendue", file: file, line: line)
        } catch let error as URLError {
            XCTAssertEqual(error.code, code, file: file, line: line)
        } catch {
            XCTFail("Erreur inattendue : \(error)", file: file, line: line)
        }
    }

    // MARK: - Kanye

    func testKanyeServiceReturnsQuote() async throws {
        respond(json: #"{"quote":"Everything I'm not made me everything I am"}"#)
        let quote = try await KanyeService(session: session).fetchQuote()
        XCTAssertEqual(quote, "Everything I'm not made me everything I am")
    }

    func testKanyeServiceCallsKanyeRestAPI() async throws {
        respond(json: #"{"quote":"x"}"#)
        _ = try await KanyeService(session: session).fetchQuote()
        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.absoluteString, "https://api.kanye.rest/")
    }

    func testKanyeServiceThrowsOnServerError() async {
        respond(status: 500, json: #"{"quote":"x"}"#)
        await assertThrowsURLError(.badServerResponse) {
            _ = try await KanyeService(session: self.session).fetchQuote()
        }
    }

    func testKanyeServiceThrowsOnInvalidJSON() async {
        respond(json: "not json")
        do {
            _ = try await KanyeService(session: session).fetchQuote()
            XCTFail("Une erreur de décodage était attendue")
        } catch {
            XCTAssertTrue(error is DecodingError, "Reçu : \(error)")
        }
    }

    func testKanyeServicePropagatesNetworkError() async {
        MockURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }
        await assertThrowsURLError(.notConnectedToInternet) {
            _ = try await KanyeService(session: self.session).fetchQuote()
        }
    }

    // MARK: - Chuck Norris

    func testChuckServiceReturnsJoke() async throws {
        respond(json: #"{"id":"42","value":"Chuck Norris can divide by zero.","icon_url":"i","url":"u"}"#)
        let joke = try await ChuckService(session: session).fetchJoke()
        XCTAssertEqual(joke.id, "42")
        XCTAssertEqual(joke.value, "Chuck Norris can divide by zero.")
    }

    func testChuckServiceCallsChuckNorrisAPI() async throws {
        respond(json: #"{"id":"1","value":"v","icon_url":"i","url":"u"}"#)
        _ = try await ChuckService(session: session).fetchJoke()
        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.absoluteString,
                       "https://api.chucknorris.io/jokes/random")
    }

    func testChuckServiceThrowsOnNotFound() async {
        respond(status: 404, json: "{}")
        await assertThrowsURLError(.badServerResponse) {
            _ = try await ChuckService(session: self.session).fetchJoke()
        }
    }

    func testChuckServiceThrowsOnIncompleteJSON() async {
        respond(json: #"{"id":"1","value":"v"}"#)
        do {
            _ = try await ChuckService(session: session).fetchJoke()
            XCTFail("Une erreur de décodage était attendue")
        } catch {
            XCTAssertTrue(error is DecodingError, "Reçu : \(error)")
        }
    }

    // MARK: - Breaking Bad

    func testBreakingBadServiceReturnsOneOfTheQuotes() async throws {
        respond(json: """
        {"data":[
          {"quote":"Say my name.","author":"Walter White"},
          {"quote":"Better call Saul!","author":"Saul Goodman"}
        ]}
        """)
        let quote = try await BreakingBadService(session: session).fetchQuote()
        XCTAssertTrue(["Say my name.", "Better call Saul!"].contains(quote.quote))
        XCTAssertTrue(["Walter White", "Saul Goodman"].contains(quote.author))
    }

    func testBreakingBadServiceKeepsQuoteAndAuthorTogether() async throws {
        respond(json: """
        {"data":[
          {"quote":"Say my name.","author":"Walter White"},
          {"quote":"Better call Saul!","author":"Saul Goodman"}
        ]}
        """)
        let expected = ["Say my name.": "Walter White", "Better call Saul!": "Saul Goodman"]
        for _ in 0..<10 {
            let quote = try await BreakingBadService(session: session).fetchQuote()
            XCTAssertEqual(expected[quote.quote], quote.author)
        }
    }

    func testBreakingBadServiceCallsBreakingBadAPI() async throws {
        respond(json: #"{"data":[{"quote":"q","author":"a"}]}"#)
        _ = try await BreakingBadService(session: session).fetchQuote()
        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.absoluteString,
                       "https://api.mridul.tech/api/breaking-bad/quotes")
    }

    func testBreakingBadServiceThrowsOnEmptyList() async {
        respond(json: #"{"data":[]}"#)
        await assertThrowsURLError(.cannotParseResponse) {
            _ = try await BreakingBadService(session: self.session).fetchQuote()
        }
    }

    func testBreakingBadServiceThrowsOnServerError() async {
        respond(status: 503, json: #"{"data":[{"quote":"q","author":"a"}]}"#)
        await assertThrowsURLError(.badServerResponse) {
            _ = try await BreakingBadService(session: self.session).fetchQuote()
        }
    }

    // MARK: - Singletons

    func testSharedInstancesAreSingletons() {
        XCTAssertTrue(KanyeService.shared === KanyeService.shared)
        XCTAssertTrue(ChuckService.shared === ChuckService.shared)
        XCTAssertTrue(BreakingBadService.shared === BreakingBadService.shared)
    }
}
