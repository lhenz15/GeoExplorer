// Country.swift
// GeoExplorer
//
// The core data model.
//
// NEW: `Codable` conformance lets Swift automatically convert JSON ↔ Swift.
// `Codable` is actually a shorthand for two protocols combined:
//   • `Encodable` — Swift struct  →  JSON  (e.g. saving to disk)
//   • `Decodable` — JSON  →  Swift struct  (e.g. reading a file)
// We only need `Decodable` here, but `Codable` costs nothing extra and is
// more conventional when you might need both directions later.

import Foundation

struct Country: Identifiable, Codable {

    // `var` instead of `let` so Swift's synthesized Codable init can
    // assign the default value. Since `id` is NOT in CodingKeys below,
    // Swift simply calls UUID() for each country when decoding — it is
    // never read from the JSON file.
    var id = UUID()

    let name: String
    let capital: String
    let continent: String
    let flag: String
    let population: Int
    let area: Double
    let funFact: String
    let latitude: Double
    let longitude: Double

    // ── CodingKeys ────────────────────────────────────────────────────────
    // `CodingKeys` is an enum that tells Swift which JSON keys map to which
    // Swift properties. Two important things it does here:
    //
    // 1. Maps names: every case name must match a property name exactly
    //    (they already do, so no aliases are needed — but you could write
    //    `case funFact = "fun_fact"` to handle a snake_case JSON key).
    //
    // 2. Excludes `id`: because `id` is NOT listed, Swift leaves it alone
    //    during decoding and uses the default value `UUID()` instead.
    enum CodingKeys: String, CodingKey {
        case name, capital, continent, flag, population, area, funFact, latitude, longitude
    }
}
