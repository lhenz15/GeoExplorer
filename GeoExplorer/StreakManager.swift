// StreakManager.swift
// GeoExplorer
//
// Manages the daily study streak using UserDefaults.
//
// ── What is UserDefaults? ─────────────────────────────────────────────────────
// UserDefaults is a persistent key-value store built into iOS. Think of it as
// a tiny dictionary that survives app restarts:
//
//   UserDefaults.standard.set(42, forKey: "myNumber")   // write
//   UserDefaults.standard.integer(forKey: "myNumber")   // read → 42
//
// It's ideal for small, simple values like settings or lightweight stats.
// For large structured data (lists of sessions, country records) use SwiftData.
//
// SwiftUI provides `@AppStorage("key")` as a convenient property wrapper that
// reads and writes from UserDefaults — and causes the view to re-render when
// the value changes, just like @State.
//
// StreakManager uses UserDefaults directly (not @AppStorage) because it's
// called from non-view code. StatsView reads the same key via @AppStorage
// and will update automatically when StreakManager writes.

import Foundation

enum StreakManager {

    // These key constants are `internal` so StatsView can reference `streakKey`
    // in its @AppStorage declaration and share the same UserDefaults slot.
    static let  streakKey      = "geoexplorer.currentStreak"
    private static let lastStudyKey  = "geoexplorer.lastStudyDate"
    private static let defaults      = UserDefaults.standard

    // The current streak count (0 if never studied).
    static var currentStreak: Int {
        defaults.integer(forKey: streakKey)
    }

    // Call this at the end of every quiz or flashcard session.
    // Compares today's date with the last study date to decide
    // whether to extend, maintain, or reset the streak.
    static func recordStudySession() {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())    // midnight today

        if let stored = defaults.object(forKey: lastStudyKey) as? Date {
            let lastDay = cal.startOfDay(for: stored)

            // Already studied today — don't change the streak.
            if cal.isDate(lastDay, inSameDayAs: today) { return }

            // How many calendar days since the last session?
            let diff = cal.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if diff == 1 {
                // Studied yesterday → extend.
                defaults.set(currentStreak + 1, forKey: streakKey)
            } else {
                // Skipped one or more days → reset to 1 (today counts).
                defaults.set(1, forKey: streakKey)
            }
        } else {
            // First session ever.
            defaults.set(1, forKey: streakKey)
        }

        // Always update the last-study date so tomorrow's check works.
        defaults.set(today, forKey: lastStudyKey)
    }
}
