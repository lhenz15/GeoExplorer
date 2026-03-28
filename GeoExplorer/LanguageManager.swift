// LanguageManager.swift
// GeoExplorer
//
// The single source of truth for localisation.  Every view reads its strings,
// countries, and continents from this one object instead of loading files
// independently.
//
// ── What is ObservableObject? ────────────────────────────────────────────────
// ObservableObject is a protocol that turns a class into something SwiftUI can
// "watch".  When you mark a property with @Published, any SwiftUI view that
// depends on that property will automatically re-render whenever the value
// changes — like a spreadsheet cell that updates when a referenced cell changes.
//
//   final class LanguageManager: ObservableObject {
//       @Published private(set) var countries: [Country] = []
//   }
//
// When switchLanguage(to:) calls reloadData() and assigns a new array to
// `countries`, every view that reads `lang.countries` instantly re-renders with
// the new localised data.  No manual "please refresh" calls needed.
//
// ── What is EnvironmentObject? ────────────────────────────────────────────────
// EnvironmentObject is how you share ONE instance of an ObservableObject with
// an entire view hierarchy without passing it to every single initialiser.
//
// Step 1 — inject at the root (GeoExplorerApp.swift):
//   @StateObject private var lang = LanguageManager()
//   ContentView().environmentObject(lang)
//
// Step 2 — receive in any descendant view:
//   @EnvironmentObject var lang: LanguageManager
//
// SwiftUI automatically finds the nearest LanguageManager in the environment
// and hands it to the view.  All views share the exact same instance, so when
// it publishes a change, every view updates simultaneously.
//
// ── @StateObject vs @EnvironmentObject ───────────────────────────────────────
// @StateObject creates and owns the object — use it exactly once, at the root.
// @EnvironmentObject receives a reference — use it in every child view.
// Think of @StateObject as the original copy and @EnvironmentObject as a
// pointer to that copy.

import Foundation
import Combine

final class LanguageManager: ObservableObject {

    // ── Keys ─────────────────────────────────────────────────────────────────
    static let languageKey = "geoexplorer.language"

    // ── Published state ───────────────────────────────────────────────────────
    // `private(set)` means anyone can read these, but only LanguageManager
    // can write them.  The `@Published` wrapper notifies all observing views
    // whenever the value changes.

    @Published private(set) var currentLanguage: String
    @Published private(set) var countries       : [Country]   = []
    @Published private(set) var continents      : [Continent] = []

    // ── Private storage ───────────────────────────────────────────────────────
    // translations.json is loaded once and cached here.
    // Structure: { "en": { "key": "value", … }, "es": { "key": "value", … } }
    private var translations: [String: [String: String]] = [:]

    // ── Initialiser ───────────────────────────────────────────────────────────
    init() {
        // 1. Restore the language the user picked last time, or detect the
        //    device language, defaulting to English if not Spanish.
        let saved = UserDefaults.standard.string(forKey: Self.languageKey)
        if let saved = saved {
            currentLanguage = saved
        } else {
            // Locale.current.language.languageCode?.identifier returns "en", "es", etc.
            let deviceCode = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = (deviceCode == "es") ? "es" : "en"
        }

        // 2. Load translations once — they contain both languages in one file.
        loadTranslations()

        // 3. Load the language-specific data arrays.
        reloadData()
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /// Returns the localised string for `key`, falling back to English, then
    /// the key itself if no match exists.
    ///
    /// Usage in a view:  Text(lang.t("quiz.result.great"))
    func t(_ key: String) -> String {
        translations[currentLanguage]?[key]
            ?? translations["en"]?[key]
            ?? key
    }

    /// Switches the active language, persists the choice, and reloads all data.
    /// Because `countries` and `continents` are @Published, every view that
    /// uses them will automatically re-render.
    func switchLanguage(to language: String) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: Self.languageKey)
        reloadData()
    }

    /// Returns the localised display name for a continent id.
    /// e.g. continentName(for: "Europe") → "Europe" (EN) or "Europa" (ES)
    func continentName(for id: String) -> String {
        continents.first { $0.id == id }?.name ?? id
    }

    /// Returns the localised display name for a QuizMode raw value string.
    /// Used in StatsView where session.mode is stored as the English raw value.
    func localizedModeName(_ rawValue: String) -> String {
        switch rawValue {
        case "Flag → Country":    return t("quiz.mode.flagToCountry")
        case "Country → Flag":    return t("quiz.mode.countryToFlag")
        case "Country → Capital": return t("quiz.mode.countryToCapital")
        case "Capital → Country": return t("quiz.mode.capitalToCountry")
        default:                  return rawValue
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private func loadTranslations() {
        guard
            let url  = Bundle.main.url(forResource: "translations", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let dict = try? JSONDecoder().decode([String: [String: String]].self, from: data)
        else { return }
        translations = dict
    }

    private func reloadData() {
        countries  = loadCountries()
        continents = loadContinents()
    }

    private func loadCountries() -> [Country] {
        let file = "countries-\(currentLanguage)"
        guard
            let url  = Bundle.main.url(forResource: file, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let list = try? JSONDecoder().decode([Country].self, from: data)
        else { return [] }
        return list.sorted { $0.name < $1.name }
    }

    private func loadContinents() -> [Continent] {
        let file = "continents-\(currentLanguage)"
        guard
            let url  = Bundle.main.url(forResource: file, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let list = try? JSONDecoder().decode([Continent].self, from: data)
        else { return [] }
        return list
    }
}

// ── QuizMode localised display name ───────────────────────────────────────────
// Placed here so it's co-located with the translation logic.
// The raw value is still the English string stored in the database — we only
// translate at display time, never at storage time.
extension QuizMode {
    func localizedName(using lang: LanguageManager) -> String {
        switch self {
        case .flagToCountry:    return lang.t("quiz.mode.flagToCountry")
        case .countryToFlag:    return lang.t("quiz.mode.countryToFlag")
        case .countryToCapital: return lang.t("quiz.mode.countryToCapital")
        case .capitalToCountry: return lang.t("quiz.mode.capitalToCountry")
        }
    }
}

// ── FlashcardMode localised display name ──────────────────────────────────────
extension FlashcardMode {
    func localizedName(using lang: LanguageManager) -> String {
        switch self {
        case .flagToCountry:    return lang.t("flashcard.mode.flagQuiz")
        case .countryToCapital: return lang.t("flashcard.mode.capitalQuiz")
        }
    }
}
