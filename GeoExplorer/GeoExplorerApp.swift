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
    @StateObject private var lang       = LanguageManager()

    // ── Appearance manager ────────────────────────────────────────────────────
    // Owns the colour-scheme preference.  We read appearance.colorScheme below
    // and pass it to .preferredColorScheme — nil means "follow the device",
    // .light or .dark overrides it for the entire view tree.
    @StateObject private var appearance = AppearanceManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the shared LanguageManager into the environment so
                // every descendant view can access it with @EnvironmentObject.
                .environmentObject(lang)
                // Inject AppearanceManager so SettingsView can call
                // appearance.setAppearance(_:) without needing a direct reference.
                .environmentObject(appearance)
                // ── The key modifier ─────────────────────────────────────────
                // .preferredColorScheme overrides the colour scheme for
                // ContentView and every view inside it (i.e. the whole app).
                // When appearance.colorScheme is nil the device setting is used.
                // When it is .light or .dark that scheme is forced regardless of
                // what the user has set in iOS Settings.
                // Because appearance is @Published, this line re-evaluates
                // automatically the moment the user taps a new option.
                .preferredColorScheme(appearance.colorScheme)
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
