// Flashcard.swift
// GeoExplorer
//
// Shared types used across all three flashcard screens.

import Foundation

// ── The data for one card ────────────────────────────────────────────────────

// `Hashable` is needed so we can put [Flashcard] inside a `FlashcardRoute`
// enum and use it with NavigationStack's programmatic navigation.
struct Flashcard: Identifiable, Hashable {
    // Auto-generated UUID — not from JSON, just a runtime identity.
    let id = UUID()
    let question: String   // shown on the front of the card
    let answer: String     // revealed when the card is flipped

    // Custom Hashable: we only care about identity, not content equality.
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
