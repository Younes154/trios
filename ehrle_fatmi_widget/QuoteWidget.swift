//
//  QuoteWidget.swift
//  ehrle_fatmi_widget
//

import AppIntents
import SwiftUI
import WidgetKit

struct QuoteEntry: TimelineEntry {
    let date: Date
    /// Source choisie dans les réglages du widget (point de départ du cycle).
    let configured: QuoteSource
    /// Personnage actuellement affiché (modifié par le bouton du widget).
    let source: QuoteSource
    let text: String
    let author: String?
}

struct QuoteProvider: AppIntentTimelineProvider {
    /// Fréquence de rafraîchissement demandée au système (indicative, iOS décide).
    private let refreshInterval: TimeInterval = 30 * 60

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: .now, configured: .kanye, source: .kanye,
                   text: "Chargement d'une citation...", author: nil)
    }

    func snapshot(for configuration: SelectSourceIntent, in context: Context) async -> QuoteEntry {
        if context.isPreview {
            return QuoteEntry(date: .now, configured: configuration.source, source: configuration.source,
                              text: "Une citation apparaîtra ici.", author: nil)
        }
        return await entry(for: configuration.source)
    }

    func timeline(for configuration: SelectSourceIntent, in context: Context) async -> Timeline<QuoteEntry> {
        let entry = await entry(for: configuration.source)
        return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(refreshInterval)))
    }

    private func entry(for configured: QuoteSource) async -> QuoteEntry {
        let source = WidgetState.currentSource(for: configured)
        do {
            let result = try await source.fetch()
            return QuoteEntry(date: .now, configured: configured, source: source,
                              text: result.text, author: result.author)
        } catch {
            return QuoteEntry(date: .now, configured: configured, source: source,
                              text: "Impossible de charger une citation.", author: nil)
        }
    }
}

struct QuoteWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuoteEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // En-tête : nom du personnage + bouton pour changer de personnage
            HStack {
                Text(entry.source.title)
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Button(intent: NextCharacterIntent(configuredSource: entry.configured)) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.white.opacity(0.2), in: Circle())
                }
                .buttonStyle(.plain)
            }

            // Corps : toucher la citation (ou l'image) charge une nouvelle citation
            Button(intent: RefreshQuoteIntent()) {
                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.text)
                            .font(family == .systemSmall ? .caption : .body)
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.leading)

                        if let author = entry.author, !author.isEmpty {
                            Text("— \(author)")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if family != .systemSmall {
                        Image(entry.source.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: family == .systemLarge ? 120 : 70)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .invalidatableContent()
        }
        .containerBackground(for: .widget) {
            LinearGradient(colors: entry.source.colors, startPoint: .top, endPoint: .bottom)
        }
        .widgetURL(entry.source.url)
    }
}

struct QuoteWidget: Widget {
    let kind = "QuoteWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSourceIntent.self, provider: QuoteProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Citation")
        .description("Touche la citation pour en avoir une nouvelle, et le bouton pour changer de personnage.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    QuoteWidget()
} timeline: {
    QuoteEntry(date: .now, configured: .kanye, source: .breakingBad,
               text: "I am the one who knocks!", author: "Walter White")
    QuoteEntry(date: .now, configured: .kanye, source: .chuck,
               text: "Chuck Norris a compté jusqu'à l'infini. Deux fois.", author: nil)
}
