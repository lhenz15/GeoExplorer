// FlashcardSetupView.swift
// GeoExplorer
//
// Screen 1: the user chooses mode, continent, and card count before studying.

import SwiftUI
import SwiftData

struct FlashcardSetupView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var lang: LanguageManager

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Query private var allProgress: [CountryProgress]

    // ── Settings ──────────────────────────────────────────────────────────────
    @AppStorage("excludeKnownCountries") private var excludeKnownCountries = false

    @State private var path: [FlashcardRoute] = []

    @State private var mode: FlashcardMode = .flagToCountry
    @State private var selectedContinent  = "all"
    @State private var cardCount          = 10    // 0 means "All"

    private let cardCounts = [5, 10, 20, 0]

    // Set of known country ids — empty when the toggle is off.
    private var knownIds: Set<String> {
        guard excludeKnownCountries else { return [] }
        return Set(allProgress.filter { $0.isKnown }.map { $0.countryName })
    }

    // ── Derived values ────────────────────────────────────────────────────────
    private var availableCountries: [Country] {
        var base = selectedContinent == "all"
            ? lang.countries
            : lang.countries.filter { $0.continent == selectedContinent }
        if !knownIds.isEmpty {
            base = base.filter { !knownIds.contains($0.id) }
        }
        return base
    }

    private var actualCount: Int {
        cardCount == 0
            ? availableCountries.count
            : min(cardCount, availableCountries.count)
    }

    // ── Body ─────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack(path: $path) {
            Form {

                // ── Mode section ──────────────────────────────────────────
                Section(lang.t("flashcard.setup.mode")) {
                    Picker("Mode", selection: $mode) {
                        ForEach(FlashcardMode.allCases, id: \.self) { m in
                            Text(m.localizedName(using: lang)).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ── Continent section ─────────────────────────────────────
                Section(lang.t("flashcard.setup.continent")) {
                    Picker("Continent", selection: $selectedContinent) {
                        ForEach(lang.continents) { c in
                            Text(c.name).tag(c.id)
                        }
                    }
                }

                // ── Card count section ────────────────────────────────────
                Section(lang.t("flashcard.setup.cardCount")) {
                    Picker("Cards", selection: $cardCount) {
                        ForEach(cardCounts, id: \.self) { n in
                            Text(n == 0 ? lang.t("flashcard.setup.all") : "\(n)").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ── Summary + Start button ────────────────────────────────
                Section {
                    VStack(spacing: 14) {
                        HStack {
                            Label(lang.t("flashcard.setup.cardsToStudy"), systemImage: "rectangle.stack")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(actualCount)")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Label(lang.t("flashcard.setup.region"), systemImage: "globe")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(lang.continentName(for: selectedContinent))
                                .fontWeight(.semibold)
                        }

                        Button {
                            path.append(.session(generateCards()))
                        } label: {
                            Text(lang.t("flashcard.setup.start"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(availableCountries.isEmpty)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(lang.t("flashcard.title"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationDestination(for: FlashcardRoute.self) { route in
                switch route {
                case .session(let cards):
                    FlashcardView(cards: cards, path: $path)
                case .results(let count, let cards):
                    FlashcardResultView(cardCount: count, cards: cards, path: $path)
                }
            }
        }
    }

    // ── Card generation ───────────────────────────────────────────────────────
    private func generateCards() -> [Flashcard] {
        let pool  = availableCountries.shuffled()
        let slice = cardCount == 0 ? pool : Array(pool.prefix(cardCount))

        return slice.map { country in
            switch mode {
            case .flagToCountry:
                return Flashcard(
                    question   : country.flag,
                    answer     : country.name,
                    countryName: country.id
                )
            case .countryToCapital:
                return Flashcard(
                    question   : "\(country.flag)  \(country.name)",
                    answer     : country.capital,
                    countryName: country.id
                )
            }
        }
    }
}

#Preview {
    FlashcardSetupView()
        .environmentObject(LanguageManager())
}
