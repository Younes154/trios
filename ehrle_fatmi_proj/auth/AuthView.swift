import SwiftUI
import GoogleSignInSwift

/// Écran de connexion / inscription (étape 6).
struct AuthView: View {
    @ObservedObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Bienvenue")
                    .font(.largeTitle.bold())

                TextField("Adresse email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                SecureField("Mot de passe", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = authManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Se connecter") {
                    authManager.signIn(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)

                Button("Créer un compte") {
                    authManager.signUp(email: email, password: password)
                }

                GoogleSignInButton {
                    authManager.signInWithGoogle()
                }
                .frame(height: 44)
            }
            .padding()
        }
    }
}
