//
//  WatchQuoteView.swift
//  ehrle_fatmi_watch
//

import SwiftUI

/// Une page générique : titre, citation, auteur éventuel,
/// et l'image du personnage sur laquelle on tape pour recharger.
struct WatchQuoteView: View {
    let title: String
    let imageName: String
    let colors: [Color]
    let load: () async throws -> (text: String, author: String?)

    @State private var text = "Chargement..."
    @State private var author: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)

                Button {
                    Task { await loadQuote() }
                } label: {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                } else {
                    Text(text)
                        .font(.footnote)
                        .multilineTextAlignment(.center)

                    if let author, !author.isEmpty {
                        Text("— \(author)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .containerBackground(
            LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom),
            for: .tabView
        )
        .task { await loadQuote() }
    }

    func loadQuote() async {
        isLoading = true
        do {
            let result = try await load()
            text = result.text
            author = result.author
        } catch {
            text = "Erreur : \(error.localizedDescription)"
            author = nil
        }
        isLoading = false
    }
}
