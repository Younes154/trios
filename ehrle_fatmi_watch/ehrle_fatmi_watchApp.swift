//
//  ehrle_fatmi_watchApp.swift
//  ehrle_fatmi_watch
//
//  Point d'entrée de l'app Apple Watch.
//  Les modèles (modele/) et services (services/) sont partagés avec l'app iOS.
//

import SwiftUI

@main
struct ehrle_fatmi_watchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}
