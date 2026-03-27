// FlashcardResultView.swift
// GeoExplorer
//
// Screen 3: shown after the user finishes all cards.
// Lets them study the same set again or go back to setup.

import SwiftUI

struct FlashcardResultView: View {

    let cardCount: Int
    let cards: [Flashcard]
    @Binding var path: [FlashcardRoute]

    @EnvironmentObject var lang: LanguageManager

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
                    Text(lang.t("flashcard.result.complete"))
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("\(lang.t("flashcard.result.studied.prefix")) \(cardCount) \(cardCount == 1 ? lang.t("flashcard.result.card") : lang.t("flashcard.result.cards"))")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // ── Stat pill ──────────────────────────────────────────────────
            HStack(spacing: 40) {
                statPill(value: "\(cardCount)", label: lang.t("flashcard.result.cardsStudied"), icon: "rectangle.stack.fill")
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 32)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()

            // ── Action buttons ─────────────────────────────────────────────
            VStack(spacing: 12) {

                Button {
                    path = [.session(cards.shuffled())]
                } label: {
                    Label(lang.t("flashcard.result.studyAgain"), systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    path = []
                } label: {
                    Label(lang.t("flashcard.result.backSetup"), systemImage: "house")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle(lang.t("flashcard.result.title"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }

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
    .environmentObject(LanguageManager())
}
