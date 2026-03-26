// Quiz.swift
// GeoExplorer
//
// Shared data types for the Multiple Choice Quiz feature.

import Foundation

// ── Quiz modes ────────────────────────────────────────────────────────────────
enum QuizMode: String, CaseIterable {
    case flagToCountry    = "Flag → Country"
    case countryToFlag    = "Country → Flag"
    case countryToCapital = "Country → Capital"
    case capitalToCountry = "Capital → Country"
}

// ── A single quiz question ─────────────────────────────────────────────────────
struct QuizQuestion: Identifiable, Hashable {

    let id            = UUID()
    let prompt        : String
    let correctAnswer : String
    let choices       : [String]
    // The country name is stored separately so progress tracking always
    // has a consistent key — regardless of what the prompt or answer shows.
    let countryName   : String

    // Custom init with `countryName` defaulting to "" so existing preview
    // call sites that omit it continue to compile.
    init(prompt: String, correctAnswer: String, choices: [String], countryName: String = "") {
        self.prompt        = prompt
        self.correctAnswer = correctAnswer
        self.choices       = choices
        self.countryName   = countryName
    }

    static func == (lhs: QuizQuestion, rhs: QuizQuestion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// ── Navigation routes ─────────────────────────────────────────────────────────
// `.quiz` now carries the mode alongside the questions so QuizView and
// QuizResultView can save sessions with the correct mode label.
enum QuizRoute: Hashable {
    case quiz(mode: QuizMode, questions: [QuizQuestion])
    case results(score: Int, total: Int, mode: QuizMode, questions: [QuizQuestion])
}
