import SwiftUI
//
//  BreakingBadView.swift
//  ehrle_fatmi_proj
//
//  Created by Valentin Ehrle on 29/05/2026.
//



struct BreakingBadView: View {
    @State private var quote = "Charge une citation..."
    @State private var author = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Breaking Bad")
                .font(.largeTitle.bold())

            VStack(spacing: 8) {
                Text(quote)
                    .font(.title3)
                    .multilineTextAlignment(.center)

                if !author.isEmpty {
                    Text("— \(author)")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Button {
                Task { await loadQuote() }
            } label: {
                Image("walter")
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            if isLoading {
                ProgressView()
            }
        }
        .padding()
        .task { await loadQuote() }
    }

    func loadQuote() async {
        isLoading = true
        do {
            let result = try await BreakingBadService.shared.fetchQuote()
            quote = result.quote
            author = result.author
        } catch {
            quote = "Erreur: \(error.localizedDescription)"
            author = ""
        }
        isLoading = false
    }
}
