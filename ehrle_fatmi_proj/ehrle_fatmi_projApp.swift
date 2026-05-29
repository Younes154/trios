//
//  ehrle_fatmi_projApp.swift
//  ehrle_fatmi_proj
//
//  Created by Valentin Ehrle on 29/05/2026.
//

import SwiftUI

@main
struct ehrle_fatmi_projApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
