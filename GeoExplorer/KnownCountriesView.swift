// KnownCountriesView.swift
// GeoExplorer
//
// A full-screen list of all 195 countries where the user can manually mark
// countries as 'already known'.  Tapping a row toggles the isKnown flag on
// that country's CountryProgress record in SwiftData.
//
// ── How the 'Select All' button works ────────────────────────────────────────
// Each continent section header has a 'Select All' button.  If every country
// in that continent is already known it acts as 'Deselect All' instead —
// i.e. it always moves the whole continent to the *opposite* of its current
// majority state.
//
// ── SwiftUI concept: List + Section ──────────────────────────────────────────
// List is SwiftUI's scrollable table.  Section lets you group rows with an
// optional header and footer.  Here we group by continent so the 'Select All'
// button appears at the top of each group naturally.
//
// ── SwiftUI concept: @Query ───────────────────────────────────────────────────
// @Query fetches all CountryProgress records from SwiftData and re-runs
// whenever any record changes.  The view re-renders automatically — you never
// need to call 'refresh' manually.

import SwiftUI
import SwiftData

struct KnownCountriesView: View {

    @EnvironmentObject var lang: LanguageManager

    // All progress records — we filter in computed properties below.
    @Query private var allProgress: [CountryProgress]
    @Environment(\.modelContext) private var modelContext

    @State private var searchText        = ""
    @State private var selectedContinent = "all"

    // ── Derived data ──────────────────────────────────────────────────────────

    // Set of country ids (English) that are currently marked as known.
    // Using a Set gives O(1) lookup when drawing each row.
    private var knownIds: Set<String> {
        Set(allProgress.filter { $0.isKnown }.map { $0.countryName })
    }

    // How many of the currently visible countries are marked known.
    private var visibleKnownCount: Int {
        filteredCountries.filter { knownIds.contains($0.id) }.count
    }

    // Countries that pass both the search filter and the continent filter.
    private var filteredCountries: [Country] {
        lang.countries.filter { country in
            let matchesSearch = searchText.isEmpty
                || country.name.localizedCaseInsensitiveContains(searchText)
                || country.capital.localizedCaseInsensitiveContains(searchText)
            let matchesContinent = selectedContinent == "all"
                || country.continent == selectedContinent
            return matchesSearch && matchesContinent
        }
    }

    // Only the continents that have at least one country in filteredCountries.
    // This hides continent sections when searching narrows the list.
    private var visibleContinents: [Continent] {
        let ids = Set(filteredCountries.map { $0.continent })
        return lang.continents.filter { ids.contains($0.id) }
    }

    // Countries for a specific continent within the current filters.
    private func countries(for continentId: String) -> [Country] {
        filteredCountries.filter { $0.continent == continentId }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        VStack(spacing: 0) {

            // ── Status line ────────────────────────────────────────────────
            // Shows how many of the visible countries are marked known.
            Text("\(visibleKnownCount) \(lang.t("known.status.of")) \(filteredCountries.count) \(lang.t("known.status.suffix"))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))

            Divider()

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
                                    ? AppColors.accent : AppColors.surface)
                        .foregroundStyle(selectedContinent == continent.id
                                         ? Color.white : Color.primary)
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
            // "All" → flat list, just like the Explore tab.
            // Specific continent → single section with a 'Select All' header button.
            if filteredCountries.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else if selectedContinent == "all" {
                // Flat list — no grouping, no section headers.
                List(filteredCountries) { country in
                    KnownCountryRow(
                        country : country,
                        isKnown : knownIds.contains(country.id),
                        onToggle: { toggleKnown(country.id) }
                    )
                }
                .listStyle(.plain)
            } else {
                // Single continent selected — show one section with a bulk toggle.
                List {
                    ForEach(visibleContinents) { continent in
                        Section {
                            ForEach(countries(for: continent.id)) { country in
                                KnownCountryRow(
                                    country : country,
                                    isKnown : knownIds.contains(country.id),
                                    onToggle: { toggleKnown(country.id) }
                                )
                            }
                        } header: {
                            HStack {
                                Text(continent.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Spacer()
                                let allKnown = countries(for: continent.id)
                                    .allSatisfy { knownIds.contains($0.id) }
                                Button(allKnown ? lang.t("known.deselectAll") : lang.t("known.selectAll")) {
                                    selectAll(in: continent.id, currentlyAllKnown: allKnown)
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.accent)
                            }
                            .padding(.vertical, 2)
                            .textCase(nil)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(lang.t("known.navTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: lang.t("known.search"))
        .background(AppColors.background)
        .toolbar {
            // Only show the bulk toggle button in the flat 'All' view.
            // In continent view the Select All button lives in the section header.
            if selectedContinent == "all" {
                ToolbarItem(placement: .navigationBarTrailing) {
                    let allKnown = filteredCountries.allSatisfy { knownIds.contains($0.id) }
                    Button(allKnown ? lang.t("known.deselectAll") : lang.t("known.selectAll")) {
                        selectAllVisible(currentlyAllKnown: allKnown)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // ── Actions ───────────────────────────────────────────────────────────────

    /// Toggle the isKnown flag for a single country.
    private func toggleKnown(_ countryId: String) {
        if let existing = allProgress.first(where: { $0.countryName == countryId }) {
            existing.isKnown.toggle()
        } else {
            // Create a fresh CountryProgress record with isKnown = true.
            // modelContext.insert registers it with SwiftData so it is saved.
            let p = CountryProgress(countryName: countryId)
            p.isKnown = true
            modelContext.insert(p)
        }
    }

    /// Bulk-toggle all currently visible countries (used in the flat 'All' view).
    private func selectAllVisible(currentlyAllKnown: Bool) {
        let targetValue = !currentlyAllKnown
        for country in filteredCountries {
            if let existing = allProgress.first(where: { $0.countryName == country.id }) {
                existing.isKnown = targetValue
            } else if targetValue {
                let p = CountryProgress(countryName: country.id)
                p.isKnown = true
                modelContext.insert(p)
            }
        }
    }

    /// Bulk-toggle all countries in a continent.
    /// - If every country is already known: unmark all of them.
    /// - Otherwise: mark all of them as known.
    private func selectAll(in continentId: String, currentlyAllKnown: Bool) {
        let countriesInContinent = lang.countries.filter { $0.continent == continentId }
        let targetValue = !currentlyAllKnown   // flip the majority state

        for country in countriesInContinent {
            if let existing = allProgress.first(where: { $0.countryName == country.id }) {
                existing.isKnown = targetValue
            } else if targetValue {
                // Only create new records when we're marking as known —
                // there's no point creating a record just to store isKnown = false.
                let p = CountryProgress(countryName: country.id)
                p.isKnown = true
                modelContext.insert(p)
            }
        }
    }
}

// ── Row subview ───────────────────────────────────────────────────────────────
// Extracted into its own struct so the List only re-renders the specific row
// that changed, not the entire list.
private struct KnownCountryRow: View {

    let country : Country
    let isKnown : Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.system(size: 34))
                    .frame(width: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(country.capital)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Filled circle = known, empty circle = not known.
                // The animation makes the toggle feel snappy.
                Image(systemName: isKnown ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isKnown ? .green : Color(.systemGray3))
                    .animation(.spring(duration: 0.25), value: isKnown)
            }
            .padding(.vertical, 4)
            // contentShape makes the whole row (including the Spacer) tappable,
            // not just the text or icon.
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
#Preview {
    NavigationStack {
        KnownCountriesView()
    }
    .environmentObject(LanguageManager())
    .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self],
                    inMemory: true)
}
