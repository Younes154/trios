import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

/// Centralise toute la logique Firebase Auth (étape 5).
@MainActor
final class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    /// Argument de lancement réservé aux tests UI : `-UITestAuthState signedIn|signedOut`.
    /// Il rend l'état de connexion prévisible, quel que soit le compte resté connecté sur le simulateur.
    static let uiTestAuthStateKey = "UITestAuthState"

    init() {
        switch UserDefaults.standard.string(forKey: Self.uiTestAuthStateKey) {
        case "signedIn":
            // Tests UI : on affiche directement l'app, sans compte Firebase.
            isAuthenticated = true
        case "signedOut":
            // Tests UI : on part toujours de l'écran de connexion.
            try? Auth.auth().signOut()
        default:
            // Si l'utilisateur s'est déjà connecté lors d'un lancement précédent,
            // Firebase garde la session : on la restaure directement.
            user = Auth.auth().currentUser
            isAuthenticated = user != nil
        }
    }

    func signUp(email: String, password: String) {
        Task {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                self.user = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func signIn(email: String, password: String) {
        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                self.user = result.user
                self.isAuthenticated = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// Connexion Google (étape 9) : jeton Google -> credential Firebase.
    func signInWithGoogle() {
        Task {
            do {
                guard let clientID = FirebaseApp.app()?.options.clientID else {
                    self.errorMessage = "Client ID Google introuvable."
                    return
                }
                GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

                guard let rootViewController = UIApplication.shared.rootViewController else {
                    self.errorMessage = "Écran principal introuvable."
                    return
                }

                let googleResult = try await GIDSignIn.sharedInstance.signIn(
                    withPresenting: rootViewController
                )

                guard let idToken = googleResult.user.idToken?.tokenString else {
                    self.errorMessage = "Jeton Google introuvable."
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: googleResult.user.accessToken.tokenString
                )

                let authResult = try await Auth.auth().signIn(with: credential)
                self.user = authResult.user
                self.isAuthenticated = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            user = nil
            isAuthenticated = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
