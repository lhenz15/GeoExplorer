// Quiz.swift
// GeoExplorer
//
// Shared data types for the Multiple Choice Quiz feature.
// Mirrors the structure of Flashcard.swift — a model file, a mode enum,
// and a route enum for programmatic navigation.

import Foundation

// ── Quiz modes ────────────────────────────────────────────────────────────────
// `CaseIterable` lets us write `QuizMode.allCases` to get every option in
// a ForEach — the same trick used in FlashcardMode.
enum QuizMode: String, CaseIterable {
    case flagToCountry    = "Flag → Country"
    case countryToFlag    = "Country → Flag"
    case countryToCapital = "Country → Capital"
    case capitalToCountry = "Capital → Country"
}

// ── A single quiz question ─────────────────────────────────────────────────────
struct QuizQuestion: Identifiable, Hashable {

    let id            = UUID()
    let prompt        : String   // what the user sees as the question
    let correctAnswer : String
    let choices       : [String] // exactly 4 options (1 correct + 3 wrong), pre-shuffled

    // Manual Hashable — we only care about identity, not content.
    // Same pattern used in Flashcard.swift.
    static func == (lhs: QuizQuestion, rhs: QuizQuestion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// ── Navigation routes ─────────────────────────────────────────────────────────
// Used as the typed path array in QuizSetupView's NavigationStack.
//
// .quiz([QuizQuestion])                    → show QuizView
// .results(score:total:questions:)         → show QuizResultView
//
// Both associated values are Hashable, so Swift synthesises Hashable for free.
enum QuizRoute: Hashable {
    case quiz([QuizQuestion])
    case results(score: Int, total: Int, questions: [QuizQuestion])
}
