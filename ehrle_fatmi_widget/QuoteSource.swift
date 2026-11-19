//
//  QuoteSource.swift
//  ehrle_fatmi_widget
//
//  La source de citation choisie par l'utilisateur dans les réglages du widget.
//

import AppIntents
import SwiftUI

enum QuoteSource: String, AppEnum {
    case kanye
    case chuck
    case breakingBad

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Source"

    static var caseDisplayRepresentations: [QuoteSource: DisplayRepresentation] = [
        .kanye: "Kanye",
        .chuck: "Chuck Norris",
        .breakingBad: "Breaking Bad",
    ]

    var title: String {
        switch self {
        case .kanye: "Kanye a déjà dit..."
        case .chuck: "Le saviez-vous ?"
        case .breakingBad: "Breaking Bad"
        }
    }

    var imageName: String {
        switch self {
        case .kanye: "kanye"
        case .chuck: "chuck"
        case .breakingBad: "walter"
        }
    }

    var colors: [Color] {
        switch self {
        case .kanye: [.gray, .black]
        case .chuck: [.orange, .black]
        case .breakingBad: [.green, .black]
        }
    }

    /// Personnage suivant dans le cycle du bouton du widget.
    var next: QuoteSource {
        switch self {
        case .kanye: .chuck
        case .chuck: .breakingBad
        case .breakingBad: .kanye
        }
    }

    /// Lien ouvert au tap sur le widget : l'app affiche la page correspondante.
    var url: URL {
        URL(string: "ehrlefatmi://\(rawValue)")!
    }

    /// Récupère une citation via les services partagés avec l'app.
    func fetch() async throws -> (text: String, author: String?) {
        switch self {
        case .kanye:
            return (try await KanyeService.shared.fetchQuote(), nil)
        case .chuck:
            return (try await ChuckService.shared.fetchJoke().value, nil)
        case .breakingBad:
            let quote = try await BreakingBadService.shared.fetchQuote()
            return (quote.quote, quote.author)
        }
    }
}

struct SelectSourceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Source des citations"
    static var description = IntentDescription("Choisis d'où viennent les citations.")

    @Parameter(title: "Source", default: .kanye)
    var source: QuoteSource
}
