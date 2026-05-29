import Foundation
//
//  chuck_service.swift
//  ehrle_fatmi_proj
//
//  Created by Valentin Ehrle on 29/05/2026.
//
class ChuckService {
    static let shared = ChuckService()
    private let url = URL(string: "https://api.chucknorris.io/jokes/random")!

    func fetchJoke() async throws -> ChuckQuote {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ChuckQuote.self, from: data)
    }
}
