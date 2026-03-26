// QuizSession.swift
// GeoExplorer
//
// SwiftData model that records one completed quiz round.
// Every time the user finishes a quiz, one QuizSession row is written to disk.

import SwiftData
import Foundation

@Model
class QuizSession {

    // The five pieces of data we store for each session.
    var date     : Date
    var mode     : String   // QuizMode.rawValue — storing as a String means we
                            // don't need QuizMode itself to be a SwiftData entity.
    var score    : Int
    var total    : Int
    var timeTaken: Double   // seconds from the first question to the Finish tap

    // ── Computed helpers ──────────────────────────────────────────────────────
    // These are calculated in memory each time — they're NOT stored in the db.
    var percentage: Double {
        total > 0 ? Double(score) / Double(total) : 0
    }

    var formattedTime: String {
        let m = Int(timeTaken) / 60
        let s = Int(timeTaken) % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }

    // `date: Date = .now` means the date defaults to right now if not specified.
    init(date: Date = .now, mode: String, score: Int, total: Int, timeTaken: Double) {
        self.date      = date
        self.mode      = mode
        self.score     = score
        self.total     = total
        self.timeTaken = timeTaken
    }
}
