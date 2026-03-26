// FlashcardSetupView.swift
// GeoExplorer
//
// Screen 1: the user chooses mode, continent, and card count before studying.
//
// New concepts:
//   • Form            — a grouped, scrollable settings-style layout
//   • Section         — a named group inside a Form
//   • Picker          — a control for choosing one value from a list
//   • pickerStyle     — controls how the Picker is rendered (.segmented, .menu, etc.)
//   • NavigationStack — the container that manages a push-navigation stack
//   • navigationDestination — declares which view to show for each route type

import SwiftUI

struct FlashcardSetupView: View {

    // ── Navigation state ──────────────────────────────────────────────────────
    // `path` is the navigation stack as an array of routes.
    // • Empty array  → we're at the setup screen (the root)
    // • [.session(cards)]  → session screen is pushed on top
    // • [.session(cards), .results(...)]  → results screen is on top
    //
    // Any screen can modify `path` to push, pop, or jump anywhere.
    @State private var path: [FlashcardRoute] = []

    // ── Setup selections ──────────────────────────────────────────────────────
    @State private var mode: FlashcardMode = .flagToCountry
    @State private var selectedContinent  = "All"
    @State private var cardCount          = 10    // 0 means "All"

    // ── Data ──────────────────────────────────────────────────────────────────
    private let countries   = DataLoader.loadCountries()
    private let continents  = ["All", "Africa", "Americas", "Asia", "Europe", "Oceania"]
    private let cardCounts  = [5, 10, 20, 0]    // 0 is the sentinel value for "All"

    // ── Derived values ────────────────────────────────────────────────────────
    private var availableCountries: [Country] {
        selectedContinent == "All"
            ? countries
            : countries.filter { $0.continent == selectedContinent }
    }

    // How many cards will actually be created (respects the pool size).
    private var actualCount: Int {
        cardCount == 0
            ? availableCountries.count
            : min(cardCount, availableCountries.count)
    }

    // ── Body ─────────────────────────────────────────────────────────────────
    var body: some View {
        // `NavigationStack(path:)` is the programmatic navigation container.
        // It watches `path` and pushes/pops screens as the array changes.
        NavigationStack(path: $path) {
            Form {

                // ── Mode section ──────────────────────────────────────────
                // `Picker` with `.segmented` style renders like iOS's segment
                // control — great for a small number of labelled options.
                Section("Study Mode") {
                    Picker("Mode", selection: $mode) {
                        ForEach(FlashcardMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ── Continent section ─────────────────────────────────────
                // Default Form Picker style shows the current value inline
                // and taps to a full list — perfect for 6+ options.
                Section("Continent") {
                    Picker("Continent", selection: $selectedContinent) {
                        ForEach(continents, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                }

                // ── Card count section ────────────────────────────────────
                Section("Number of Cards") {
                    Picker("Cards", selection: $cardCount) {
                        ForEach(cardCounts, id: \.self) { n in
                            Text(n == 0 ? "All" : "\(n)").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ── Summary + Start button ────────────────────────────────
                Section {
                    VStack(spacing: 14) {
                        // Live summary so the user knows what they'll study.
                        HStack {
                            Label("Cards to study", systemImage: "rectangle.stack")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(actualCount)")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Label("Region", systemImage: "globe")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(selectedContinent)
                                .fontWeight(.semibold)
                        }

                        // The Start button pushes a session route onto `path`,
                        // which causes NavigationStack to show FlashcardView.
                        Button {
                            path.append(.session(generateCards()))
                        } label: {
                            Text("Start Studying")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        // Disable if the continent has no countries.
                        .disabled(availableCountries.isEmpty)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Flashcards")

            // ── Navigation destinations ───────────────────────────────────
            // `navigationDestination(for:)` tells SwiftUI what to show when
            // a value of type FlashcardRoute is pushed onto the path.
            // This single declaration handles ALL routes for this NavigationStack.
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
    // `private` keeps this helper hidden from other files.
    private func generateCards() -> [Flashcard] {
        // Shuffle the pool so each session is different.
        let pool = availableCountries.shuffled()
        // Take the first N (or all if cardCount == 0).
        let slice = cardCount == 0 ? pool : Array(pool.prefix(cardCount))

        return slice.map { country in
            switch mode {
            case .flagToCountry:
                return Flashcard(
                    question   : country.flag,
                    answer     : country.name,
                    countryName: country.name
                )
            case .countryToCapital:
                return Flashcard(
                    question   : "\(country.flag)  \(country.name)",
                    answer     : country.capital,
                    countryName: country.name
                )
            }
        }
    }
}

#Preview {
    FlashcardSetupView()
}
