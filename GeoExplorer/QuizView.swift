// QuizView.swift
// GeoExplorer
//
// Screen 2: shows one question at a time with a countdown timer.
// Supports two answer modes:
//   • Multiple Choice — four tappable buttons (original behaviour)
//   • Type It         — a text field with fuzzy-match grading
//
// ── Levenshtein distance ──────────────────────────────────────────────────────
// Levenshtein distance counts the minimum number of single-character edits
// (insertions, deletions, or substitutions) needed to turn one string into
// another.  "France" vs "Frace" = 1 edit (missing 'n'), so distance = 1.
// We use it to allow small typos: 1 typo for 5-8 character answers, 2 typos
// for 9+ characters.  Short answers (1-4 chars) require an exact match because
// they are already very short and a single typo could match a different country.
//
// ── @FocusState ───────────────────────────────────────────────────────────────
// @FocusState is a SwiftUI property wrapper that tracks which view currently
// has keyboard focus.  Pairing it with `.focused($isInputFocused)` on a
// TextField lets you programmatically show or hide the keyboard:
//   isInputFocused = true   → keyboard appears
//   isInputFocused = false  → keyboard dismisses
// We set it to true via .onAppear and on every question advance so the
// keyboard stays open throughout the quiz without the user having to tap.

import SwiftUI
import SwiftData
import Combine

struct QuizView: View {

    let questions    : [QuizQuestion]
    let mode         : QuizMode
    let answerMode   : AnswerMode
    let continent    : String
    let questionCount: Int
    @Binding var path: [QuizRoute]

    @EnvironmentObject var lang: LanguageManager

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Environment(\.modelContext) private var modelContext

    // ── Timer ─────────────────────────────────────────────────────────────────
    private let ticker           = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let questionDuration = 10.0

    // ── Multiple-choice state ─────────────────────────────────────────────────
    @State private var selectedAnswer: String? = nil

    // ── Type-It state ─────────────────────────────────────────────────────────
    @State private var typedAnswer      = ""
    // feedbackIsCorrect drives the text field border colour.
    // nil = question is still active (no feedback yet).
    @State private var feedbackIsCorrect: Bool? = nil

    // @FocusState tracks whether the TextField currently has keyboard focus.
    // We flip this to true whenever a new question loads.
    @FocusState private var isInputFocused: Bool

    // ── Shared state ──────────────────────────────────────────────────────────
    @State private var currentIndex      = 0
    @State private var score             = 0
    @State private var timeRemaining     = 1.0
    @State private var isShowingFeedback = false
    @State private var startTime         = Date()

    // ── Derived shortcuts ──────────────────────────────────────────────────────
    private var currentQuestion   : QuizQuestion { questions[currentIndex] }
    private var promptIsLargeEmoji: Bool          { currentQuestion.prompt.count == 1 }
    private var choicesAreEmojis  : Bool          { currentQuestion.choices.allSatisfy { $0.count == 1 } }

    private var timerColor: Color {
        if timeRemaining > 0.5  { return .green  }
        if timeRemaining > 0.25 { return .orange }
        return .red
    }

    // Colour for the typed-answer text field border.
    private var textFieldBorderColor: Color {
        switch feedbackIsCorrect {
        case .none:  return AppColors.accent
        case .some(true):  return .green
        case .some(false): return .red
        }
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
                if answerMode == .typeIt {
                    typeItSection
                } else {
                    answerButtons
                }
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
        .onAppear {
            startTime = Date()
            focusInputIfNeeded()
        }
        // Re-focus the text field every time the question index advances.
        // .onChange(of:) fires whenever currentIndex changes value.
        .onChange(of: currentIndex) { _, _ in
            focusInputIfNeeded()
        }
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

    // ── Multiple-choice answer buttons ────────────────────────────────────────
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

    // ── Type-It section ───────────────────────────────────────────────────────
    // Layout: coloured-border TextField → feedback row → Submit button.
    private var typeItSection: some View {
        VStack(spacing: 14) {

            // Text field with a coloured rounded border.
            // .focused($isInputFocused) links this field to our @FocusState variable.
            // .onSubmit fires when the user presses Return on the keyboard —
            // exactly the same as tapping the Submit button.
            TextField(lang.t("quiz.type.placeholder"), text: $typedAnswer)
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(14)
                .background(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(textFieldBorderColor, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .focused($isInputFocused)
                .disabled(isShowingFeedback)
                .onSubmit { submitTypedAnswer() }
                .animation(.easeInOut(duration: 0.2), value: textFieldBorderColor)

            // Feedback row: shown only during the 1–1.5 s feedback window.
            // Correct → green checkmark.  Wrong → correct answer in red.
            if let correct = feedbackIsCorrect {
                if correct {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text(currentQuestion.correctAnswer)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
            }

            // Submit button — disabled while feedback is showing or field is empty.
            Button {
                submitTypedAnswer()
            } label: {
                Text(lang.t("quiz.type.submit"))
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isShowingFeedback || typedAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // ── Type-It logic ─────────────────────────────────────────────────────────

    private func submitTypedAnswer() {
        let trimmed = typedAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isShowingFeedback else { return }
        isInputFocused = false  // dismiss keyboard so feedback is visible
        if isCloseEnough(trimmed, to: currentQuestion.correctAnswer) {
            handleAnswer(currentQuestion.correctAnswer)
        } else {
            handleAnswer(trimmed)
        }
    }

    // Fuzzy matching using Levenshtein distance with accent stripping.
    //
    // Step 1: normalise — strip diacritics and make lowercase so
    //   "Côte d'Ivoire" == "cote d'ivoire" and "España" == "espana".
    // Step 2: measure edit distance between the normalised strings.
    // Step 3: compare against the allowed error count, which depends on
    //   how long the correct answer is (shorter = stricter).
    private func isCloseEnough(_ typed: String, to correct: String) -> Bool {
        let a = normalize(typed)
        let b = normalize(correct)
        let distance = levenshtein(a, b)
        let allowed: Int
        switch b.count {
        case 0...4: allowed = 0   // exact match required
        case 5...8: allowed = 1   // 1 typo allowed
        default:    allowed = 2   // 2 typos allowed
        }
        return distance <= allowed
    }

    // Strips accents and lowercases — "Côte d'Ivoire" → "cote d'ivoire".
    private func normalize(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Levenshtein distance — counts the minimum single-character edits to
    // transform string `a` into string `b`.
    //
    // How it works: we build a 1-D array `dp` where dp[j] = the edit distance
    // between the first i characters of `a` and the first j characters of `b`.
    // We fill it row by row, carrying a `prev` variable for the diagonal cell.
    private func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        guard !a.isEmpty else { return b.count }
        guard !b.isEmpty else { return a.count }
        var dp = Array(0...b.count)              // dp[j] = cost for first j chars of b
        for i in 1...a.count {
            var prev = dp[0]                     // the diagonal: dp[i-1][j-1]
            dp[0] = i
            for j in 1...b.count {
                let temp = dp[j]
                dp[j] = a[i-1] == b[j-1]
                    ? prev                               // characters match: no edit
                    : 1 + min(prev, dp[j], dp[j-1])     // substitute / delete / insert
                prev = temp
            }
        }
        return dp[b.count]
    }

    // Focuses the text field a tick after the view updates so SwiftUI has
    // time to lay out the field before trying to focus it.
    private func focusInputIfNeeded() {
        guard answerMode == .typeIt else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isInputFocused = true
        }
    }

    // ── Shared answer handling ────────────────────────────────────────────────
    private func handleAnswer(_ answer: String?) {
        guard !isShowingFeedback else { return }
        selectedAnswer       = answer
        isShowingFeedback    = true

        let isCorrect = (answer == currentQuestion.correctAnswer)

        // Update the Type-It feedback border/icon.
        if answerMode == .typeIt {
            withAnimation { feedbackIsCorrect = isCorrect }
        }

        if isCorrect {
            score += 1
            if answer != nil { triggerHaptic(correct: true) }
        } else if answer != nil {
            triggerHaptic(correct: false)
        }

        MasteryManager.recordAnswer(
            countryName: currentQuestion.countryId,
            mode       : mode,
            isCorrect  : isCorrect,
            in         : modelContext
        )

        // Correct: advance after 1.0 s.
        // Wrong in Type-It: stay 1.5 s so the user can read the correct answer.
        let delay: Double = (isCorrect || answerMode == .multipleChoice) ? 1.0 : 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
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
            typedAnswer        = ""
            feedbackIsCorrect  = nil
            // focusInputIfNeeded() is called by .onChange(of: currentIndex)
        } else {
            saveSession()
            path.append(.results(
                score        : score,
                total        : questions.count,
                mode         : mode,
                questions    : questions,
                continent    : continent,
                questionCount: questionCount,
                answerMode   : answerMode
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
            answerMode   : .multipleChoice,
            continent    : "all",
            questionCount: 10,
            path: .constant([.quiz(mode: .flagToCountry, questions: [], answerMode: .multipleChoice)])
        )
    }
    .environmentObject(LanguageManager())
    .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
