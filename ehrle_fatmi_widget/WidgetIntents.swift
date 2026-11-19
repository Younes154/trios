//
//  WidgetIntents.swift
//  ehrle_fatmi_widget
//
//  Actions déclenchées par les boutons du widget (iOS 17+).
//  Après chaque action, WidgetKit recharge automatiquement la timeline,
//  donc le provider va chercher une nouvelle citation.
//

import AppIntents
import Foundation

/// Mémorise le personnage affiché, pour chaque source configurée.
/// Les intents des boutons s'exécutent dans le processus du widget,
/// donc les UserDefaults du widget suffisent (pas besoin d'App Group).
enum WidgetState {
    private static let defaults = UserDefaults.standard

    private static func key(_ configured: QuoteSource) -> String {
        "currentSource.\(configured.rawValue)"
    }

    static func currentSource(for configured: QuoteSource) -> QuoteSource {
        guard let raw = defaults.string(forKey: key(configured)),
              let source = QuoteSource(rawValue: raw) else {
            return configured
        }
        return source
    }

    static func setCurrentSource(_ source: QuoteSource, for configured: QuoteSource) {
        defaults.set(source.rawValue, forKey: key(configured))
    }
}

/// Bouton « nouvelle citation » : il suffit de recharger le widget.
struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Nouvelle citation"
    static var isDiscoverable = false

    func perform() async throws -> some IntentResult {
        .result()
    }
}

/// Bouton « personnage suivant » : Kanye → Chuck Norris → Breaking Bad → Kanye...
struct NextCharacterIntent: AppIntent {
    static var title: LocalizedStringResource = "Personnage suivant"
    static var isDiscoverable = false

    /// Source configurée du widget, pour savoir quel état modifier.
    @Parameter(title: "Source configurée")
    var configuredSource: QuoteSource

    init() {}

    init(configuredSource: QuoteSource) {
        self.configuredSource = configuredSource
    }

    func perform() async throws -> some IntentResult {
        let current = WidgetState.currentSource(for: configuredSource)
        WidgetState.setCurrentSource(current.next, for: configuredSource)
        return .result()
    }
}
