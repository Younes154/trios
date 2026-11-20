import UIKit

/// Fournit le contrôleur racine dont Google Sign-In a besoin pour présenter sa fenêtre (étape 9).
extension UIApplication {
    var rootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
