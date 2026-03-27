// FavoritesView.swift
// GeoExplorer
//
// Shows only the countries the user has favourited.
// Mirrors CountryListView but filters to the saved ids.
//
// `embedded` parameter — same pattern as CountryListView:
//   • false (default) → wraps in NavigationStack for use as a tab root.
//   • true            → skips NavigationStack; relies on the parent's stack.

import SwiftUI
import SwiftData

struct FavoritesView: View {

    /// Set to `true` when pushed from HomeView's NavigationStack.
    var embedded: Bool = false

    @EnvironmentObject var lang: LanguageManager

    @State private var searchText        = ""
    @State private var selectedContinent = "all"

    @Query private var favorites: [FavoriteCountry]

    // FavoriteCountry.name stores the stable English country id.
    private var favoriteIds: Set<String> {
        Set(favorites.map { $0.name })
    }

    private var favoriteCountries: [Country] {
        lang.countries.filter { favoriteIds.contains($0.id) }
    }

    private var filteredFavorites: [Country] {
        favoriteCountries.filter { country in
            let matchesSearch = searchText.isEmpty
                || country.name.localizedCaseInsensitiveContains(searchText)
                || country.capital.localizedCaseInsensitiveContains(searchText)

            let matchesContinent = selectedContinent == "all"
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
                Text(lang.t("favorites.empty.title"))
                    .font(.title2)
                    .fontWeight(.bold)
                Text(lang.t("favorites.empty.subtitle"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(lang.t("favorites.title"))
        } else {
            VStack(spacing: 0) {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(lang.continents) { continent in
                            Button(continent.name) {
                                selectedContinent = continent.id
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedContinent == continent.id
                                        ? AppColors.accent
                                        : AppColors.surface)
                            .foregroundStyle(selectedContinent == continent.id
                                             ? Color.white
                                             : Color.primary)
                            .clipShape(Capsule())
                            .fontWeight(selectedContinent == continent.id ? .semibold : .regular)
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

                                if selectedContinent == "all" {
                                    Text(lang.continentName(for: country.continent))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }

                                FavoriteButton(countryId: country.id)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(lang.t("favorites.title"))
            .searchable(text: $searchText, prompt: lang.t("favorites.search"))
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(LanguageManager())
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
