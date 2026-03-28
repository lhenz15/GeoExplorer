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
import SwiftData

struct ContentView: View {

    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        TabView {

            // ── Tab 1: Home dashboard ──────────────────────────────────────────
            HomeView()
                .tabItem {
                    Label(lang.t("tab.home"), systemImage: "house.fill")
                }

            // ── Tab 2: Country browser ─────────────────────────────────────────
            CountryListView()
                .tabItem {
                    Label(lang.t("tab.explore"), systemImage: "globe")
                }

            // ── Tab 3: Stats dashboard ─────────────────────────────────────────
            StatsView()
                .tabItem {
                    Label(lang.t("tab.stats"), systemImage: "chart.bar.fill")
                }

            // ── Tab 4: Settings ────────────────────────────────────────────────
            SettingsView()
                .tabItem {
                    Label(lang.t("tab.settings"), systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LanguageManager())
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
