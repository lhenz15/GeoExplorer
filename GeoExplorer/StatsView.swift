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
    @AppStorage(StreakManager.streakKey)            private var streak           = 0
    @AppStorage("geoexplorer.notificationsOn")      private var notificationsOn  = false
    @AppStorage("geoexplorer.reminderHour")         private var reminderHour     = 20
    @AppStorage("geoexplorer.reminderMinute")       private var reminderMinute   = 0

    // ── Other state ───────────────────────────────────────────────────────────
    // Total countries loaded from JSON — used to show "X / 195" mastered.
    private let totalCountries = DataLoader.loadCountries().count

    // ── Derived values ────────────────────────────────────────────────────────
    private var masteredCount: Int {
        progress.filter { $0.isMastered }.count
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

    // ── Reminder time binding ─────────────────────────────────────────────────
    // A DatePicker needs a Binding<Date>, but we store the time as two
    // separate @AppStorage Ints (hour and minute) so they're easy to read back.
    //
    // `Binding { get } set: { }` lets us build a custom two-way bridge:
    //   • get: reconstruct a Date from the stored hour + minute
    //   • set: extract hour + minute from the new Date and save them back
    private var reminderTimeBinding: Binding<Date> {
        Binding {
            var c      = DateComponents()
            c.hour     = reminderHour
            c.minute   = reminderMinute
            return Calendar.current.date(from: c) ?? Date()
        } set: { newDate in
            let c      = Calendar.current.dateComponents([.hour, .minute], from: newDate)
            reminderHour   = c.hour   ?? 20
            reminderMinute = c.minute ?? 0
            if notificationsOn {
                NotificationManager.scheduleDailyReminder(
                    hour: reminderHour, minute: reminderMinute)
            }
        }
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    heroRow
                    personalBestsSection
                    reminderSection
                    historySection

                }
                .padding(16)
            }
            .navigationTitle("Stats")
            // When the view appears (or the app returns from background),
            // check whether the user revoked notification permission in Settings
            // and update the toggle accordingly.
            .onAppear {
                NotificationManager.checkAuthorisation { authorised in
                    if !authorised { notificationsOn = false }
                }
            }
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
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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

    // ── Daily reminder ────────────────────────────────────────────────────────
    private var reminderSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {

                // The toggle enables/disables the daily reminder.
                // `.onChange` fires when the value changes — we use it to
                // request permission (if first time) or cancel the notification.
                Toggle("Enable Daily Reminder", isOn: $notificationsOn)
                    .onChange(of: notificationsOn) { _, newValue in
                        if newValue {
                            NotificationManager.requestPermission { granted in
                                if granted {
                                    NotificationManager.scheduleDailyReminder(
                                        hour: reminderHour, minute: reminderMinute)
                                } else {
                                    // User denied permission — turn toggle back off.
                                    notificationsOn = false
                                }
                            }
                        } else {
                            NotificationManager.cancelReminder()
                        }
                    }

                // Only show the time picker when notifications are on.
                if notificationsOn {
                    DatePicker(
                        "Remind me at",
                        selection : reminderTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        } label: {
            Label("Daily Reminder", systemImage: "bell.fill")
                .foregroundStyle(.blue)
        }
    }

    // ── Session history ───────────────────────────────────────────────────────
    @ViewBuilder
    private var historySection: some View {
        if sessions.isEmpty {
            // Friendly empty state — shown until the first quiz is completed.
            ContentUnavailableView(
                "No Sessions Yet",
                systemImage: "chart.bar",
                description: Text("Complete a quiz to see your history here.")
            )
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
