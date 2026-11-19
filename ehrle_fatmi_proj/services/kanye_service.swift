import Foundation
//
//  kanye_service.swift
//  ehrle_fatmi_proj
//
//  Created by Valentin Ehrle on 29/05/2026.
//
class KanyeService {
    static let shared = KanyeService()
    private let url = URL(string: "https://api.kanye.rest/")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchQuote() async throws -> String {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(KanyeQuote.self, from: data)
        return decoded.quote
    }
}

