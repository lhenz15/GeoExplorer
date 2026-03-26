// GeoExplorerApp.swift
// GeoExplorer
//
// The app entry point. `@main` tells Swift "start here."
//
// New concept: .modelContainer
//   `.modelContainer(for:)` is the one-time setup call that creates (or opens)
//   the SwiftData SQLite database on the device. Passing `FavoriteCountry.self`
//   tells SwiftData which @Model types to include.
//
//   Once attached here, every view in the app can:
//     • Read data via @Query
//     • Write data via @Environment(\.modelContext)
//   — without any extra plumbing. The container flows down automatically
//   through SwiftUI's environment, just like colour schemes or font sizes.

import SwiftUI
import SwiftData

@main
struct GeoExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Creates the SQLite database file in the app's private storage.
        // This call runs once at launch; subsequent launches open the
        // existing file so favourites survive app restarts.
        .modelContainer(for: FavoriteCountry.self)
    }
}
