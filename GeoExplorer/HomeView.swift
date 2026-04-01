// HomeView.swift
// GeoExplorer
//
// The app's entry point — a personal dashboard showing the user's progress
// at a glance and surfacing every feature with a single tap.

import SwiftUI
import SwiftData

struct HomeView: View {

    // ── Language ──────────────────────────────────────────────────────────────
    @EnvironmentObject var lang: LanguageManager

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Query(sort: [SortDescriptor(\QuizSession.date, order: .reverse)])
    private var sessions: [QuizSession]

    @Query private var progress : [CountryProgress]
    @Query private var favorites: [FavoriteCountry]

    // ── UserDefaults (streak) ─────────────────────────────────────────────────
    @AppStorage(StreakManager.streakKey) private var streak = 0

    // ── Sheet / cover state ───────────────────────────────────────────────────
    @State private var showFlashcards = false
    @State private var showQuiz       = false

    // ── Derived values ────────────────────────────────────────────────────────

    private var bestScoreText: String {
        guard let best = sessions.max(by: { $0.percentage < $1.percentage }) else { return "—" }
        return "\(Int(best.percentage * 100))%"
    }

    private var masteredCount: Int {
        progress.filter { $0.hasGoldBadge }.count
    }

    private var knownCount: Int {
        progress.filter { $0.isKnown }.count
    }

    private func masteredForMode(_ mode: QuizMode) -> Int {
        progress.filter { $0.modeProgress(for: mode).isMastered }.count
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return lang.t("home.greeting.morning")
        case 12..<17: return lang.t("home.greeting.afternoon")
        default:      return lang.t("home.greeting.evening")
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
                        featureSection
                        NavigationLink {
                            FavoritesView(embedded: true)
                        } label: {
                            favouritesStrip
                        }
                        .buttonStyle(NavLinkPressStyle())
                        masterySection
                        recentActivitySection
                    }
                    .padding(16)
                }
            }
            .ignoresSafeArea(edges: .top)
            .toolbar(.hidden, for: .navigationBar)
            .background(AppColors.background)
        }
        .fullScreenCover(isPresented: $showFlashcards) { FlashcardSetupView() }
        .fullScreenCover(isPresented: $showQuiz)       { QuizSetupView() }
    }

    // ── Hero ──────────────────────────────────────────────────────────────────
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

                Text(lang.t("home.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 6) {
                    Image(systemName: streak > 0 ? "flame.fill" : "flame")
                        .foregroundStyle(streak > 0 ? .orange : .white.opacity(0.7))
                    Text(streak > 0
                         ? "\(streak) \(lang.t("home.streak.active"))"
                         : lang.t("home.streak.none"))
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
    private var statsRow: some View {
        HStack(spacing: 8) {
            statCard(value: bestScoreText,        label: lang.t("home.stat.bestScore"),  icon: "star.fill",              color: .yellow)
            statCard(value: "\(masteredCount)",   label: lang.t("home.stat.mastered"),   icon: "checkmark.seal.fill",    color: .green)
            statCard(value: "\(knownCount)/195",  label: lang.t("home.stat.known"),      icon: "checkmark.circle.fill",  color: .mint)
            statCard(value: "\(favorites.count)", label: lang.t("home.stat.favourites"), icon: "heart.fill",             color: .pink)
        }
    }

    // ── Mastery section ───────────────────────────────────────────────────────
    private var masterySection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(lang.t("home.mastery.title"))
                .font(.title3)
                .fontWeight(.bold)

            VStack(spacing: 14) {

                HStack(spacing: 10) {
                    Text("⭐")
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(lang.t("home.mastery.goldBadge"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(masteredCount) / \(lang.countries.count) (\(Int(Double(masteredCount) / Double(max(lang.countries.count, 1)) * 100))%)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: Double(masteredCount), total: Double(max(lang.countries.count, 1)))
                            .tint(.yellow)
                    }
                }

                Divider()

                ForEach(QuizMode.allCases, id: \.self) { mode in
                    let count = masteredForMode(mode)
                    HStack(spacing: 8) {
                        Text(mode.localizedName(using: lang))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 140, alignment: .leading)
                        ProgressView(value: Double(count), total: Double(max(lang.countries.count, 1)))
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

            Text(lang.t("home.section.todo"))
                .font(.title3)
                .fontWeight(.bold)

            NavigationLink {
                CountryListView(embedded: true)
            } label: {
                exploreCard
            }
            .buttonStyle(NavLinkPressStyle())

            HStack(spacing: 12) {
                Button { showFlashcards = true } label: {
                    featureCard(emoji: "🃏", title: lang.t("home.flashcards.title"), subtitle: lang.t("home.flashcards.subtitle"))
                }
                .scaleOnPress()

                Button { showQuiz = true } label: {
                    featureCard(emoji: "❓", title: lang.t("home.quiz.title"), subtitle: lang.t("home.quiz.subtitle"))
                }
                .scaleOnPress()
            }

        }
    }

    private var exploreCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("🌍")
                    .font(.system(size: 44))
                Text(lang.t("home.explore.title"))
                    .font(.title3)
                    .fontWeight(.bold)
                Text(lang.t("home.explore.subtitle"))
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

    private var favouritesStrip: some View {
        HStack(spacing: 14) {
            Text("❤️")
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(lang.t("home.favourites.title"))
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(favorites.isEmpty
                     ? lang.t("home.favourites.empty")
                     : "\(favorites.count) \(lang.t("home.favourites.saved"))")
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
    @ViewBuilder
    private var recentActivitySection: some View {
        if !sessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(lang.t("home.activity.title"))
                    .font(.title3)
                    .fontWeight(.bold)

                ForEach(Array(sessions.prefix(2))) { session in
                    recentRow(session)
                }
            }
        }
    }

    private func recentRow(_ session: QuizSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(lang.localizedModeName(session.mode))
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
        .environmentObject(LanguageManager())
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
