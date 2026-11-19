import SwiftUI

enum AppPage {
    case kanye
    case chuck
    case breakingBad

    /// Page correspondant à un lien du widget (ehrlefatmi://kanye, ehrlefatmi://chuck, ehrlefatmi://breakingBad).
    init?(url: URL) {
        switch url.host {
        case "kanye": self = .kanye
        case "chuck": self = .chuck
        case "breakingBad": self = .breakingBad
        default: return nil
        }
    }
}

struct ContentView: View {
    @State private var currentPage: AppPage = .kanye

    var body: some View {
        NavigationStack {
            Group {
                switch currentPage {
                case .kanye:
                    KanyeView()
                case .chuck:
                    ChuckView()
                case .breakingBad:
                    BreakingBadView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Menu", selection: $currentPage) {
                        Text("Kanye").tag(AppPage.kanye)
                        Text("Chuck").tag(AppPage.chuck)
                        Text("Breaking Bad").tag(AppPage.breakingBad)
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("pagePicker")
                }
            }
        }
        // Tap sur un widget : ehrlefatmi://kanye, ehrlefatmi://chuck ou ehrlefatmi://breakingBad
        .onOpenURL { url in
            if let page = AppPage(url: url) {
                currentPage = page
            }
        }
    }
}
