// ContentView.swift
// GeoExplorer
//
// The root view. Now hosts a TabView with two tabs:
//   1. Countries — the browseable country list
//   2. Flashcards — the study mode
//
// New concept: TabView
//   A `TabView` renders a tab bar at the bottom of the screen.
//   Each child view becomes one tab. `.tabItem` provides the icon and label.
//   SwiftUI keeps each tab's navigation state independent — switching tabs
//   doesn't reset the other tab's position in the stack.

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {

            // ── Tab 1: Country browser ─────────────────────────────────────
            CountryListView()
                .tabItem {
                    Label("Countries", systemImage: "globe")
                }

            // ── Tab 2: Flashcard study mode ────────────────────────────────
            FlashcardSetupView()
                .tabItem {
                    Label("Flashcards", systemImage: "rectangle.stack")
                }
        }
    }
}

#Preview {
    ContentView()
}
