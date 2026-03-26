// QuizView.swift
// GeoExplorer
//
// Screen 2: shows one question at a time with a countdown timer.
//
// New concepts:
//   • Timer.publish     — a Combine publisher that fires every N seconds
//   • .onReceive        — a view modifier that subscribes to a publisher
//   • DispatchQueue.main.asyncAfter — runs code after a delay
//   • State machine     — `isShowingFeedback` controls which "phase" we're in

import SwiftUI

struct QuizView: View {

    let questions: [QuizQuestion]
    @Binding var path: [QuizRoute]

    // ── Timer setup ────────────────────────────────────────────────────────────
    // `Timer.publish(every:on:in:)` creates a Combine publisher that fires
    // a Date value every `every` seconds on the given RunLoop.
    //
    // Think of it like a stopwatch tick: the publisher broadcasts a "tick"
    // signal, and any view that subscribes with `.onReceive` runs its closure.
    //
    // `.autoconnect()` starts the timer the moment a subscriber attaches
    // (i.e., when the view appears on screen).
    private let ticker = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    // How many seconds each question gets.
    private let questionDuration = 10.0

    // ── Local state ────────────────────────────────────────────────────────────
    @State private var currentIndex      = 0
    @State private var score             = 0

    // `timeRemaining` is a fraction from 1.0 (full time) down to 0.0 (no time).
    // We use a fraction because ProgressView expects a value between 0 and 1.
    @State private var timeRemaining     = 1.0

    // Stores the answer the user tapped. `nil` means they haven't answered yet.
    @State private var selectedAnswer: String? = nil

    // When `true`, we are in the "feedback" phase:
    //   • Timer is paused (ticks are ignored)
    //   • Buttons are coloured green/red
    //   • We're waiting 1 second before advancing
    @State private var isShowingFeedback = false

    // ── Derived shortcuts ──────────────────────────────────────────────────────
    private var currentQuestion: QuizQuestion { questions[currentIndex] }

    // Flag emojis are a single Swift grapheme cluster — check for size == 1.
    private var promptIsLargeEmoji: Bool      { currentQuestion.prompt.count == 1 }
    private var choicesAreEmojis:   Bool      { currentQuestion.choices.allSatisfy { $0.count == 1 } }

    // Timer bar turns orange below 50%, red below 25%.
    private var timerColor: Color {
        if timeRemaining > 0.5 { return .green }
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
        }
        .navigationTitle("Question \(currentIndex + 1) of \(questions.count)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Quit") { path = [] }
                    .foregroundStyle(.red)
            }
        }
        // ── Timer subscription ─────────────────────────────────────────────
        // `.onReceive` listens to the publisher and runs the closure on
        // every tick. The `_` parameter is the Date fired — we don't need it.
        //
        // HOW THE TIMER WORKS:
        //   1. Every 0.05 seconds, this closure runs.
        //   2. If we're showing feedback, skip the tick (timer is "paused").
        //   3. Otherwise, subtract a small fraction from `timeRemaining`.
        //   4. When it hits 0, call handleAnswer(nil) — a timeout = wrong answer.
        .onReceive(ticker) { _ in
            guard !isShowingFeedback else { return }

            if timeRemaining <= 0 {
                handleAnswer(nil)   // ran out of time
                return
            }

            // Each tick subtracts (tickInterval / totalDuration) from the fraction.
            // With 0.05s ticks and 10s total: each tick removes 0.5% of the bar.
            withAnimation(.linear(duration: 0.05)) {
                timeRemaining = max(0, timeRemaining - (0.05 / questionDuration))
            }
        }
    }

    // ── Timer bar ─────────────────────────────────────────────────────────────
    // A thin coloured bar at the very top of the screen.
    // `ProgressView(value:)` expects a number between 0 and 1 — perfect for
    // our `timeRemaining` fraction.
    private var timerBar: some View {
        ProgressView(value: timeRemaining)
            .tint(timerColor)
            .scaleEffect(x: 1, y: 2.5)   // make it thicker without changing layout
            .padding(.horizontal, 0)
            .padding(.top, 4)
            .animation(.linear(duration: 0.05), value: timerColor)
    }

    // ── Score header ──────────────────────────────────────────────────────────
    private var scoreHeader: some View {
        HStack {
            // Question progress
            Text("Q \(currentIndex + 1) / \(questions.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            // Live score pill
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
            Text("What is this?")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)

            // Show the prompt large if it's a flag emoji, regular size otherwise.
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
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // ── Answer buttons ────────────────────────────────────────────────────────
    // A vertical stack of 4 buttons. Each changes colour after an answer:
    //   • Correct answer  → always green
    //   • Tapped wrong    → red
    //   • Others          → unchanged (grey)
    private var answerButtons: some View {
        VStack(spacing: 10) {
            ForEach(currentQuestion.choices, id: \.self) { choice in
                Button {
                    handleAnswer(choice)
                } label: {
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
                // Disable all buttons once an answer is shown (prevents double-tap).
                .disabled(isShowingFeedback)
            }
        }
    }

    // ── Button colour helpers ──────────────────────────────────────────────────

    // Background: grey normally, green for correct, red for the wrong tap.
    private func buttonBackground(for choice: String) -> Color {
        guard isShowingFeedback else { return Color(.systemGray5) }
        if choice == currentQuestion.correctAnswer { return .green }
        if choice == selectedAnswer                { return .red   }
        return Color(.systemGray5)
    }

    // Foreground: primary text normally, white on coloured buttons.
    private func buttonForeground(for choice: String) -> Color {
        guard isShowingFeedback else { return .primary }
        if choice == currentQuestion.correctAnswer { return .white }
        if choice == selectedAnswer                { return .white }
        return .secondary
    }

    // ── Logic ─────────────────────────────────────────────────────────────────

    // Called when the user taps an answer OR the timer hits zero.
    // `answer == nil` means a timeout.
    private func handleAnswer(_ answer: String?) {
        // Guard against being called twice (shouldn't happen, but safe).
        guard !isShowingFeedback else { return }

        selectedAnswer   = answer
        isShowingFeedback = true

        if answer == currentQuestion.correctAnswer {
            score += 1
        }

        // `DispatchQueue.main.asyncAfter` runs its closure on the main thread
        // after the given delay. It's the SwiftUI way of saying "wait 1 second,
        // then do this" without blocking the UI.
        //
        // `.now() + 1.0` means "1 second from right now".
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advanceQuestion()
        }
    }

    private func advanceQuestion() {
        if currentIndex + 1 < questions.count {
            // More questions — reset state for the next one.
            currentIndex      += 1
            selectedAnswer     = nil
            isShowingFeedback  = false
            // Reset the bar to full. No animation so it snaps back instantly.
            timeRemaining      = 1.0
        } else {
            // All done — push the results route.
            path.append(.results(
                score    : score,
                total    : questions.count,
                questions: questions
            ))
        }
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
            path: .constant([.quiz([])])
        )
    }
}
