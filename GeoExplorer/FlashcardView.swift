// FlashcardView.swift
// GeoExplorer
//
// Screen 2: shows one card at a time. Tap to flip, use Previous/Next to navigate.
//
// New concepts:
//   • withAnimation        — runs a state change through SwiftUI's animation engine
//   • .rotation3DEffect    — rotates a view in 3D space (the flip effect)
//   • ZStack               — layers views on top of each other (needed for front/back)
//   • ProgressView         — a built-in progress bar
//   • .toolbar             — adds buttons to the navigation bar
//   • .navigationBarBackButtonHidden — hides the default "<Back" button

import SwiftUI
import SwiftData

struct FlashcardView: View {

    let cards: [Flashcard]
    @Binding var path: [FlashcardRoute]

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Environment(\.modelContext) private var modelContext
    @Query private var progressList: [CountryProgress]

    // ── Local state ───────────────────────────────────────────────────────────
    @State private var currentIndex = 0
    @State private var isFlipped    = false

    // ── Derived shortcuts ─────────────────────────────────────────────────────
    private var currentCard: Flashcard { cards[currentIndex] }
    private var isFirstCard: Bool      { currentIndex == 0 }
    private var isLastCard:  Bool      { currentIndex == cards.count - 1 }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        VStack(spacing: 20) {

            progressHeader

            Spacer()

            // The card itself — tapping it flips it.
            cardStack
                .onTapGesture { flipCard() }

            // Small hint so the user knows it's interactive.
            Text(isFlipped ? "Tap to see question" : "Tap to reveal answer")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            navigationButtons
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .navigationTitle("Card \(currentIndex + 1) of \(cards.count)")
        .navigationBarTitleDisplayMode(.inline)
        // Hide the default back button — we provide our own "Quit".
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Quit") {
                    // Wipe the entire path — jumps straight back to Setup.
                    path = []
                }
                .foregroundStyle(.red)
            }
        }
    }

    // ── Progress header ───────────────────────────────────────────────────────
    private var progressHeader: some View {
        VStack(spacing: 6) {
            // `ProgressView(value:total:)` draws a filled horizontal bar.
            // value / total = fraction complete. SwiftUI handles the math.
            ProgressView(value: Double(currentIndex + 1), total: Double(cards.count))
                .tint(.blue)

            Text("\(currentIndex + 1) / \(cards.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // ── The flip card ─────────────────────────────────────────────────────────
    // This is the heart of the screen. Two card faces sit in a ZStack.
    // When `isFlipped` changes, `.rotation3DEffect` rotates each face in 3D.
    //
    // HOW THE 3D FLIP WORKS:
    // ┌─────────────────────────────────────────────────────────────────┐
    // │ Imagine a physical card lying flat on a table, held at its      │
    // │ left and right edges. "Flipping" means rotating it 180° around  │
    // │ a vertical axis (the Y axis).                                   │
    // │                                                                 │
    // │  Front face:                                                    │
    // │    - Starts at 0°   (facing you).                              │
    // │    - Rotates to 180° when flipped (now facing away from you).  │
    // │                                                                 │
    // │  Back face:                                                     │
    // │    - Starts at -180° (pre-rotated to face away from you).      │
    // │    - Rotates to 0°   when flipped (now facing toward you).     │
    // │                                                                 │
    // │  opacity: each face hides itself after it passes 90° so you    │
    // │  never see mirrored text. The transition is instant at 90°     │
    // │  — the spring animation smoothly covers the jump.              │
    // └─────────────────────────────────────────────────────────────────┘
    private var cardStack: some View {
        ZStack {
            // ── Front face ─────────────────────────────────────────────
            CardFace(text: currentCard.question, role: .question)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),    // Y axis = vertical spin
                    perspective: 0.4              // depth — 0 = flat, 1 = very deep
                )
                // Hide once this face has rotated past 90° (pointing away).
                .opacity(isFlipped ? 0 : 1)

            // ── Back face ──────────────────────────────────────────────
            CardFace(text: currentCard.answer, role: .answer)
                // Pre-rotated -180°: starts facing away, arrives at 0° (facing you).
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                // Hidden until this face has rotated into view past 90°.
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(height: 280)
    }

    // ── Navigation buttons ────────────────────────────────────────────────────
    private var navigationButtons: some View {
        HStack(spacing: 16) {

            // Previous button
            Button {
                moveCard(by: -1)
            } label: {
                Label("Previous", systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)
            .disabled(isFirstCard)

            Spacer()

            // Next or Finish button
            if isLastCard {
                Button("Finish  ✓") {
                    saveProgress()
                    path.append(.results(cardCount: cards.count, cards: cards))
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    moveCard(by: 1)
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon) // shows both text AND icon
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private func flipCard() {
        // `withAnimation` wraps a state change so SwiftUI smoothly interpolates
        // between the old and new values using the spring curve.
        // Without `withAnimation`, the rotation would jump instantly.
        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            isFlipped.toggle()
        }
    }

    private func moveCard(by offset: Int) {
        isFlipped = false
        currentIndex += offset
    }

    // ── Progress saving ───────────────────────────────────────────────────────
    // Called when the user taps Finish. Every card studied counts as one
    // correct answer towards mastery (3 correct = mastered).
    private func saveProgress() {
        for card in cards {
            guard !card.countryName.isEmpty else { continue }
            if let existing = progressList.first(where: { $0.countryName == card.countryName }) {
                existing.correctCount += 1
            } else {
                modelContext.insert(CountryProgress(countryName: card.countryName, correctCount: 1))
            }
        }
        StreakManager.recordStudySession()
    }
}

// ── CardFace ─────────────────────────────────────────────────────────────────
// A `private` struct — only usable inside this file.
// It draws one side of the flashcard (question or answer).

private enum CardRole { case question, answer }

private struct CardFace: View {
    let text: String
    let role: CardRole

    // Flag emojis are a single Swift grapheme cluster (e.g. 🇫🇷 = 1 character).
    // We show them at 80pt; other text uses a smaller title size.
    private var isSingleEmoji: Bool { text.count == 1 }

    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(gradient)
            .overlay {
                VStack(spacing: 16) {

                    // Role label at the top corner
                    Text(role == .question ? "QUESTION" : "ANSWER")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 6)

                    Spacer()

                    // Main text — large emoji for flag quiz, regular for others
                    Text(text)
                        .font(isSingleEmoji
                              ? .system(size: 80)
                              : .system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)  // shrinks if text is very long
                        .padding(.horizontal, 12)

                    Spacer()
                }
                .padding(20)
            }
            .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
    }

    private var gradient: LinearGradient {
        switch role {
        case .question:
            return LinearGradient(
                colors: [Color(red: 0.27, green: 0.45, blue: 0.90),
                         Color(red: 0.17, green: 0.30, blue: 0.75)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .answer:
            return LinearGradient(
                colors: [Color(red: 0.18, green: 0.68, blue: 0.55),
                         Color(red: 0.09, green: 0.48, blue: 0.40)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
#Preview {
    // NavigationStack is needed in the preview because FlashcardView uses
    // navigation bar features (.navigationTitle, .toolbar, etc.)
    NavigationStack {
        FlashcardView(
            cards: [
                Flashcard(question: "🇫🇷", answer: "France"),
                Flashcard(question: "🇯🇵", answer: "Japan"),
                Flashcard(question: "🇧🇷", answer: "Brazil"),
            ],
            path: .constant([.session([])])
        )
    }
    .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
