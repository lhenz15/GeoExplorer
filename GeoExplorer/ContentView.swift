// ContentView.swift
// GeoExplorer
//
// The root view. Hosts a TabView with four tabs:
//   1. Countries  — the browseable country list
//   2. Favourites — countries the user has hearted
//   3. Flashcards — the study mode
//   4. Quiz       — multiple choice quiz with timer

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {

            // ── Tab 1: Country browser ─────────────────────────────────────
            CountryListView()
                .tabItem {
                    Label("Countries", systemImage: "globe")
                }

            // ── Tab 2: Favourites ──────────────────────────────────────────
            FavoritesView()
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }

            // ── Tab 3: Flashcard study mode ────────────────────────────────
            FlashcardSetupView()
                .tabItem {
                    Label("Flashcards", systemImage: "rectangle.stack")
                }

            // ── Tab 4: Multiple choice quiz ────────────────────────────────
            QuizSetupView()
                .tabItem {
                    Label("Quiz", systemImage: "checkmark.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
