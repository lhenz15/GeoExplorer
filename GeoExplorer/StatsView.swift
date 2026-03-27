// StatsView.swift
// GeoExplorer
//
// Dashboard showing streak, mastery progress, personal bests, notification
// settings, and a scrollable history of completed quiz sessions.
//
// New concepts used here:
//   • @AppStorage     — property wrapper that reads/writes UserDefaults and
//                       re-renders the view when the value changes (like @State
//                       but backed by persistent storage instead of memory).
//   • @Query with sort — fetches SwiftData rows pre-sorted, so we don't need
//                       to sort the array ourselves in a computed property.
//   • GroupBox        — a built-in SwiftUI container that draws a rounded card
//                       with an optional title label above it.
//   • Binding { get set } — a custom two-way binding built from closures,
//                       used here to bridge @AppStorage ints ↔ a Date picker.

import SwiftUI
import SwiftData

struct StatsView: View {

    // ── SwiftData ─────────────────────────────────────────────────────────────

    // Fetch sessions sorted newest-first. SortDescriptor is the SwiftData way
    // to declare a sort order directly on the @Query — more efficient than
    // sorting a plain array in a computed property.
    @Query(sort: [SortDescriptor(\QuizSession.date, order: .reverse)])
    private var sessions: [QuizSession]

    @Query private var progress: [CountryProgress]

    // ── UserDefaults (via @AppStorage) ────────────────────────────────────────
    // @AppStorage("key") declares a property backed by UserDefaults.
    // Reading it returns the stored value (or the default if nothing is saved).
    // Writing it saves to UserDefaults AND triggers a SwiftUI re-render.
    //
    // We share the exact same key string as StreakManager so that when
    // StreakManager calls UserDefaults.standard.set(...), this view updates.
    @AppStorage(StreakManager.streakKey) private var streak = 0

    // ── Other state ───────────────────────────────────────────────────────────
    // Total countries loaded from JSON — used to show "X / 195" mastered.
    private let totalCountries = DataLoader.loadCountries().count

    // ── Derived values ────────────────────────────────────────────────────────
    // A country counts as mastered once it earns the gold badge
    // (mastered in at least 2 of the 4 quiz modes).
    private var masteredCount: Int {
        progress.filter { $0.hasGoldBadge }.count
    }

    private func masteredForMode(_ mode: QuizMode) -> Int {
        progress.filter { $0.modeProgress(for: mode).isMastered }.count
    }

    // Best score (highest percentage) for a given mode.
    private func bestScore(for mode: QuizMode) -> QuizSession? {
        sessions
            .filter  { $0.mode == mode.rawValue }
            .max     { $0.percentage < $1.percentage }
    }

    // Fastest completion time for a given mode.
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
            .navigationTitle("Stats")
        }
    }

    // ── Hero row: streak + mastered ───────────────────────────────────────────
    private var heroRow: some View {
        HStack(spacing: 12) {
            heroCard(
                topText  : streak == 0 ? "—" : "\(streak)",
                label    : streak == 1 ? "Day Streak" : "Days Streak",
                icon     : "flame.fill",
                iconColor: streak > 0 ? .orange : .secondary
            )
            heroCard(
                topText  : "\(masteredCount)",
                label    : "of \(totalCountries) Mastered",
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
                // .contentTransition(.numericText()) animates number changes
                // by counting up/down digit-by-digit — feels alive when the
                // streak increments after a study session.
                // .animation(…, value: streak) triggers the spring whenever
                // the @AppStorage streak value changes.
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

                // Overall gold-badge row
                HStack(spacing: 10) {
                    Text("⭐")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Gold Badge")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(masteredCount) / \(totalCountries)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: Double(masteredCount), total: Double(totalCountries))
                            .tint(.yellow)
                    }
                }

                Divider()

                // Per-mode rows
                ForEach(QuizMode.allCases, id: \.self) { mode in
                    let count = masteredForMode(mode)
                    HStack(spacing: 8) {
                        Text(mode.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 140, alignment: .leading)
                        ProgressView(value: Double(count), total: Double(totalCountries))
                            .tint(AppColors.accent)
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 26, alignment: .trailing)
                    }
                }
            }
        } label: {
            Label("Mastery Breakdown", systemImage: "star.fill")
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
                Label("Personal Bests", systemImage: "trophy.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }

    private func bestRow(for mode: QuizMode) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(mode.rawValue)
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
            // Custom emoji empty state — warmer than the default system view.
            VStack(spacing: 16) {
                Text("🎯")
                    .font(.system(size: 72))
                Text("No Sessions Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Complete a quiz to see\nyour history here.")
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
                Label("Recent Sessions", systemImage: "clock.fill")
                    .foregroundStyle(.purple)
            }
        }
    }

    private func sessionRow(_ session: QuizSession) -> some View {
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
                Text(session.formattedTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
