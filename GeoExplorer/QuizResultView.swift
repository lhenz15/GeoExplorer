// QuizResultView.swift
// GeoExplorer
//
// Screen 3: shown after all questions are answered.
// Displays the final score and offers Play Again or Back to Setup.

import SwiftUI
import SwiftData

struct QuizResultView: View {

    let score        : Int
    let total        : Int
    let mode         : QuizMode
    let questions    : [QuizQuestion]
    let continent    : String
    let questionCount: Int
    let answerMode   : AnswerMode
    @Binding var path: [QuizRoute]

    @EnvironmentObject var lang: LanguageManager

    // ── Known-countries filtering (mirrors QuizSetupView) ─────────────────────
    @Query private var allProgress: [CountryProgress]
    @AppStorage("excludeKnownCountries") private var excludeKnownCountries = false

    private var knownIds: Set<String> {
        guard excludeKnownCountries else { return [] }
        return Set(allProgress.filter { $0.isKnown }.map { $0.countryName })
    }

    // ── Derived values ────────────────────────────────────────────────────────
    private var percentage: Double  { total > 0 ? Double(score) / Double(total) : 0 }
    private var percentText: String { "\(Int(percentage * 100))%" }

    private var resultEmoji: String {
        switch percentage {
        case 0.9...: return "🏆"
        case 0.7...: return "⭐️"
        case 0.5...: return "👍"
        default:     return "📚"
        }
    }

    private var resultMessage: String {
        switch percentage {
        case 0.9...: return lang.t("quiz.result.outstanding")
        case 0.7...: return lang.t("quiz.result.great")
        case 0.5...: return lang.t("quiz.result.good")
        default:     return lang.t("quiz.result.keep")
        }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        ZStack {
        VStack(spacing: 0) {

            Spacer()

            // ── Score display ──────────────────────────────────────────────
            VStack(spacing: 16) {

                Text(resultEmoji)
                    .font(.system(size: 80))
                    .shadow(color: .black.opacity(0.1), radius: 8)

                VStack(spacing: 6) {
                    Text(resultMessage)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("\(score) / \(total)")
                        .font(.system(size: 60, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text("\(percentText) \(lang.t("quiz.result.percentCorrect"))")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // ── Stat pills ─────────────────────────────────────────────────
            HStack(spacing: 32) {
                statPill(value: "\(score)",         label: lang.t("quiz.result.correct"),  icon: "checkmark.circle.fill", color: .green)
                statPill(value: "\(total - score)", label: lang.t("quiz.result.wrong"),    icon: "xmark.circle.fill",     color: .red)
                statPill(value: percentText,        label: lang.t("quiz.result.score"),    icon: "percent",               color: .blue)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            Spacer()

            // ── Action buttons ─────────────────────────────────────────────
            VStack(spacing: 12) {

                Button {
                    let freshQuestions = QuizQuestion.generate(
                        mode       : mode,
                        continent  : continent,
                        count      : questionCount,
                        from       : lang.countries,
                        excludedIds: knownIds
                    )
                    path = [.quiz(mode: mode, questions: freshQuestions, answerMode: answerMode)]
                } label: {
                    Label(lang.t("quiz.result.playAgain"), systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .scaleOnPress()

                Button {
                    path = []
                } label: {
                    Label(lang.t("quiz.result.backSetup"), systemImage: "house")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .scaleOnPress()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .screenAppear()

        if percentage >= 0.7 {
            ConfettiView()
        }

        } // end ZStack
        .navigationTitle(lang.t("quiz.result.title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }

    private func statPill(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
#Preview {
    NavigationStack {
        QuizResultView(
            score        : 7,
            total        : 10,
            mode         : .flagToCountry,
            questions    : [],
            continent    : "all",
            questionCount: 10,
            answerMode   : .multipleChoice,
            path         : .constant([
                .quiz(mode: .flagToCountry, questions: [], answerMode: .multipleChoice),
                .results(score: 7, total: 10, mode: .flagToCountry, questions: [],
                         continent: "all", questionCount: 10, answerMode: .multipleChoice)
            ])
        )
    }
    .environmentObject(LanguageManager())
}
