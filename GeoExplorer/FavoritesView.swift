// FavoritesView.swift
// GeoExplorer
//
// Shows only the countries the user has favourited.
// Mirrors CountryListView but filters to the saved names.
//
// `embedded` parameter — same pattern as CountryListView:
//   • false (default) → wraps in NavigationStack for use as a tab root.
//   • true            → skips NavigationStack; relies on the parent's stack.

import SwiftUI
import SwiftData

struct FavoritesView: View {

    /// Set to `true` when pushed from HomeView's NavigationStack.
    var embedded: Bool = false

    @State private var searchText        = ""
    @State private var selectedContinent = "All"

    let continents = ["All", "Africa", "Americas", "Asia", "Europe", "Oceania"]

    private let countries = DataLoader.loadCountries()

    @Query private var favorites: [FavoriteCountry]

    private var favoriteNames: Set<String> {
        Set(favorites.map { $0.name })
    }

    private var favoriteCountries: [Country] {
        countries.filter { favoriteNames.contains($0.name) }
    }

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
        if embedded {
            listContent
        } else {
            NavigationStack {
                listContent
            }
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if favorites.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                Text("🌍")
                    .font(.system(size: 80))
                Text("No Favourites Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Tap the ♡ on any country\nto save it here.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Favourites")
        } else {
            VStack(spacing: 0) {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(continents, id: \.self) { continent in
                            Button(continent) {
                                selectedContinent = continent
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedContinent == continent
                                        ? AppColors.accent
                                        : AppColors.surface)
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

#Preview {
    FavoritesView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
