// SettingsView.swift
// GeoExplorer
//
// A simple settings screen with two sections:
//   1. Daily Reminder — schedule a local notification at a chosen time.
//   2. Reset Progress — wipe all SwiftData records and streak data.
//
// ── New concepts ──────────────────────────────────────────────────────────────
//
//   @Environment(\.modelContext)
//     Gives this view write access to the SwiftData store. We call
//     `modelContext.delete(object)` on every item in the @Query arrays to
//     permanently remove them from the database.
//
//   .alert(isPresented:)
//     Presents a modal confirmation dialog. We use it before the destructive
//     "Reset" action so an accidental tap can't wipe the user's history.
//     The `role: .destructive` label turns the button text red, signalling
//     danger to the user — a standard iOS pattern.
//
//   UserDefaults.standard.removeObject(forKey:)
//     Deletes a key entirely from UserDefaults. Different from setting it
//     to 0: removeObject means the key won't exist, so any code that checks
//     "has the user studied before?" gets a clean slate.
//
//   forEach on a SwiftData @Query array
//     `sessions.forEach { modelContext.delete($0) }` is a compact shorthand
//     for looping over every session and deleting it. `$0` is Swift's
//     automatic name for the first closure argument.

import SwiftUI
import SwiftData

struct SettingsView: View {

    // ── Notification settings ─────────────────────────────────────────────────
    @AppStorage("geoexplorer.notificationsOn") private var notificationsOn = false
    @AppStorage("geoexplorer.reminderHour")    private var reminderHour    = 20
    @AppStorage("geoexplorer.reminderMinute")  private var reminderMinute  = 0

    // ── SwiftData — needed for the reset action ───────────────────────────────
    @Query private var sessions : [QuizSession]
    @Query private var progress : [CountryProgress]
    @Query private var favorites: [FavoriteCountry]
    @Environment(\.modelContext) private var modelContext

    // ── Local state ───────────────────────────────────────────────────────────
    @State private var showResetAlert = false

    // ── Reminder time binding ─────────────────────────────────────────────────
    // DatePicker expects a Binding<Date>, but we store hour and minute as two
    // separate @AppStorage Ints (so they're easy to read back when scheduling).
    // This computed binding bridges them: the getter rebuilds a Date from the
    // stored ints; the setter pulls the new hour/minute back out and saves them.
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
            Form {

                // ── Daily reminder ─────────────────────────────────────────────
                // The Toggle writes to @AppStorage "geoexplorer.notificationsOn".
                // .onChange fires whenever the value changes so we can request
                // permission on the first enable, or cancel when disabled.
                Section {
                    Toggle("Enable Daily Reminder", isOn: $notificationsOn)
                        .onChange(of: notificationsOn) { _, newValue in
                            if newValue {
                                NotificationManager.requestPermission { granted in
                                    if granted {
                                        NotificationManager.scheduleDailyReminder(
                                            hour: reminderHour, minute: reminderMinute)
                                    } else {
                                        // Permission denied — revert the toggle.
                                        notificationsOn = false
                                    }
                                }
                            } else {
                                NotificationManager.cancelReminder()
                            }
                        }

                    if notificationsOn {
                        DatePicker(
                            "Remind me at",
                            selection          : reminderTimeBinding,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Daily Reminder")
                }

                // ── Reset progress ─────────────────────────────────────────────
                // `role: .destructive` makes the button text red — iOS convention
                // for irreversible actions. The actual deletion happens in the
                // alert's confirmation handler, not here.
                Section {
                    Button("Reset All Progress", role: .destructive) {
                        showResetAlert = true
                    }
                } footer: {
                    Text("Permanently deletes all quiz sessions, mastery records, and saved favourites. Resets your streak to zero.")
                }

            }
            .navigationTitle("Settings")
            // Re-check notification permission each time the screen appears.
            // The user may have revoked permission in iOS Settings while the
            // app was in the background, so we sync the toggle.
            .onAppear {
                NotificationManager.checkAuthorisation { authorised in
                    if !authorised { notificationsOn = false }
                }
            }
            // ── Confirmation alert ─────────────────────────────────────────────
            // .alert is presented when showResetAlert becomes true.
            // The Reset button calls resetProgress(); Cancel does nothing.
            .alert("Reset All Progress?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) { resetProgress() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All quiz history, mastery records, and saved favourites will be permanently deleted. This cannot be undone.")
            }
        }
    }

    // ── Reset ──────────────────────────────────────────────────────────────────
    // Deletes every row from every model, then clears the UserDefaults keys
    // that store the streak counter and the last-study date.
    private func resetProgress() {
        sessions .forEach { modelContext.delete($0) }
        progress .forEach { modelContext.delete($0) }
        favorites.forEach { modelContext.delete($0) }
        UserDefaults.standard.removeObject(forKey: StreakManager.streakKey)
        UserDefaults.standard.removeObject(forKey: "geoexplorer.lastStudyDate")
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
#Preview {
    SettingsView()
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
