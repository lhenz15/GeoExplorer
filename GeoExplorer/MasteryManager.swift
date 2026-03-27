// MasteryManager.swift
// GeoExplorer
//
// All mastery logic lives here so QuizView only needs to call two methods.
//
//   recordAnswer(countryName:mode:isCorrect:in:)
//     ── called once per answered question, including timer timeouts.
//     ── sets the per-session correct/wrong flags on the right ModeProgress.
//     ── if the mode is already mastered and this is a wrong answer, may
//        revoke the badge immediately (3 wrongs after mastery = demotion).
//
//   finishSession(for:mode:in:)
//     ── called once when the whole quiz ends.
//     ── awards a session credit to every country that passed the "clean
//        session" test (correct ≥1, wrong = 0, not yet mastered).
//     ── resets the per-session flags so the next quiz starts clean.
//
// ── Why ModelContext as a parameter? ─────────────────────────────────────────
// ModelContext is SwiftData's write channel.  Views receive it through
// @Environment(\.modelContext).  Passing it in as a parameter lets
// MasteryManager do SwiftData work from non-view code without holding a
// stored reference (which can cause threading problems).
//
// ── Why FetchDescriptor instead of @Query? ────────────────────────────────────
// @Query is a SwiftUI property wrapper — it lives on a view and stays live.
// FetchDescriptor is a one-shot query you run manually: perfect for helper
// code that runs outside the SwiftUI view hierarchy.

import Foundation
import SwiftData

enum MasteryManager {

    // ── Per-answer update ─────────────────────────────────────────────────────
    static func recordAnswer(
        countryName : String,
        mode        : QuizMode,
        isCorrect   : Bool,
        in context  : ModelContext
    ) {
        guard !countryName.isEmpty else { return }

        let record = fetchOrCreate(countryName, in: context)
        var mp = record.modeProgress(for: mode)

        if isCorrect {
            // Mark "at least one correct answer this session."
            mp.correctThisSession = true
        } else {
            // Mark "at least one wrong answer this session."
            mp.wrongThisSession = true

            // ── Mastery demotion ──────────────────────────────────────────────
            // Only runs when the badge has already been earned.
            // Accumulate wrong answers; at 3 the badge is revoked.
            // sessionCredits is set back to 2 so the user only needs one
            // more clean session to re-earn mastery (rather than starting
            // from 0, which would feel too punishing).
            if mp.isMastered {
                mp.wrongAnswersAfterMastery += 1
                if mp.wrongAnswersAfterMastery >= 3 {
                    mp.isMastered               = false
                    mp.sessionCredits           = 2
                    mp.wrongAnswersAfterMastery = 0
                }
            }
        }

        record.setModeProgress(mp, for: mode)
    }

    // ── End-of-session credit award ───────────────────────────────────────────
    static func finishSession(
        for countryNames : [String],
        mode             : QuizMode,
        in context       : ModelContext
    ) {
        // Deduplicate: a country might appear in multiple questions.
        // Using a Set processes each country name exactly once.
        //
        // ── What is Set? ──────────────────────────────────────────────────────
        // A Set is like an Array but without duplicates and with no guaranteed
        // order.  `Set(array)` builds one in one step, dropping any repeat values.
        // It's ideal here because we only need "which countries were in this quiz",
        // not "how many times each appeared".
        let unique = Set(countryNames.filter { !$0.isEmpty })

        for name in unique {
            let record = fetchOrCreate(name, in: context)
            var mp = record.modeProgress(for: mode)

            // Award a credit if ALL three conditions are met:
            //   1. at least one correct answer this session
            //   2. zero wrong answers this session
            //   3. not already mastered in this mode (no credit overflow)
            if mp.correctThisSession && !mp.wrongThisSession && !mp.isMastered {
                mp.sessionCredits = min(mp.sessionCredits + 1, 3)

                if mp.sessionCredits >= 3 {
                    mp.isMastered               = true
                    mp.wrongAnswersAfterMastery = 0   // start demotion counter fresh
                }
            }

            // Always reset session flags — the next quiz must start clean.
            mp.correctThisSession = false
            mp.wrongThisSession   = false

            record.setModeProgress(mp, for: mode)
        }
    }

    // ── Private helper ────────────────────────────────────────────────────────
    // Looks up an existing CountryProgress row by name, or creates a new one.
    // Equivalent to SQL "SELECT … WHERE name = ? LIMIT 1; INSERT IF NOT FOUND".
    //
    // ── FetchDescriptor + #Predicate ─────────────────────────────────────────
    // FetchDescriptor<T>(predicate:) describes a query to run against the store.
    // #Predicate { } is a macro that turns a Swift closure into a type-safe
    // database filter — like WHERE in SQL but checked by the compiler.
    private static func fetchOrCreate(
        _ countryName : String,
        in context    : ModelContext
    ) -> CountryProgress {
        let descriptor = FetchDescriptor<CountryProgress>(
            predicate: #Predicate { $0.countryName == countryName }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let new = CountryProgress(countryName: countryName)
        context.insert(new)
        return new
    }
}
