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
    case mapToCountry     = "Map → Country"
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

    // ── Question generation ────────────────────────────────────────────────────
    // Shared by QuizSetupView (initial quiz) and QuizResultView (Play Again).
    // `continent` == "All" means no filtering.
    // `count` is clamped to the pool size automatically.
    static func generate(mode: QuizMode, continent: String, count: Int) -> [QuizQuestion] {
        let allCountries = DataLoader.loadCountries()
        var pool = continent == "All"
            ? allCountries
            : allCountries.filter { $0.continent == continent }

        // Map quiz can only use countries that have polygon shape data.
        // ShapeLoader.shapeNames is a Set<String> so the lookup is O(1).
        if mode == .mapToCountry {
            pool = pool.filter { ShapeLoader.shapeNames.contains($0.name) }
        }

        let actualCount = min(count, pool.count)
        let slice = Array(pool.shuffled().prefix(actualCount))

        return slice.map { country in
            let prompt    : String
            let correct   : String
            let wrongPool : [String]

            switch mode {
            case .flagToCountry:
                prompt    = country.flag
                correct   = country.name
                wrongPool = allCountries.filter { $0.name != country.name }.map { $0.name }

            case .countryToFlag:
                prompt    = country.name
                correct   = country.flag
                wrongPool = allCountries.filter { $0.flag != country.flag }.map { $0.flag }

            case .countryToCapital:
                prompt    = "\(country.flag)  \(country.name)"
                correct   = country.capital
                wrongPool = allCountries.filter { $0.capital != country.capital }.map { $0.capital }

            case .capitalToCountry:
                prompt    = country.capital
                correct   = country.name
                wrongPool = allCountries.filter { $0.name != country.name }.map { $0.name }

            case .mapToCountry:
                // prompt = country name so MapQuizView can look up the shape.
                // correct = country name (the answer the user picks).
                // wrong answers are other country names from the full pool.
                prompt    = country.name
                correct   = country.name
                wrongPool = allCountries.filter { $0.name != country.name }.map { $0.name }
            }

            let wrongs  = Array(wrongPool.shuffled().prefix(3))
            let choices = ([correct] + wrongs).shuffled()

            return QuizQuestion(
                prompt       : prompt,
                correctAnswer: correct,
                choices      : choices,
                countryName  : country.name
            )
        }
    }
}

// ── Navigation routes ─────────────────────────────────────────────────────────
// `.quiz` now carries the mode alongside the questions so QuizView and
// QuizResultView can save sessions with the correct mode label.
// `.results` carries `continent` and `questionCount` so Play Again can
// generate a completely fresh batch without going back to setup.
enum QuizRoute: Hashable {
    case quiz(mode: QuizMode, questions: [QuizQuestion])
    case results(score: Int, total: Int, mode: QuizMode, questions: [QuizQuestion],
                 continent: String, questionCount: Int)
}
