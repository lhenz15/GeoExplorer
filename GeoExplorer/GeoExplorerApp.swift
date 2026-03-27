// GeoExplorerApp.swift
// GeoExplorer
//
// App entry point. Configures the SwiftData container and requests
// notification permission on first launch.

import SwiftUI
import SwiftData

@main
struct GeoExplorerApp: App {

    // ── Language manager ──────────────────────────────────────────────────────
    // @StateObject creates and *owns* the LanguageManager. It is created once
    // here at the root and injected into every child view via .environmentObject.
    // Child views receive it with @EnvironmentObject — they share this same instance.
    @StateObject private var lang = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the shared LanguageManager into the environment so
                // every descendant view can access it with @EnvironmentObject.
                .environmentObject(lang)
                // Set the accent colour for every tintable control in the app
                // (buttons, toggles, progress bars, segmented pickers, etc.).
                // Any view using .borderedProminent or .tint(.accentColor)
                // automatically picks up AppColors.accent in both light/dark mode.
                .tint(AppColors.accent)
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
