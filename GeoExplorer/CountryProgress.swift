// CountryProgress.swift
// GeoExplorer
//
// SwiftData model tracking mastery for a single country across all four
// quiz modes.  Each mode is stored as a ModeProgress Codable struct so the
// database row stays compact while the logic in ModeProgress stays grouped.
//
// ── Schema migration note ─────────────────────────────────────────────────────
// This version replaces the earlier model that had a single `correctCount` Int.
// The schema has changed significantly, so you must delete the app from the
// simulator / device before your first build to let SwiftData start fresh.
// In Xcode: Product → Clean Build Folder, then delete the app, then run.
//
// ── How SwiftData stores Codable structs ──────────────────────────────────────
// Any property whose type conforms to Codable is automatically serialised to
// JSON inside SwiftData's SQLite file.  You don't need @Attribute, a custom
// transformer, or any extra code — just declare the property normally.
//
// ── Gold badge threshold ──────────────────────────────────────────────────────
// A country earns ⭐ once mastered in at least 2 of the 4 modes.
// Why 2-of-4?  It rewards real breadth (you know the flag AND the capital)
// without demanding perfect coverage of every possible mode.

import SwiftData

@Model
class CountryProgress {

    var countryName      : String

    // One ModeProgress value per quiz mode.
    // SwiftData serialises each Codable struct automatically.
    var flagToCountry    : ModeProgress
    var countryToFlag    : ModeProgress
    var countryToCapital : ModeProgress
    var capitalToCountry : ModeProgress

    // ── Gold badge ────────────────────────────────────────────────────────────
    // Computed — not stored in the database.
    // Collecting the four structs in an array lets us use `.filter` and
    // `.count` in one line instead of writing out four separate `if` checks.
    var hasGoldBadge: Bool {
        [flagToCountry, countryToFlag, countryToCapital, capitalToCountry]
            .filter { $0.isMastered }
            .count >= 2
    }

    init(countryName: String) {
        self.countryName     = countryName
        // Every mode starts from scratch — zero credits, not mastered.
        self.flagToCountry    = ModeProgress()
        self.countryToFlag    = ModeProgress()
        self.countryToCapital = ModeProgress()
        self.capitalToCountry = ModeProgress()
    }

    // ── Mode accessors ────────────────────────────────────────────────────────
    // These two helpers let MasteryManager work with a single QuizMode value
    // instead of repeating switch statements everywhere.

    /// Returns a **copy** of the ModeProgress struct for the given mode.
    /// Modifying the copy does NOT affect the stored data — call setModeProgress
    /// afterwards to write the updated value back.
    func modeProgress(for mode: QuizMode) -> ModeProgress {
        switch mode {
        case .flagToCountry:    return flagToCountry
        case .countryToFlag:    return countryToFlag
        case .countryToCapital: return countryToCapital
        case .capitalToCountry: return capitalToCountry
        }
    }

    /// Replaces the stored ModeProgress struct for the given mode.
    /// Assigning a new struct value triggers SwiftData's change tracking,
    /// so the update is automatically written to disk on the next save cycle.
    func setModeProgress(_ mp: ModeProgress, for mode: QuizMode) {
        switch mode {
        case .flagToCountry:    flagToCountry    = mp
        case .countryToFlag:    countryToFlag    = mp
        case .countryToCapital: countryToCapital = mp
        case .capitalToCountry: capitalToCountry = mp
        }
    }
}
