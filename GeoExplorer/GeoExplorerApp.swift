// GeoExplorerApp.swift
// GeoExplorer
//
// App entry point. Configures the SwiftData container and requests
// notification permission on first launch.

import SwiftUI
import SwiftData

@main
struct GeoExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Request notification permission on first launch.
                // iOS shows the system dialog only once — subsequent calls
                // are silent and just check the stored decision.
                .task {
                    NotificationManager.requestPermission { _ in }
                }
        }
        // Register all three @Model types with the container.
        // Passing an array lets SwiftData create all their tables in one file.
        .modelContainer(for: [
            FavoriteCountry.self,
            QuizSession.self,
            CountryProgress.self,
        ])
    }
}
