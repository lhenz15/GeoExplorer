// AppearanceManager.swift
// GeoExplorer
//
// Manages the user's preferred colour scheme (System / Light / Dark) and
// exposes it as a ColorScheme? so the root view can apply it with
// .preferredColorScheme(_:).
//
// ── How .preferredColorScheme works ──────────────────────────────────────────
// Every SwiftUI view tree has an *environment* — a bag of values (colour
// scheme, font size, locale, etc.) that flows automatically from parent to
// every descendant.  One of those values is the active colour scheme.
//
// By default SwiftUI reads the colour scheme from iOS itself (the user's
// system setting in the Control Centre / Settings → Display & Brightness).
// You can *override* that for a view and all its descendants with:
//
//   ContentView()
//       .preferredColorScheme(.dark)   // forces dark everywhere
//       .preferredColorScheme(.light)  // forces light everywhere
//       .preferredColorScheme(nil)     // defer to the device setting (default)
//
// Because we attach the modifier to ContentView — the very root of the app —
// the chosen scheme applies to *every* screen at once.  When the user changes
// the setting, AppearanceManager publishes the new value, SwiftUI re-evaluates
// the modifier, and the whole app re-renders in the new scheme instantly.
//
// ── Why ColorScheme? (optional) not ColorScheme ───────────────────────────────
// .preferredColorScheme accepts a ColorScheme? — the question mark means it
// can be nil.  nil is the "I don't care, follow the device" value.  Passing
// .light or .dark overrides the device.  We model the three states as a plain
// String ("system" / "light" / "dark") stored in UserDefaults, then convert to
// ColorScheme? at the point of use.

import SwiftUI
import Combine

// ── Appearance options ────────────────────────────────────────────────────────
// A simple enum so we get exhaustive switch statements and avoid raw strings
// in the view layer.
enum AppAppearance: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    /// The ColorScheme? value that .preferredColorScheme expects.
    /// nil tells SwiftUI "follow the device" — which is exactly what
    /// System mode should do.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil    // no override → device decides
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// ── AppearanceManager ─────────────────────────────────────────────────────────
final class AppearanceManager: ObservableObject {

    static let key = "appAppearance"

    // @Published makes SwiftUI automatically re-render any view that reads
    // this property whenever it changes — just like lang.currentLanguage.
    @Published private(set) var current: AppAppearance

    init() {
        // Restore the saved preference, or default to System.
        let saved = UserDefaults.standard.string(forKey: Self.key) ?? "system"
        current = AppAppearance(rawValue: saved) ?? .system
    }

    /// Call this from the appearance picker buttons in SettingsView.
    func setAppearance(_ appearance: AppAppearance) {
        guard appearance != current else { return }
        current = appearance
        UserDefaults.standard.set(appearance.rawValue, forKey: Self.key)
    }

    /// Convenience shortcut for the .preferredColorScheme modifier.
    var colorScheme: ColorScheme? { current.colorScheme }
}
