import SwiftUI

struct KanyeView: View {
    @State private var quote = "Appuie pour une citation..."
    @State private var isLoading = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Kanye a déjà dit ...")
                    .font(.largeTitle.bold())

                Text(quote)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()

                Button {
                    Task { await loadQuote() }
                } label: {
                    Image("Image 1")
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }
            }
            .padding()
        }
        .task { await loadQuote() }
    }

    func loadQuote() async {
        isLoading = true
        do {
            quote = try await KanyeService.shared.fetchQuote()
        } catch {
            quote = "Erreur: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
