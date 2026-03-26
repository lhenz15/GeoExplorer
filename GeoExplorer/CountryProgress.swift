// CountryProgress.swift
// GeoExplorer
//
// SwiftData model that tracks how many times a country has been
// answered correctly across all quiz and flashcard sessions.
// A country is "mastered" once it reaches 3 correct answers.

import SwiftData

@Model
class CountryProgress {

    var countryName : String
    var correctCount: Int

    // Computed — not stored. A country is mastered after 3 correct answers.
    var isMastered: Bool { correctCount >= 3 }

    init(countryName: String, correctCount: Int = 0) {
        self.countryName  = countryName
        self.correctCount = correctCount
    }
}
