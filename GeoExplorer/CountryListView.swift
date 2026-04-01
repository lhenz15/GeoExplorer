// CountryListView.swift
// GeoExplorer
//
// The main country browser: searchable, filterable list of all 195 nations.
//
// `embedded` parameter
// ────────────────────
// When CountryListView is shown as a standalone tab it wraps itself in a
// NavigationStack so it can push CountryDetailView. When it is pushed from
// HomeView's NavigationStack (embedded: true), the outer NavigationStack is
// skipped — there is already a stack in place and adding a second one would
// create a double navigation bar.

import SwiftUI
import SwiftData

struct CountryListView: View {

    /// Set to `true` when this view is pushed from inside another NavigationStack
    /// (e.g. HomeView). Set to `false` (the default) when used as a tab root.
    var embedded: Bool = false

    @EnvironmentObject var lang: LanguageManager

    // Watch the mastery database so badges update live after a quiz or toggle.
    // We compute Set<String>s for O(1) lookup per row.
    @Query private var allProgress: [CountryProgress]

    private var goldBadgeIds: Set<String> {
        Set(allProgress.filter { $0.hasGoldBadge }.map { $0.countryName })
    }

    // Known-country ids for the green ✓ badge.
    private var knownIds: Set<String> {
        Set(allProgress.filter { $0.isKnown }.map { $0.countryName })
    }

    @State private var searchText        = ""
    @State private var selectedContinent = "all"

    var filteredCountries: [Country] {
        lang.countries.filter { country in
            let matchesSearch = searchText.isEmpty
                || country.name.localizedCaseInsensitiveContains(searchText)
                || country.capital.localizedCaseInsensitiveContains(searchText)

            let matchesContinent = selectedContinent == "all"
                || country.continent == selectedContinent

            return matchesSearch && matchesContinent
        }
    }

    var body: some View {
        if embedded {
            listContent
        } else {
            NavigationStack {
                listContent
            }
        }
    }

    // ── Extracted list content ────────────────────────────────────────────────
    @ViewBuilder
    private var listContent: some View {
        VStack(spacing: 0) {

            // ── Continent filter pills ──────────────────────────────────────
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

            // ── Country list ────────────────────────────────────────────────
            if filteredCountries.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List(filteredCountries) { country in
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

                            // ✓ already-known badge — green, shown when the
                            // user has manually marked this country as known.
                            if knownIds.contains(country.id) {
                                Text("✓")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                                    .transition(.scale.combined(with: .opacity))
                            }

                            // ⭐ gold badge — visible once the country is
                            // mastered in at least 3 of the 5 quiz modes.
                            // Matched by country.id (stable English key).
                            if goldBadgeIds.contains(country.id) {
                                Text("⭐")
                                    .font(.subheadline)
                                    .transition(.scale.combined(with: .opacity))
                            }

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
        .navigationTitle(lang.t("explore.navTitle"))
        .searchable(text: $searchText, prompt: lang.t("explore.search"))
        .toolbar {
            // Tap to open the bulk known-countries picker screen.
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    KnownCountriesView()
                } label: {
                    Image(systemName: "person.fill.checkmark")
                        .accessibilityLabel(lang.t("known.accessibility"))
                }
            }
        }
    }
}

#Preview {
    CountryListView()
        .environmentObject(LanguageManager())
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
