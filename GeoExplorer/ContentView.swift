// ContentView.swift
// GeoExplorer
//
// The root view. Hosts a TabView with four tabs:
//   1. Home     — personal dashboard (HomeView)
//   2. Explore  — the browseable country list (CountryListView)
//   3. Stats    — streak, mastery, personal bests, history (StatsView)
//   4. Settings — notifications and reset progress (SettingsView)
//
// Flashcards, Quiz, and Favourites are no longer tabs — they are accessed
// by tapping their feature cards on the Home dashboard.

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {

            // ── Tab 1: Home dashboard ──────────────────────────────────────────
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // ── Tab 2: Country browser ─────────────────────────────────────────
            CountryListView()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }

            // ── Tab 3: Stats dashboard ─────────────────────────────────────────
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            // ── Tab 4: Settings ────────────────────────────────────────────────
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
