// MapQuizView.swift
// GeoExplorer
//
// Screen 2 for Map → Country mode.
// The top 55 % of the screen shows the target country's shape on a muted map.
// The bottom 45 % shows 4 country-name buttons with the same timer, feedback,
// and auto-advance behaviour as the regular QuizView.

import SwiftUI
import SwiftData
import Combine

struct MapQuizView: View {

    let questions    : [QuizQuestion]
    let mode         : QuizMode       // always .mapToCountry
    let continent    : String
    let questionCount: Int
    @Binding var path: [QuizRoute]

    @EnvironmentObject var lang: LanguageManager

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Environment(\.modelContext) private var modelContext

    // ── Timer ─────────────────────────────────────────────────────────────────
    private let ticker           = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let questionDuration = 15.0

    // ── Local state ───────────────────────────────────────────────────────────
    @State private var currentIndex      = 0
    @State private var score             = 0
    @State private var timeRemaining     = 1.0
    @State private var selectedAnswer: String? = nil
    @State private var isShowingFeedback = false
    @State private var startTime         = Date()

    // ── Derived shortcuts ─────────────────────────────────────────────────────
    private var currentQuestion: QuizQuestion { questions[currentIndex] }

    private var timerColor: Color {
        if timeRemaining > 0.5  { return .green  }
        if timeRemaining > 0.25 { return .orange }
        return .red
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        VStack(spacing: 0) {

            ProgressView(value: timeRemaining)
                .tint(timerColor)
                .scaleEffect(x: 1, y: 2.5)
                .padding(.top, 4)
                .animation(.linear(duration: 0.05), value: timerColor)

            GeometryReader { geo in
                VStack(spacing: 0) {

                    // ── Map (55 %) ────────────────────────────────────────────
                    // currentQuestion.prompt = country.id (English name).
                    // CountryMapView looks up the shape by English name in ShapeLoader.
                    CountryMapView(countryName: currentQuestion.prompt)
                        .frame(height: geo.size.height * 0.55)
                        .id(currentQuestion.id)

                    // ── Score + buttons (45 %) ────────────────────────────────
                    VStack(spacing: 12) {
                        scoreHeader
                        answerButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .frame(height: geo.size.height * 0.45)
                }
            }
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
    }

    // ── Answer buttons ────────────────────────────────────────────────────────
    private var answerButtons: some View {
        VStack(spacing: 8) {
            ForEach(currentQuestion.choices, id: \.self) { choice in
                Button { handleAnswer(choice) } label: {
                    Text(choice)
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.65)
                }
                .background(buttonBackground(for: choice))
                .foregroundStyle(buttonForeground(for: choice))
                .clipShape(RoundedRectangle(cornerRadius: 12))
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

    // ── Answer handling ───────────────────────────────────────────────────────
    private func handleAnswer(_ answer: String?) {
        guard !isShowingFeedback else { return }
        selectedAnswer    = answer
        isShowingFeedback = true

        let isCorrect = (answer == currentQuestion.correctAnswer)
        if isCorrect {
            score += 1
            if answer != nil { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        } else if answer != nil {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }

        // countryId is the stable English name used as the MasteryManager key.
        MasteryManager.recordAnswer(
            countryName: currentQuestion.countryId,
            mode       : mode,
            isCorrect  : isCorrect,
            in         : modelContext
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            advanceQuestion()
        }
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
        MapQuizView(
            questions: [
                QuizQuestion(prompt: "France",  correctAnswer: "France",
                             choices: ["France","Germany","Spain","Italy"].shuffled(),
                             countryId: "France"),
                QuizQuestion(prompt: "Brazil",  correctAnswer: "Brazil",
                             choices: ["Brazil","Argentina","Peru","Colombia"].shuffled(),
                             countryId: "Brazil"),
            ],
            mode         : .mapToCountry,
            continent    : "all",
            questionCount: 10,
            path         : .constant([.quiz(mode: .mapToCountry, questions: [])])
        )
    }
    .environmentObject(LanguageManager())
    .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self],
                    inMemory: true)
}
