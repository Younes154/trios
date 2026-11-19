//
//  MockURLProtocol.swift
//  ehrle_fatmi_projTests
//
//  Intercepte les requêtes réseau pour tester les services sans Internet.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    /// Réponse renvoyée pour chaque requête : (code HTTP, corps) ou une erreur.
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (Int, Data))?
    /// Dernière requête reçue, pour vérifier l'URL appelée.
    nonisolated(unsafe) static var lastRequest: URLRequest?

    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    static func reset() {
        handler = nil
        lastRequest = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        MockURLProtocol.lastRequest = request
        guard let handler = MockURLProtocol.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (status, data) = try handler(request)
            let response = HTTPURLResponse(url: request.url!, statusCode: status,
                                           httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
