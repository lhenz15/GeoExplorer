// FlashcardView.swift
// GeoExplorer
//
// Screen 2: shows one card at a time. Tap to flip, use Previous/Next to navigate.

import SwiftUI
import SwiftData

struct FlashcardView: View {

    let cards: [Flashcard]
    @Binding var path: [FlashcardRoute]

    @EnvironmentObject var lang: LanguageManager

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

            cardStack
                .onTapGesture { flipCard() }

            Text(isFlipped
                 ? lang.t("flashcard.card.tapQuestion")
                 : lang.t("flashcard.card.tapAnswer"))
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            navigationButtons
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .screenAppear()
        .navigationTitle("\(lang.t("flashcard.card.title")) \(currentIndex + 1) \(lang.t("flashcard.card.of")) \(cards.count)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(lang.t("flashcard.card.quit")) {
                    path = []
                }
                .foregroundStyle(.red)
            }
        }
    }

    // ── Progress header ───────────────────────────────────────────────────────
    private var progressHeader: some View {
        VStack(spacing: 6) {
            ProgressView(value: Double(currentIndex + 1), total: Double(cards.count))
                .tint(AppColors.accent)

            Text("\(currentIndex + 1) / \(cards.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // ── The flip card ─────────────────────────────────────────────────────────
    private var cardStack: some View {
        ZStack {
            CardFace(text: currentCard.question, role: .question, lang: lang)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                .opacity(isFlipped ? 0 : 1)

            CardFace(text: currentCard.answer, role: .answer, lang: lang)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(height: 280)
    }

    // ── Navigation buttons ────────────────────────────────────────────────────
    private var navigationButtons: some View {
        HStack(spacing: 16) {

            Button {
                moveCard(by: -1)
            } label: {
                Label(lang.t("flashcard.card.previous"), systemImage: "chevron.left")
            }
            .buttonStyle(.bordered)
            .disabled(isFirstCard)

            Spacer()

            if isLastCard {
                Button(lang.t("flashcard.card.finish")) {
                    saveProgress()
                    path.append(.results(cardCount: cards.count, cards: cards))
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    moveCard(by: 1)
                } label: {
                    Label(lang.t("flashcard.card.next"), systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private func flipCard() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
            isFlipped.toggle()
        }
    }

    private func moveCard(by offset: Int) {
        isFlipped = false
        currentIndex += offset
    }

    private func saveProgress() {
        StreakManager.recordStudySession()
    }
}

// ── CardFace ─────────────────────────────────────────────────────────────────
private enum CardRole { case question, answer }

private struct CardFace: View {
    let text: String
    let role: CardRole
    let lang: LanguageManager

    private var isSingleEmoji: Bool { text.count == 1 }

    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(gradient)
            .overlay {
                VStack(spacing: 16) {

                    Text(role == .question
                         ? lang.t("flashcard.card.question")
                         : lang.t("flashcard.card.answer"))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 6)

                    Spacer()

                    Text(text)
                        .font(isSingleEmoji
                              ? .system(size: 80)
                              : .system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
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
    .environmentObject(LanguageManager())
    .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
