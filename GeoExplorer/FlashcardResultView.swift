// FlashcardResultView.swift
// GeoExplorer
//
// Screen 3: shown after the user finishes all cards.
// Lets them study the same set again or go back to setup.

import SwiftUI

struct FlashcardResultView: View {

    let cardCount: Int          // how many cards were in the session
    let cards: [Flashcard]      // the same cards (shuffled for "Study Again")
    @Binding var path: [FlashcardRoute]

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // ── Trophy section ─────────────────────────────────────────────
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.4), radius: 12)

                VStack(spacing: 8) {
                    Text("Session Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // Pluralise "card" correctly using a ternary expression.
                    // `condition ? valueIfTrue : valueIfFalse`
                    Text("You studied \(cardCount) \(cardCount == 1 ? "card" : "cards")")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // ── Stat pill ──────────────────────────────────────────────────
            HStack(spacing: 40) {
                statPill(value: "\(cardCount)", label: "Cards studied", icon: "rectangle.stack.fill")
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 32)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()

            // ── Action buttons ─────────────────────────────────────────────
            VStack(spacing: 12) {

                // "Study Again" replaces the entire path with a new session
                // using the same cards shuffled in a different order.
                //
                // `path = [.session(...)]` means:
                //   • Clear the stack (pop results + session)
                //   • Push a brand-new session to the top
                // NavigationStack animates this as a pop-then-push.
                Button {
                    path = [.session(cards.shuffled())]
                } label: {
                    Label("Study Same Cards Again", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // "Back to Setup" empties the path entirely — NavigationStack
                // pops back to the root (FlashcardSetupView).
                Button {
                    path = []
                } label: {
                    Label("Back to Setup", systemImage: "house")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        // Hide the back button — the explicit buttons above handle navigation.
        .navigationBarBackButtonHidden()
    }

    // ── Helper: a labelled stat pill ──────────────────────────────────────────
    private func statPill(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(value)
                .font(.title)
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
        FlashcardResultView(
            cardCount: 10,
            cards: [Flashcard(question: "🇫🇷", answer: "France")],
            path: .constant([.session([]), .results(cardCount: 10, cards: [])])
        )
    }
}
