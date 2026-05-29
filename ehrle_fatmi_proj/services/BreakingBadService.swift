import Foundation

class BreakingBadService {
    static let shared = BreakingBadService()
    private let url = URL(string: "https://api.mridul.tech/api/breaking-bad/quotes")!

    func fetchQuote() async throws -> BreakingBadQuote {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(BreakingBadResponse.self, from: data)

        guard let quotes = decoded.data.randomElement() else {
            throw URLError(.cannotParseResponse)
        }

        return quotes
    }
}
