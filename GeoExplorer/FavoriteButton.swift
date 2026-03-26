// FavoriteButton.swift
// GeoExplorer
//
// A self-contained heart button used in both CountryListView rows
// and CountryDetailView's toolbar.
//
// Because it owns its own @Query and @Environment, each instance knows
// whether *its* country is favourited and can toggle it — no extra code
// needed in the parent view.

import SwiftUI
import SwiftData

struct FavoriteButton: View {

    // The name of the country this button represents.
    // We use name as the unique key to match against stored FavoriteCountry rows.
    let countryName: String

    // ── SwiftData wiring ──────────────────────────────────────────────────────

    // `@Query` fetches every FavoriteCountry row from the database and
    // keeps `favorites` live. Whenever a row is inserted or deleted anywhere
    // in the app, SwiftUI automatically re-renders this view.
    //
    // Important: @Query is read-only. To write to the database you need
    // modelContext (below).
    @Query private var favorites: [FavoriteCountry]

    // `modelContext` is the environment object SwiftData injects into every
    // view once `.modelContainer` is set on the App. It's the "write channel":
    //   • modelContext.insert(object)  → adds a new row
    //   • modelContext.delete(object)  → removes a row
    // SwiftData saves changes automatically — no manual "save" call needed.
    @Environment(\.modelContext) private var modelContext

    // ── Derived state ─────────────────────────────────────────────────────────

    // Check whether this country's name exists in the persisted list.
    private var isFavorited: Bool {
        favorites.contains { $0.name == countryName }
    }

    // ── Body ──────────────────────────────────────────────────────────────────

    var body: some View {
        Button {
            toggleFavorite()
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .foregroundStyle(isFavorited ? .red : .secondary)
                .imageScale(.large)
                // Animate the fill/unfill transition smoothly.
                .animation(.spring(duration: 0.25), value: isFavorited)
        }
        // `.plain` stops the tap from "bleeding through" to the NavigationLink
        // behind it — the heart tap favourites, everything else navigates.
        .buttonStyle(.plain)
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.name == countryName }) {
            // Already saved — remove it from the database.
            modelContext.delete(existing)
        } else {
            // Not saved yet — create a new row.
            modelContext.insert(FavoriteCountry(name: countryName))
        }
    }
}
