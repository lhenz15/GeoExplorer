// Continent.swift
// GeoExplorer
//
// A simple model for one continent entry loaded from continents-{lang}.json.
//
// ── Why a Continent model instead of a plain String array? ────────────────────
// The old code had `let continents = ["All", "Africa", ...]` hardcoded in every
// view that needed filtering.  A typed Continent gives us two things:
//
//   • id   — a stable, language-independent key (always English: "Africa", "all")
//            used for filtering country.continent and for UserDefaults storage.
//
//   • name — the localised display label (English: "Africa", Spanish: "África")
//            shown in pickers and continent filter pills.
//
// The id is the same across all languages, so a quiz started in English and
// a progress record stored in English both refer to "Africa" — no translation
// of stored data is ever needed.

import Foundation

struct Continent: Identifiable, Codable, Hashable {
    let id  : String   // stable key: "all" | "Africa" | "Americas" | "Asia" | "Europe" | "Oceania"
    let name: String   // localised display name
}
