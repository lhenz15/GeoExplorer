// Country.swift
// GeoExplorer
//
// The core data model — now with an `id` field for stable cross-language identity.
//
// ── Why did `id` change from UUID to String? ──────────────────────────────────
// Previously `id` was a UUID generated fresh at decode time (not in the JSON).
// This worked fine when there was only one language, but with localisation we
// need a stable key that is the same regardless of which language file is loaded.
//
// The new `id` is the English country name (e.g. "France") decoded directly
// from the JSON.  Every other system that stores a country reference — the
// SwiftData CountryProgress.countryName, FavoriteCountry.name, and the
// ShapeLoader dictionary — already uses the English name as its key.  Making
// Country.id match that convention means zero migration and O(1) lookups.
//
// ── How does Codable work now? ────────────────────────────────────────────────
// All properties are declared with `let` and have the same name as the JSON keys,
// so Swift's automatic Codable synthesis handles everything.  No CodingKeys enum,
// no custom init(from:) needed — just declare the struct and Swift does the rest.

import Foundation

struct Country: Identifiable, Codable, Hashable {

    // Stable English name — same in every language file.
    // Used as the primary key for ShapeLoader, CountryProgress, and FavoriteCountry.
    let id        : String

    // Localised fields — change when the active language changes.
    let name      : String
    let capital   : String
    let continent : String   // continent id: "Africa" | "Americas" | "Asia" | "Europe" | "Oceania"
    let flag      : String
    let population: Int
    let area      : Double
    let funFact   : String
    let latitude  : Double
    let longitude : Double
}
