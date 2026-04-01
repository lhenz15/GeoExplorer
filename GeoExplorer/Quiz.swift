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
    // Stable English country id — same regardless of active language.
    // Passed to MasteryManager so progress records are always keyed on the
    // English name (= country.id), never on a localised display name.
    let countryId     : String

    // Custom init with `countryId` defaulting to "" so existing preview
    // call sites that omit it continue to compile.
    init(prompt: String, correctAnswer: String, choices: [String], countryId: String = "") {
        self.prompt        = prompt
        self.correctAnswer = correctAnswer
        self.choices       = choices
        self.countryId     = countryId
    }

    static func == (lhs: QuizQuestion, rhs: QuizQuestion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    // ── Question generation ────────────────────────────────────────────────────
    // Shared by QuizSetupView (initial quiz) and QuizResultView (Play Again).
    // `continent` == "all" means no filtering.
    // `count` is clamped to the pool size automatically.
    // `countries` is passed in from LanguageManager so questions use the
    // active language's localised names.
    // `excludedIds` — a set of English country ids (country.id) that must not
    // appear as the *correct* answer.  They can still appear as wrong-answer
    // distractors because `wrongPool` is built from the full `countries` list.
    // Pass an empty set (the default) to disable filtering.
    static func generate(mode: QuizMode, continent: String, count: Int,
                         from countries: [Country],
                         excludedIds: Set<String> = []) -> [QuizQuestion] {
        var pool = continent == "all"
            ? countries
            : countries.filter { $0.continent == continent }

        // Map quiz can only use countries that have polygon shape data.
        // ShapeLoader.shapeNames keys are English country names = country.id.
        if mode == .mapToCountry {
            pool = pool.filter { ShapeLoader.shapeNames.contains($0.id) }
        }

        // Remove countries the user has marked as 'already known' from the
        // answer pool.  They remain in `countries` so they can still be chosen
        // as wrong-answer options — the user needs to recognise all flags, not
        // just the ones they haven't mastered yet.
        if !excludedIds.isEmpty {
            pool = pool.filter { !excludedIds.contains($0.id) }
        }

        let actualCount = count == 0 ? pool.count : min(count, pool.count)
        let slice = Array(pool.shuffled().prefix(actualCount))

        return slice.map { country in
            let prompt    : String
            let correct   : String
            let wrongPool : [String]

            switch mode {
            case .flagToCountry:
                prompt    = country.flag
                correct   = country.name
                wrongPool = countries.filter { $0.name != country.name }.map { $0.name }

            case .countryToFlag:
                prompt    = country.name
                correct   = country.flag
                wrongPool = countries.filter { $0.flag != country.flag }.map { $0.flag }

            case .countryToCapital:
                prompt    = "\(country.flag)  \(country.name)"
                correct   = country.capital
                wrongPool = countries.filter { $0.capital != country.capital }.map { $0.capital }

            case .capitalToCountry:
                prompt    = country.capital
                correct   = country.name
                wrongPool = countries.filter { $0.name != country.name }.map { $0.name }

            case .mapToCountry:
                // prompt = country.id (English) so CountryMapView / ShapeLoader
                // can find the polygon — shapes are keyed on English names.
                // correct = country.name (localised) — what the user picks.
                prompt    = country.id
                correct   = country.name
                wrongPool = countries.filter { $0.name != country.name }.map { $0.name }
            }

            let wrongs  = Array(wrongPool.shuffled().prefix(3))
            let choices = ([correct] + wrongs).shuffled()

            return QuizQuestion(
                prompt       : prompt,
                correctAnswer: correct,
                choices      : choices,
                countryId    : country.id
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
