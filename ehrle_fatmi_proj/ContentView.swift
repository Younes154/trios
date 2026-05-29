import SwiftUI

enum AppPage {
    case kanye
    case chuck
    case breakingBad
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
                }
            }
        }
    }
}
