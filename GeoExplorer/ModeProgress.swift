// ModeProgress.swift
// GeoExplorer
//
// A Codable struct that holds mastery data for ONE quiz mode for ONE country.
// It is stored as a SwiftData attribute inside CountryProgress.
//
// ── What is a Codable struct? ─────────────────────────────────────────────────
// Codable is two protocols fused together: Encodable (Swift → bytes) and
// Decodable (bytes → Swift).  Adding `: Codable` to a struct whose properties
// are all basic types (Int, Bool, String…) gives you the conversion for free —
// Swift writes all the implementation automatically.
//
// SwiftData stores every Codable attribute as JSON inside its SQLite file, so
// all five fields below are persisted to disk without any extra code from you.
//
// ── Why a struct instead of five separate Int/Bool properties? ────────────────
// Grouping related state into its own type communicates "these five things
// belong together — they describe one mode's mastery state."  It also lets
// CountryProgress hold four clean properties (one per mode) instead of twenty
// scattered ones, and lets MasteryManager work with a single value at a time.

import Foundation

struct ModeProgress: Codable {

    // ── Credits ───────────────────────────────────────────────────────────────
    // Counts "clean sessions" earned toward mastery.
    // Clean session = at least one correct answer AND zero wrong answers.
    // 0–2 = still working toward mastery.  Reaching 3 awards the badge.
    var sessionCredits: Int = 0

    // ── Mastery badge ─────────────────────────────────────────────────────────
    // Set to true when sessionCredits reaches 3.
    // Once mastered, credits stop incrementing — the badge persists until
    // wrongAnswersAfterMastery accumulates to 3.
    var isMastered: Bool = false

    // ── Demotion counter ──────────────────────────────────────────────────────
    // Tracks wrong answers that occur AFTER mastery is earned.
    // At 3 wrong answers: mastery is removed and this resets to 0.
    var wrongAnswersAfterMastery: Int = 0

    // ── Per-session flags ─────────────────────────────────────────────────────
    // Both are reset to false at the end of every quiz session.
    // MasteryManager uses them to decide whether to award a credit that session.
    var correctThisSession: Bool = false   // true if ≥1 correct answer this session
    var wrongThisSession:   Bool = false   // true if ≥1 wrong  answer this session
}
