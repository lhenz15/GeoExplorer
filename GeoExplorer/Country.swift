// Country.swift
// GeoExplorer
//
// The core data model. Adding fields here means CountryData.swift must
// supply values for every country — Swift will refuse to compile otherwise.

import Foundation

struct Country: Identifiable {
    let id = UUID()
    let name: String
    let capital: String
    let continent: String
    let flag: String        // Flag emoji, e.g. "🇫🇷"
    let population: Int     // Approximate current population
    let area: Double        // Land area in km²
    let funFact: String     // One interesting fact shown on the detail screen
    let latitude: Double    // Capital city latitude  (positive = North)
    let longitude: Double   // Capital city longitude (positive = East)
}
