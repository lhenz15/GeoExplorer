// CountryProgress.swift
// GeoExplorer
//
// SwiftData model tracking mastery for a single country across all five
// quiz modes.  Each mode is stored as a ModeProgress Codable struct so the
// database row stays compact while the logic in ModeProgress stays grouped.
//
// ── Schema migration note ─────────────────────────────────────────────────────
// This version replaces the earlier model that had a single `correctCount` Int.
// The schema has changed significantly, so you must delete the app from the
// simulator / device before your first build to let SwiftData start fresh.
// In Xcode: Product → Clean Build Folder, then delete the app, then run.
//
// Adding `isKnown: Bool = false` is a lightweight migration — SwiftData reads
// the default value (false) for any existing row that doesn't have the column
// yet, so you do NOT need to wipe the database for this particular change.
//
// ── How SwiftData stores Codable structs ──────────────────────────────────────
// Any property whose type conforms to Codable is automatically serialised to
// JSON inside SwiftData's SQLite file.  You don't need @Attribute, a custom
// transformer, or any extra code — just declare the property normally.
//
// ── Gold badge threshold ──────────────────────────────────────────────────────
// A country earns ⭐ once mastered in at least 3 of the 5 modes.
// This requires solid coverage: flag recognition, capital knowledge, and
// at least one direction of the country ↔ capital association.

import SwiftData

@Model
class CountryProgress {

    var countryName      : String

    // ── Already Known flag ────────────────────────────────────────────────────
    // A manual user override — completely separate from the mastery system.
    // When true the user has said "I already know this country", which means:
    //   • A green ✓ badge is shown in the country list and detail view.
    //   • When 'Exclude known countries from quizzes' is on in Settings the
    //     country is skipped as a *correct answer* in all quiz modes (it can
    //     still appear as a wrong-answer distractor).
    // Default is false — every country starts as unknown.
    var isKnown: Bool = false

    // One ModeProgress value per quiz mode.
    // SwiftData serialises each Codable struct automatically.
    var flagToCountry    : ModeProgress
    var countryToFlag    : ModeProgress
    var countryToCapital : ModeProgress
    var capitalToCountry : ModeProgress
    var mapToCountry     : ModeProgress

    // ── Gold badge ────────────────────────────────────────────────────────────
    // Computed — not stored in the database.
    // Now requires mastery in 3 of 5 modes (raised from 2 of 4) to reflect
    // the broader range of skills tested by the new Map → Country mode.
    var hasGoldBadge: Bool {
        [flagToCountry, countryToFlag, countryToCapital, capitalToCountry, mapToCountry]
            .filter { $0.isMastered }
            .count >= 3
    }

    init(countryName: String) {
        self.countryName      = countryName
        // Every mode starts from scratch — zero credits, not mastered.
        self.flagToCountry    = ModeProgress()
        self.countryToFlag    = ModeProgress()
        self.countryToCapital = ModeProgress()
        self.capitalToCountry = ModeProgress()
        self.mapToCountry     = ModeProgress()
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
        case .mapToCountry:     return mapToCountry
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
        case .mapToCountry:     mapToCountry     = mp
        }
    }
}
