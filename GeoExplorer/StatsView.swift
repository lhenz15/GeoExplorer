// StatsView.swift
// GeoExplorer
//
// Dashboard showing streak, mastery progress, personal bests, and session history.

import SwiftUI
import SwiftData

struct StatsView: View {

    @EnvironmentObject var lang: LanguageManager

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Query(sort: [SortDescriptor(\QuizSession.date, order: .reverse)])
    private var sessions: [QuizSession]

    @Query private var progress: [CountryProgress]

    // ── UserDefaults (via @AppStorage) ────────────────────────────────────────
    @AppStorage(StreakManager.streakKey) private var streak = 0

    // ── Derived values ────────────────────────────────────────────────────────
    private var masteredCount: Int {
        progress.filter { $0.hasGoldBadge }.count
    }

    private func masteredForMode(_ mode: QuizMode) -> Int {
        progress.filter { $0.modeProgress(for: mode).isMastered }.count
    }

    private func bestScore(for mode: QuizMode) -> QuizSession? {
        sessions
            .filter  { $0.mode == mode.rawValue }
            .max     { $0.percentage < $1.percentage }
    }

    private func fastestTime(for mode: QuizMode) -> QuizSession? {
        sessions
            .filter { $0.mode == mode.rawValue }
            .min    { $0.timeTaken < $1.timeTaken }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    heroRow
                    masteryBreakdownSection
                    personalBestsSection
                    historySection

                }
                .padding(16)
            }
            .navigationTitle(lang.t("stats.title"))
        }
    }

    // ── Hero row: streak + mastered ───────────────────────────────────────────
    private var heroRow: some View {
        HStack(spacing: 12) {
            heroCard(
                topText  : streak == 0 ? "—" : "\(streak)",
                label    : streak == 1
                           ? lang.t("stats.streak.singular")
                           : lang.t("stats.streak.plural"),
                icon     : "flame.fill",
                iconColor: streak > 0 ? .orange : .secondary
            )
            heroCard(
                topText  : "\(masteredCount)",
                label    : "/ \(lang.countries.count) \(lang.t("stats.mastered.label"))",
                icon     : "checkmark.seal.fill",
                iconColor: masteredCount > 0 ? .green : .secondary
            )
        }
    }

    private func heroCard(topText: String, label: String, icon: String, iconColor: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            Text(topText)
                .font(.system(size: 36, weight: .bold))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: streak)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // ── Mastery breakdown ─────────────────────────────────────────────────────
    @ViewBuilder
    private var masteryBreakdownSection: some View {
        GroupBox {
            VStack(spacing: 12) {

                HStack(spacing: 10) {
                    Text("⭐")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(lang.t("stats.mastery.goldBadge"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(masteredCount) / \(lang.countries.count)")
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
        } label: {
            Label(lang.t("stats.mastery.title"), systemImage: "star.fill")
                .foregroundStyle(.yellow)
        }
    }

    // ── Personal bests ────────────────────────────────────────────────────────
    @ViewBuilder
    private var personalBestsSection: some View {
        let modesWithSessions = QuizMode.allCases.filter { bestScore(for: $0) != nil }

        if !modesWithSessions.isEmpty {
            GroupBox {
                VStack(spacing: 0) {
                    ForEach(Array(modesWithSessions.enumerated()), id: \.element) { index, mode in
                        bestRow(for: mode)
                        if index < modesWithSessions.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
            } label: {
                Label(lang.t("stats.bests.title"), systemImage: "trophy.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }

    private func bestRow(for mode: QuizMode) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mode.localizedName(using: lang))
                .font(.subheadline)
                .fontWeight(.semibold)
            HStack(spacing: 16) {
                if let best = bestScore(for: mode) {
                    Label(
                        "\(best.score)/\(best.total) (\(Int(best.percentage * 100))%)",
                        systemImage: "star.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                }
                if let fastest = fastestTime(for: mode) {
                    Label(fastest.formattedTime, systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // ── Session history ───────────────────────────────────────────────────────
    @ViewBuilder
    private var historySection: some View {
        if sessions.isEmpty {
            VStack(spacing: 16) {
                Text("🎯")
                    .font(.system(size: 72))
                Text(lang.t("stats.history.empty.title"))
                    .font(.title2)
                    .fontWeight(.bold)
                Text(lang.t("stats.history.empty.subtitle"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else {
            GroupBox {
                VStack(spacing: 0) {
                    let capped = Array(sessions.prefix(50))
                    ForEach(Array(capped.enumerated()), id: \.element.persistentModelID) { index, session in
                        sessionRow(session)
                        if index < capped.count - 1 {
                            Divider().padding(.vertical, 6)
                        }
                    }
                }
            } label: {
                Label(lang.t("stats.history.title"), systemImage: "clock.fill")
                    .foregroundStyle(.purple)
            }
        }
    }

    private func sessionRow(_ session: QuizSession) -> some View {
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
                Text(session.formattedTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(LanguageManager())
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
