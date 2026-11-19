//
//  WatchContentView.swift
//  ehrle_fatmi_watch
//

import SwiftUI

/// Navigation entre les 3 sources : on fait défiler les pages avec la Digital Crown.
struct WatchContentView: View {
    var body: some View {
        TabView {
            WatchQuoteView(
                title: "Kanye",
                imageName: "kanye",
                colors: [.gray, .black],
                load: {
                    let quote = try await KanyeService.shared.fetchQuote()
                    return (quote, nil)
                }
            )

            WatchQuoteView(
                title: "Chuck Norris",
                imageName: "chuck",
                colors: [.orange, .black],
                load: {
                    let joke = try await ChuckService.shared.fetchJoke()
                    return (joke.value, nil)
                }
            )

            WatchQuoteView(
                title: "Breaking Bad",
                imageName: "walter",
                colors: [.green, .black],
                load: {
                    let result = try await BreakingBadService.shared.fetchQuote()
                    return (result.quote, result.author)
                }
            )
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    WatchContentView()
}
