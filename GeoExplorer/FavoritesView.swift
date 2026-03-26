// FavoritesView.swift
// GeoExplorer
//
// Shows only the countries the user has favourited.
// Structurally mirrors CountryListView but filters to the saved names.
//
// Note how little code is needed for persistence:
//   • `@Query` gives us the live list of saved names
//   • We look up full Country objects from the JSON-loaded array by name
//   • Everything else (search, filter, row layout) is identical to CountryListView

import SwiftUI
import SwiftData

struct FavoritesView: View {

    @State private var searchText        = ""
    @State private var selectedContinent = "All"

    let continents = ["All", "Africa", "Americas", "Asia", "Europe", "Oceania"]

    // The full country dataset (unchanged — we just filter it below).
    private let countries = DataLoader.loadCountries()

    // `@Query` loads every FavoriteCountry row from the database and keeps
    // this array live. Add a favourite anywhere in the app and this view
    // updates instantly — no manual refresh needed.
    @Query private var favorites: [FavoriteCountry]

    // ── Derived values ────────────────────────────────────────────────────────

    // Build a Set of saved names for O(1) lookup instead of scanning the
    // array once per country. `Set` in Swift works like a mathematical set:
    // it holds unique values and `contains` runs in constant time.
    private var favoriteNames: Set<String> {
        Set(favorites.map { $0.name })
    }

    // Full Country objects whose name appears in the saved set.
    private var favoriteCountries: [Country] {
        countries.filter { favoriteNames.contains($0.name) }
    }

    // Apply search and continent filter on top of the favourites.
    private var filteredFavorites: [Country] {
        favoriteCountries.filter { country in
            let matchesSearch = searchText.isEmpty
                || country.name.localizedCaseInsensitiveContains(searchText)
                || country.capital.localizedCaseInsensitiveContains(searchText)

            let matchesContinent = selectedContinent == "All"
                || country.continent == selectedContinent

            return matchesSearch && matchesContinent
        }
    }

    // ── Body ──────────────────────────────────────────────────────────────────

    var body: some View {
        NavigationStack {
            if favorites.isEmpty {
                // `ContentUnavailableView` is a built-in iOS 17 component for
                // showing friendly empty states. It takes a title, SF Symbol,
                // and an optional description.
                ContentUnavailableView(
                    "No Favourites Yet",
                    systemImage: "heart",
                    description: Text("Tap the ♡ on any country to save it here.")
                )
                .navigationTitle("Favourites")
            } else {
                VStack(spacing: 0) {

                    // ── Continent filter pills ──────────────────────────────
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(continents, id: \.self) { continent in
                                Button(continent) {
                                    selectedContinent = continent
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
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

                    // ── Favourites list ─────────────────────────────────────
                    if filteredFavorites.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        List(filteredFavorites) { country in
                            NavigationLink(destination: CountryDetailView(country: country)) {
                                HStack(spacing: 14) {
                                    Text(country.flag)
                                        .font(.system(size: 36))
                                        .frame(width: 44)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(country.name)
                                            .font(.headline)
                                        Text(country.capital)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if selectedContinent == "All" {
                                        Text(country.continent)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }

                                    FavoriteButton(countryName: country.name)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Favourites")
                .searchable(text: $searchText, prompt: "Country or capital…")
            }
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
