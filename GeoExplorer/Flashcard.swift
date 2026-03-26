// Flashcard.swift
// GeoExplorer
//
// Shared types used across all three flashcard screens.

import Foundation

// ── The data for one card ────────────────────────────────────────────────────

// `Hashable` is needed so we can put [Flashcard] inside a `FlashcardRoute`
// enum and use it with NavigationStack's programmatic navigation.
struct Flashcard: Identifiable, Hashable {
    let id          = UUID()
    let question    : String
    let answer      : String
    // Always the country name regardless of study mode — used by FlashcardView
    // to update CountryProgress when the session finishes.
    // Defaults to "" so existing preview call sites compile unchanged.
    let countryName : String

    init(question: String, answer: String, countryName: String = "") {
        self.question    = question
        self.answer      = answer
        self.countryName = countryName
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Flashcard, rhs: Flashcard) -> Bool { lhs.id == rhs.id }
}

// ── What is being tested ─────────────────────────────────────────────────────

// `CaseIterable` lets us write `FlashcardMode.allCases` to get both options
// automatically — useful for building a Picker without hardcoding the list.
enum FlashcardMode: String, CaseIterable {
    case flagToCountry    = "Flag Quiz"      // show flag → guess country name
    case countryToCapital = "Capital Quiz"   // show country → guess capital
}

// ── Programmatic navigation route ────────────────────────────────────────────
// Instead of wrapping every screen in a NavigationLink, we push values onto
// a [FlashcardRoute] array. SwiftUI's NavigationStack watches the array and
// shows the right screen for each value.
//
// `Hashable` is required by NavigationStack for typed navigation.
enum FlashcardRoute: Hashable {
    case session([Flashcard])                            // the study session
    case results(cardCount: Int, cards: [Flashcard])    // end-of-session summary
}
