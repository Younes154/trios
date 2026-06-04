import SwiftUI

struct ChuckView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var joke = "Charge une blague..."
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Image("chuckbg")
                .resizable()
                .ignoresSafeArea()
            ScrollView{
                VStack(spacing: 24) {
                    Text("le saviez-vous ?")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        Text(joke)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Button {
                        Task { await loadJoke() }
                    } label: {
                        Image("chuck")
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)
                    
                    if isLoading {
                        ProgressView()
                    }
                }
                .padding()
                .task { await loadJoke() }
            }
        }
    }

    func loadJoke() async {
        isLoading = true
        do {
            let result = try await ChuckService.shared.fetchJoke()
            joke = result.value
        } catch {
            joke = "Erreur: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
