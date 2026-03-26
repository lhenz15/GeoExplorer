// CountryListView.swift
// GeoExplorer
//
// The main screen of the app: a searchable, filterable list of all countries.

import SwiftUI
import SwiftData

struct CountryListView: View {

    // `@State` tells SwiftUI "when this variable changes, redraw the view."
    // The `$` prefix creates a two-way binding — the search bar writes into
    // `searchText` and the view reads from it simultaneously.
    @State private var searchText = ""
    @State private var selectedContinent = "All"

    // All available filter options. "All" means no filter is applied.
    let continents = ["All", "Africa", "Americas", "Asia", "Europe", "Oceania"]

    // Load all countries once from JSON when the view is first created.
    // `let` means this array never changes — DataLoader does the heavy
    // lifting of finding, reading, and decoding the JSON file.
    private let countries = DataLoader.loadCountries()

    // A computed property — recalculated every time `searchText` or
    // `selectedContinent` changes. SwiftUI automatically notices the change
    // and rerenders the list.
    var filteredCountries: [Country] {
        countries.filter { country in
            // `localizedCaseInsensitiveContains` handles "france" == "France".
            let matchesSearch = searchText.isEmpty
                || country.name.localizedCaseInsensitiveContains(searchText)
                || country.capital.localizedCaseInsensitiveContains(searchText)

            let matchesContinent = selectedContinent == "All"
                || country.continent == selectedContinent

            return matchesSearch && matchesContinent
        }
    }

    var body: some View {
        // `NavigationStack` gives us the navigation bar at the top and lets
        // us push detail views later (you'll add those in a future step).
        NavigationStack {
            VStack(spacing: 0) {

                // ── Continent filter pills ──────────────────────────────
                // A horizontal scroll so the pills don't wrap onto two lines.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(continents, id: \.self) { continent in
                            Button(continent) {
                                // Tapping a pill updates `selectedContinent`,
                                // which triggers a recompute of `filteredCountries`.
                                selectedContinent = continent
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            // Highlight the active pill in blue, others in grey.
                            .background(selectedContinent == continent
                                        ? Color.blue
                                        : Color(.systemGray5))
                            .foregroundStyle(selectedContinent == continent
                                             ? Color.white
                                             : Color.primary)
                            .clipShape(Capsule())
                            .fontWeight(selectedContinent == continent ? .semibold : .regular)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(Color(.systemBackground))

                Divider()

                // ── Country list ────────────────────────────────────────
                if filteredCountries.isEmpty {
                    // Friendly empty state instead of a blank screen.
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(filteredCountries) { country in
                        // `NavigationLink` wraps a row and makes it tappable.
                        // When tapped, SwiftUI pushes `CountryDetailView` onto
                        // the navigation stack and shows a back button automatically.
                        NavigationLink(destination: CountryDetailView(country: country)) {
                            HStack(spacing: 14) {
                                // Flag emoji displayed large so it's easy to learn.
                                Text(country.flag)
                                    .font(.system(size: 36))
                                    .frame(width: 44)   // fixed width keeps names aligned

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(country.name)
                                        .font(.headline)
                                    Text(country.capital)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                // Show continent tag only when "All" is selected,
                                // otherwise it's redundant.
                                if selectedContinent == "All" {
                                    Text(country.continent)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }

                                // Heart button — self-contained, reads and writes
                                // SwiftData on its own. `.plain` buttonStyle means
                                // tapping the heart doesn't also trigger the
                                // NavigationLink navigation.
                                FavoriteButton(countryName: country.name)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("🌍 GeoExplorer")
            // `.searchable` adds the search bar to the navigation bar and
            // wires `searchText` up automatically — no extra code needed.
            .searchable(text: $searchText, prompt: "Country or capital…")
        }
    }
}

#Preview {
    CountryListView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
