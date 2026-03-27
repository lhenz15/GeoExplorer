// SettingsView.swift
// GeoExplorer
//
// Settings screen with three sections:
//   1. Language     — switch between English and Spanish.
//   2. Daily Reminder — schedule a local notification at a chosen time.
//   3. Reset Progress — wipe all SwiftData records and streak data.

import SwiftUI
import SwiftData

struct SettingsView: View {

    @EnvironmentObject var lang: LanguageManager

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

                // ── Language section ───────────────────────────────────────────
                Section {
                    Button {
                        lang.switchLanguage(to: "en")
                    } label: {
                        HStack {
                            Text(lang.t("settings.language.english"))
                                .foregroundStyle(.primary)
                            Spacer()
                            if lang.currentLanguage == "en" {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }

                    Button {
                        lang.switchLanguage(to: "es")
                    } label: {
                        HStack {
                            Text(lang.t("settings.language.spanish"))
                                .foregroundStyle(.primary)
                            Spacer()
                            if lang.currentLanguage == "es" {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                    }
                } header: {
                    Text(lang.t("settings.language.header"))
                }

                // ── Daily reminder ─────────────────────────────────────────────
                Section {
                    Toggle(lang.t("settings.reminder.toggle"), isOn: $notificationsOn)
                        .onChange(of: notificationsOn) { _, newValue in
                            if newValue {
                                NotificationManager.requestPermission { granted in
                                    if granted {
                                        NotificationManager.scheduleDailyReminder(
                                            hour: reminderHour, minute: reminderMinute)
                                    } else {
                                        notificationsOn = false
                                    }
                                }
                            } else {
                                NotificationManager.cancelReminder()
                            }
                        }

                    if notificationsOn {
                        DatePicker(
                            lang.t("settings.reminder.at"),
                            selection          : reminderTimeBinding,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text(lang.t("settings.reminder.header"))
                }

                // ── Reset progress ─────────────────────────────────────────────
                Section {
                    Button(lang.t("settings.reset.button"), role: .destructive) {
                        showResetAlert = true
                    }
                } footer: {
                    Text(lang.t("settings.reset.footer"))
                }

            }
            .navigationTitle(lang.t("settings.title"))
            .onAppear {
                NotificationManager.checkAuthorisation { authorised in
                    if !authorised { notificationsOn = false }
                }
            }
            .alert(lang.t("settings.reset.alert.title"), isPresented: $showResetAlert) {
                Button(lang.t("settings.reset.confirm"), role: .destructive) { resetProgress() }
                Button(lang.t("settings.reset.cancel"), role: .cancel) {}
            } message: {
                Text(lang.t("settings.reset.alert.message"))
            }
        }
    }

    // ── Reset ──────────────────────────────────────────────────────────────────
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
        .environmentObject(LanguageManager())
        .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
