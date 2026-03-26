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

    @State private var searchText = ""
    @State private var selectedContinent = "All"

    let continents = ["All", "Africa", "Americas", "Asia", "Europe", "Oceania"]

    private let countries = DataLoader.loadCountries()

    var filteredCountries: [Country] {
        countries.filter { country in
            let matchesSearch = searchText.isEmpty
                || country.name.localizedCaseInsensitiveContains(searchText)
                || country.capital.localizedCaseInsensitiveContains(searchText)

            let matchesContinent = selectedContinent == "All"
                || country.continent == selectedContinent

            return matchesSearch && matchesContinent
        }
    }

    var body: some View {
        // When embedded, skip the NavigationStack — the parent already provides one.
        // When standalone (tab root), wrap in a NavigationStack as before.
        if embedded {
            listContent
        } else {
            NavigationStack {
                listContent
            }
        }
    }

    // ── Extracted list content ────────────────────────────────────────────────
    // @ViewBuilder allows conditional returns inside a computed property.
    // Everything that used to be inside `NavigationStack { }` lives here.
    @ViewBuilder
    private var listContent: some View {
        VStack(spacing: 0) {

            // ── Continent filter pills ──────────────────────────────────────
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
        .navigationTitle("🌍 GeoExplorer")
        .searchable(text: $searchText, prompt: "Country or capital…")
    }
}

#Preview {
    CountryListView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
