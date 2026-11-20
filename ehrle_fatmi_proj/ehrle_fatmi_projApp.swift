//
//  ehrle_fatmi_projApp.swift
//  ehrle_fatmi_proj
//
//  Created by Valentin Ehrle on 29/05/2026.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct ehrle_fatmi_projApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Retour de la fenêtre Google vers l'app (étape 9)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
