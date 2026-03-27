// QuizResultView.swift
// GeoExplorer
//
// Screen 3: shown after all questions are answered.
// Displays the final score and offers Play Again or Back to Setup.

import SwiftUI

struct QuizResultView: View {

    let score    : Int
    let total    : Int
    let mode     : QuizMode
    let questions: [QuizQuestion]
    @Binding var path: [QuizRoute]

    // ── Derived values ────────────────────────────────────────────────────────
    private var percentage: Double  { total > 0 ? Double(score) / Double(total) : 0 }
    private var percentText: String { "\(Int(percentage * 100))%" }

    // Pick an emoji that reflects how well the user did.
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
        case 0.9...: return "Outstanding!"
        case 0.7...: return "Great job!"
        case 0.5...: return "Good effort!"
        default:     return "Keep practising!"
        }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        // ZStack layers the confetti on top of the result content.
        // We only show confetti when the user scored 70 % or above —
        // it's a reward for a good performance, not a consolation prize.
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

                    // Big fraction — the most important number.
                    Text("\(score) / \(total)")
                        .font(.system(size: 60, weight: .bold))

                    Text("\(percentText) correct")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // ── Stat pills ─────────────────────────────────────────────────
            HStack(spacing: 32) {
                statPill(value: "\(score)",         label: "Correct",   icon: "checkmark.circle.fill",  color: .green)
                statPill(value: "\(total - score)", label: "Wrong",     icon: "xmark.circle.fill",      color: .red)
                statPill(value: percentText,        label: "Score",     icon: "percent",                color: .blue)
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
                    // Build fresh QuizQuestion instances so each question gets
                    // a brand-new UUID.  The `.id()` modifier on QuizView (in
                    // QuizSetupView's navigationDestination) compares those UUIDs;
                    // when they differ SwiftUI fully destroys and recreates the
                    // view, resetting every @State var (currentIndex, score, etc.)
                    // to its default.  Without new UUIDs the IDs look the same
                    // after a shuffle and SwiftUI reuses the existing QuizView
                    // with its stale state, which is what caused the frozen screen.
                    let freshQuestions = questions.shuffled().map { q in
                        QuizQuestion(
                            prompt       : q.prompt,
                            correctAnswer: q.correctAnswer,
                            choices      : q.choices.shuffled(),
                            countryName  : q.countryName
                        )
                    }
                    path = [.quiz(mode: mode, questions: freshQuestions)]
                } label: {
                    Label("Play Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .scaleOnPress()

                Button {
                    path = []
                } label: {
                    Label("Back to Setup", systemImage: "house")
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

        // Confetti fires once when the view appears and fades out on its own.
        // .allowsHitTesting(false) inside ConfettiView lets button taps through.
        if percentage >= 0.7 {
            ConfettiView()
        }

        } // end ZStack
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }

    // ── Helper: coloured stat pill ─────────────────────────────────────────────
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
            score    : 7,
            total    : 10,
            mode     : .flagToCountry,
            questions: [],
            path     : .constant([
                .quiz(mode: .flagToCountry, questions: []),
                .results(score: 7, total: 10, mode: .flagToCountry, questions: [])
            ])
        )
    }
}
