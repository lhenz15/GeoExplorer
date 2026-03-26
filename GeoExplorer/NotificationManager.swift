// NotificationManager.swift
// GeoExplorer
//
// Static helpers for scheduling local push notifications.
//
// ── What is UNUserNotificationCenter? ────────────────────────────────────────
// iOS requires explicit user permission before showing notifications.
// `UNUserNotificationCenter` (from the UserNotifications framework) is the
// singleton that manages this:
//
//   Step 1 — Request permission.
//     iOS shows a system dialog ("Allow GeoExplorer to send notifications?").
//     This dialog only appears ONCE. After that iOS remembers the choice.
//
//   Step 2 — Build the content.
//     `UNMutableNotificationContent` holds the title, body text, and sound.
//
//   Step 3 — Choose a trigger.
//     `UNCalendarNotificationTrigger` fires at a specific hour:minute every day.
//     `UNTimeIntervalNotificationTrigger` fires after N seconds (useful for testing).
//
//   Step 4 — Create and register a request.
//     `UNNotificationRequest` bundles content + trigger with a unique string ID.
//     The ID lets you cancel or replace a specific notification later.
//
// All UNUserNotificationCenter calls use completion handlers because they talk
// to iOS daemons — they can't return values synchronously.

import UserNotifications

struct NotificationManager {

    // ── Permission ────────────────────────────────────────────────────────────

    /// Shows the system permission dialog (first call only).
    /// `completion` is called on the main thread with `true` if granted.
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]
        ) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    /// Checks the current authorisation status without showing a dialog.
    /// Useful for syncing the UI toggle when the app returns from background.
    static func checkAuthorisation(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    // ── Scheduling ────────────────────────────────────────────────────────────

    /// Cancels any existing daily reminder and schedules a new one.
    static func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        // Remove the previous request so we never accumulate duplicates.
        center.removePendingNotificationRequests(withIdentifiers: ["geoexplorer.daily"])

        let content      = UNMutableNotificationContent()
        content.title    = "Time to explore! 🌍"
        content.body     = motivatingMessages.randomElement()!
        content.sound    = .default

        // `DateComponents` lets us specify "fire at 20:00 every day".
        // Omitting the year/month/day means it repeats daily.
        var components   = DateComponents()
        components.hour  = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "geoexplorer.daily",
            content   : content,
            trigger   : trigger
        )
        center.add(request)
    }

    static func cancelReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["geoexplorer.daily"])
    }

    // ── Content ───────────────────────────────────────────────────────────────
    private static let motivatingMessages = [
        "How many capitals can you name today?",
        "A country a day keeps ignorance away!",
        "Your geography streak is waiting for you! 🔥",
        "Ready to master more countries?",
        "Can you beat yesterday's score?",
        "The world is waiting — time to explore! 🌍",
        "Keep that streak alive! Open GeoExplorer now.",
    ]
}
