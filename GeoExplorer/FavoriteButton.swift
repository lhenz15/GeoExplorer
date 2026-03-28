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

    // The stable English country id (= country.id) for this button.
    // FavoriteCountry.name stores the same English id, so matching is stable
    // across language switches — a country favourited in Spanish is still
    // recognised when the app restarts in English.
    let countryId: String

    // ── SwiftData wiring ──────────────────────────────────────────────────────
    @Query private var favorites: [FavoriteCountry]
    @Environment(\.modelContext) private var modelContext

    // ── Derived state ─────────────────────────────────────────────────────────
    private var isFavorited: Bool {
        favorites.contains { $0.name == countryId }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        Button {
            toggleFavorite()
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .foregroundStyle(isFavorited ? .red : .secondary)
                .imageScale(.large)
                .animation(.spring(duration: 0.25), value: isFavorited)
        }
        .buttonStyle(.plain)
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.name == countryId }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteCountry(name: countryId))
        }
    }
}
