// HomeView.swift
// GeoExplorer
//
// The app's entry point — a personal dashboard showing the user's progress
// at a glance and surfacing every feature with a single tap.
//
// ── New concepts ──────────────────────────────────────────────────────────────
//
//   LinearGradient
//     Fills a shape by blending two or more colours along a direction.
//     startPoint / endPoint are UnitPoint values: .topLeading is the
//     top-left corner, .bottomTrailing is the bottom-right. SwiftUI
//     automatically scales the gradient to fill whatever view it's applied to.
//
//   .ultraThinMaterial
//     Apple's "frosted glass" blur effect. Place it over the hero gradient
//     and it creates a translucent pill that blurs what's behind it — the
//     same look used in Control Centre and Notification Centre. It adapts
//     to Light / Dark Mode automatically, so you never have to check the
//     colour scheme yourself.
//
//   .fullScreenCover(isPresented:)
//     Presents a view that covers the entire screen (no rounded-corner sheet,
//     no partially-visible peek). It's ideal for self-contained task flows
//     because the presented view owns its own NavigationStack — opening
//     Flashcards or Quiz this way avoids nesting two NavigationStacks, which
//     would create a double navigation bar.
//
//     Compare: NavigationLink pushes INTO the current stack (one nav bar).
//              .sheet slides up with a grab handle (dismissible by swipe).
//              .fullScreenCover takes over the whole screen (task flows).
//
//   Calendar.current.component(.hour, from:)
//     Pulls a single time component out of a Date. Here we read the hour
//     to decide which greeting to show (morning / afternoon / evening).
//
//   .toolbar(.hidden, for: .navigationBar)
//     Hides the navigation bar for THIS screen only. When a NavigationLink
//     pushes CountryListView on top, the bar reappears with a Back button —
//     SwiftUI only applies the modifier to the view it's declared on.

import SwiftUI
import SwiftData

struct HomeView: View {

    // ── SwiftData ─────────────────────────────────────────────────────────────
    // @Query watches the database and re-renders whenever any row changes.
    // Sessions are pre-sorted newest-first so `.prefix(2)` gives us the two
    // most recent activities without any extra sorting code.
    @Query(sort: [SortDescriptor(\QuizSession.date, order: .reverse)])
    private var sessions: [QuizSession]

    @Query private var progress : [CountryProgress]
    @Query private var favorites: [FavoriteCountry]

    // ── UserDefaults (streak) ─────────────────────────────────────────────────
    @AppStorage(StreakManager.streakKey) private var streak = 0

    // ── Sheet / cover state ───────────────────────────────────────────────────
    // A simple Bool is all .fullScreenCover needs.
    // Setting it to true presents the cover; it goes back to false
    // automatically when the user dismisses the cover.
    @State private var showFlashcards = false
    @State private var showQuiz       = false

    // ── Derived values ────────────────────────────────────────────────────────

    private var bestScoreText: String {
        guard let best = sessions.max(by: { $0.percentage < $1.percentage }) else { return "—" }
        return "\(Int(best.percentage * 100))%"
    }

    // Countries with ⭐ gold badge (mastered in ≥2 modes).
    private var masteredCount: Int {
        progress.filter { $0.hasGoldBadge }.count
    }

    // Per-mode mastery count — used in the mastery breakdown section.
    private func masteredForMode(_ mode: QuizMode) -> Int {
        progress.filter { $0.modeProgress(for: mode).isMastered }.count
    }

    // Calendar.current.component extracts the hour (0–23) from right now.
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    heroSection

                    VStack(spacing: 20) {
                        statsRow
                        masterySection
                        featureSection
                        recentActivitySection
                    }
                    .padding(16)
                }
            }
            // Let the gradient hero bleed up behind the status bar.
            .ignoresSafeArea(edges: .top)
            // Hide the navigation bar on this screen only.
            // When CountryListView or FavoritesView is pushed, the bar
            // reappears automatically with a Back button.
            .toolbar(.hidden, for: .navigationBar)
            .background(AppColors.background)
        }
        // ── Task-flow modals ──────────────────────────────────────────────────
        // Flashcards and Quiz each own a NavigationStack for their multi-screen
        // flow (setup → session → results). Presenting them as a fullScreenCover
        // is the right pattern: no nested NavigationStacks, and the user can
        // clearly see they entered a focused task mode.
        .fullScreenCover(isPresented: $showFlashcards) { FlashcardSetupView() }
        .fullScreenCover(isPresented: $showQuiz)       { QuizSetupView() }
    }

    // ── Hero ──────────────────────────────────────────────────────────────────
    // ZStack layers two things on top of each other:
    //   • The gradient rectangle (background layer)
    //   • The text + streak pill (foreground layer, pinned to the bottom-left)
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {

            LinearGradient(
                colors    : [AppColors.gradientLeading, AppColors.gradientTrailing],
                startPoint: .topLeading,
                endPoint  : .bottomTrailing
            )
            .frame(maxWidth: .infinity)
            .frame(height: 240)

            VStack(alignment: .leading, spacing: 10) {

                Text("\(greeting), Explorer!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("195 countries · 195 capitals · 195 flags")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                // ── Streak pill ───────────────────────────────────────────────
                // .ultraThinMaterial applied inside a Capsule shape creates the
                // frosted-glass look: the gradient shows through, blurred.
                HStack(spacing: 6) {
                    Image(systemName: streak > 0 ? "flame.fill" : "flame")
                        .foregroundStyle(streak > 0 ? .orange : .white.opacity(0.7))
                    Text(streak > 0 ? "\(streak) day streak" : "Start your streak!")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
    }

    // ── Quick stats ───────────────────────────────────────────────────────────
    // Three compact cards — an at-a-glance snapshot so the user never needs
    // to navigate to Stats just to see how they're doing.
    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(value: bestScoreText,        label: "Best Score",  icon: "star.fill",           color: .yellow)
            statCard(value: "\(masteredCount)",   label: "Mastered",    icon: "checkmark.seal.fill", color: .green)
            statCard(value: "\(favorites.count)", label: "Favourites",  icon: "heart.fill",          color: .pink)
        }
    }

    // ── Mastery section ───────────────────────────────────────────────────────
    // Two things are shown here:
    //   1. Overall gold-badge % (countries mastered in ≥2 modes / 195).
    //   2. Per-mode breakdown — one ProgressView row for each of the 4 modes.
    //
    // ── What is ProgressView(value:total:)? ───────────────────────────────────
    // A built-in SwiftUI control that draws a filled horizontal bar.
    // `value` is the current amount, `total` is the maximum.
    // SwiftUI divides value/total to get the fill fraction (0.0 – 1.0).
    // `.tint()` controls the colour of the filled portion.
    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Mastery")
                .font(.title3)
                .fontWeight(.bold)

            VStack(spacing: 14) {

                // ── Overall gold badge ────────────────────────────────────
                HStack(spacing: 10) {
                    Text("⭐")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Gold Badge")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(masteredCount) / 195 (\(Int(Double(masteredCount) / 195.0 * 100))%)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: Double(masteredCount), total: 195)
                            .tint(.yellow)
                    }
                }

                Divider()

                // ── Per-mode breakdown ────────────────────────────────────
                // ForEach over QuizMode.allCases iterates every mode in the
                // order they are declared in the enum.
                ForEach(QuizMode.allCases, id: \.self) { mode in
                    let count = masteredForMode(mode)
                    HStack(spacing: 8) {
                        Text(mode.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            // Fixed width keeps all four bars left-aligned.
                            .frame(width: 130, alignment: .leading)
                        ProgressView(value: Double(count), total: 195)
                            .tint(AppColors.accent)
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 26, alignment: .trailing)
                    }
                }
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // ── Feature grid ──────────────────────────────────────────────────────────
    private var featureSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("What do you want to do?")
                .font(.title3)
                .fontWeight(.bold)

            // ── Explore Countries — full-width indigo card ────────────────────
            // NavigationLink pushes CountryListView(embedded: true) onto THIS
            // NavigationStack. `embedded: true` tells CountryListView to skip
            // its own NavigationStack wrapper, so there's only ever one nav bar.
            NavigationLink {
                CountryListView(embedded: true)
            } label: {
                exploreCard
            }
            .buttonStyle(NavLinkPressStyle())

            // ── Flashcards + Quiz — side by side ──────────────────────────────
            HStack(spacing: 12) {
                Button { showFlashcards = true } label: {
                    featureCard(emoji: "🃏", title: "Flashcards", subtitle: "Flip & learn")
                }
                .scaleOnPress()

                Button { showQuiz = true } label: {
                    featureCard(emoji: "❓", title: "Quiz", subtitle: "Test yourself")
                }
                .scaleOnPress()
            }

            // ── Favourites — full-width strip ─────────────────────────────────
            NavigationLink {
                FavoritesView(embedded: true)
            } label: {
                favouritesStrip
            }
            .buttonStyle(NavLinkPressStyle())
        }
    }

    // A full-width indigo card with the same gradient as the hero.
    private var exploreCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("🌍")
                    .font(.system(size: 44))
                Text("Explore Countries")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("Browse all 195 nations")
                    .font(.subheadline)
                    .opacity(0.85)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.title2)
                .opacity(0.7)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors    : [AppColors.gradientLeading, AppColors.gradientTrailing],
                startPoint: .topLeading,
                endPoint  : .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // Small square card used for Flashcards and Quiz.
    private func featureCard(emoji: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(emoji)
                .font(.system(size: 36))
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // Favourites strip — a wide, shorter card.
    private var favouritesStrip: some View {
        HStack(spacing: 14) {
            Text("❤️")
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("Favourites")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(favorites.isEmpty ? "No countries saved yet" : "\(favorites.count) saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // ── Recent activity ───────────────────────────────────────────────────────
    // @ViewBuilder lets this computed property return "nothing" when the
    // sessions array is empty — you can't do that with a plain `some View`.
    @ViewBuilder
    private var recentActivitySection: some View {
        if !sessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Activity")
                    .font(.title3)
                    .fontWeight(.bold)

                // .prefix(2) takes only the first two sessions (already sorted
                // newest-first by the @Query sort descriptor above).
                ForEach(Array(sessions.prefix(2))) { session in
                    recentRow(session)
                }
            }
        }
    }

    private func recentRow(_ session: QuizSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.mode)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.score)/\(session.total)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(session.percentage >= 0.7 ? .green : .primary)
                Text("\(Int(session.percentage * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
#Preview {
    HomeView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
