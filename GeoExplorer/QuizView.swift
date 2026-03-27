// QuizView.swift
// GeoExplorer
//
// Screen 2: shows one question at a time with a countdown timer.
// Saves a QuizSession and updates CountryProgress when the quiz finishes.

import SwiftUI
import SwiftData
import Combine

struct QuizView: View {

    let questions    : [QuizQuestion]
    let mode         : QuizMode
    let continent    : String
    let questionCount: Int
    @Binding var path: [QuizRoute]

    @EnvironmentObject var lang: LanguageManager

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Environment(\.modelContext) private var modelContext

    // ── Timer ─────────────────────────────────────────────────────────────────
    private let ticker           = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let questionDuration = 10.0

    // ── Local state ────────────────────────────────────────────────────────────
    @State private var currentIndex         = 0
    @State private var score                = 0
    @State private var timeRemaining        = 1.0
    @State private var selectedAnswer: String? = nil
    @State private var isShowingFeedback    = false
    @State private var startTime            = Date()

    // ── Derived shortcuts ──────────────────────────────────────────────────────
    private var currentQuestion   : QuizQuestion { questions[currentIndex] }
    private var promptIsLargeEmoji: Bool          { currentQuestion.prompt.count == 1 }
    private var choicesAreEmojis  : Bool          { currentQuestion.choices.allSatisfy { $0.count == 1 } }

    private var timerColor: Color {
        if timeRemaining > 0.5  { return .green  }
        if timeRemaining > 0.25 { return .orange }
        return .red
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        VStack(spacing: 0) {
            timerBar
            VStack(spacing: 20) {
                scoreHeader
                Spacer()
                promptCard
                Spacer()
                answerButtons
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            .screenAppear()
        }
        .navigationTitle("\(lang.t("quiz.question.title")) \(currentIndex + 1) \(lang.t("quiz.question.of")) \(questions.count)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(lang.t("quiz.question.quit")) { path = [] }
                    .foregroundStyle(.red)
            }
        }
        .onAppear { startTime = Date() }
        .onReceive(ticker) { _ in
            guard !isShowingFeedback else { return }
            if timeRemaining <= 0 {
                handleAnswer(nil)
                return
            }
            withAnimation(.linear(duration: 0.05)) {
                timeRemaining = max(0, timeRemaining - (0.05 / questionDuration))
            }
        }
    }

    // ── Timer bar ─────────────────────────────────────────────────────────────
    private var timerBar: some View {
        ProgressView(value: timeRemaining)
            .tint(timerColor)
            .scaleEffect(x: 1, y: 2.5)
            .padding(.top, 4)
            .animation(.linear(duration: 0.05), value: timerColor)
    }

    // ── Score header ──────────────────────────────────────────────────────────
    private var scoreHeader: some View {
        HStack {
            Text("Q \(currentIndex + 1) / \(questions.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Label("\(score)", systemImage: "star.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.top, 12)
    }

    // ── Question prompt ───────────────────────────────────────────────────────
    private var promptCard: some View {
        VStack(spacing: 12) {
            Text(lang.t("quiz.question.what"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)
            Text(currentQuestion.prompt)
                .font(promptIsLargeEmoji
                      ? .system(size: 90)
                      : .system(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // ── Answer buttons ────────────────────────────────────────────────────────
    private var answerButtons: some View {
        VStack(spacing: 10) {
            ForEach(currentQuestion.choices, id: \.self) { choice in
                Button { handleAnswer(choice) } label: {
                    Text(choice)
                        .font(choicesAreEmojis
                              ? .system(size: 44)
                              : .system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                }
                .background(buttonBackground(for: choice))
                .foregroundStyle(buttonForeground(for: choice))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(isShowingFeedback)
            }
        }
    }

    private func buttonBackground(for choice: String) -> Color {
        guard isShowingFeedback else { return AppColors.surface }
        if choice == currentQuestion.correctAnswer { return .green }
        if choice == selectedAnswer                { return .red   }
        return AppColors.surface
    }

    private func buttonForeground(for choice: String) -> Color {
        guard isShowingFeedback else { return .primary }
        if choice == currentQuestion.correctAnswer { return .white }
        if choice == selectedAnswer                { return .white }
        return .secondary
    }

    // ── Logic ─────────────────────────────────────────────────────────────────
    private func handleAnswer(_ answer: String?) {
        guard !isShowingFeedback else { return }
        selectedAnswer    = answer
        isShowingFeedback = true

        let isCorrect = (answer == currentQuestion.correctAnswer)
        if isCorrect {
            score += 1
            if answer != nil { triggerHaptic(correct: true) }
        } else if answer != nil {
            triggerHaptic(correct: false)
        }

        // countryId is the stable English name used as the MasteryManager key.
        MasteryManager.recordAnswer(
            countryName: currentQuestion.countryId,
            mode       : mode,
            isCorrect  : isCorrect,
            in         : modelContext
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advanceQuestion()
        }
    }

    private func triggerHaptic(correct: Bool) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle = correct ? .light : .heavy
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private func advanceQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex      += 1
            selectedAnswer     = nil
            isShowingFeedback  = false
            timeRemaining      = 1.0
        } else {
            saveSession()
            path.append(.results(
                score        : score,
                total        : questions.count,
                mode         : mode,
                questions    : questions,
                continent    : continent,
                questionCount: questionCount
            ))
        }
    }

    // ── Session saving ────────────────────────────────────────────────────────
    private func saveSession() {
        let timeTaken = Date().timeIntervalSince(startTime)

        modelContext.insert(QuizSession(
            mode     : mode.rawValue,
            score    : score,
            total    : questions.count,
            timeTaken: timeTaken
        ))

        MasteryManager.finishSession(
            for: questions.map { $0.countryId },
            mode: mode,
            in: modelContext
        )

        StreakManager.recordStudySession()
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
#Preview {
    NavigationStack {
        QuizView(
            questions: [
                QuizQuestion(prompt: "🇫🇷", correctAnswer: "France",
                             choices: ["France", "Germany", "Italy", "Spain"].shuffled()),
                QuizQuestion(prompt: "🇯🇵", correctAnswer: "Japan",
                             choices: ["Japan", "China", "Korea", "Vietnam"].shuffled()),
            ],
            mode         : .flagToCountry,
            continent    : "all",
            questionCount: 10,
            path: .constant([.quiz(mode: .flagToCountry, questions: [])])
        )
    }
    .environmentObject(LanguageManager())
    .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
