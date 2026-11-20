import SwiftUI

/// Vue racine (étape 7) : affiche l'écran de connexion ou l'app selon l'état d'authentification.
/// L'écran « connecté » est le ContentView existant (Kanye / Chuck / Breaking Bad).
struct RootView: View {
    @StateObject private var authManager = AuthManager()

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ContentView(authManager: authManager)
            } else {
                AuthView(authManager: authManager)
            }
        }
    }
}
