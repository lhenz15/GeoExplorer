// Country.swift
// GeoExplorer
//
// The core data model for the app.

import Foundation

// A `struct` is a value type — think of it like a blueprint for a data record.
// `Identifiable` means every Country has a unique `id`, which SwiftUI needs
// to efficiently update lists without reloading everything.
struct Country: Identifiable {
    // `UUID()` auto-generates a unique ID each time a Country is created.
    let id = UUID()
    let name: String
    let capital: String
    let continent: String
    let flag: String   // Flag emoji, e.g. "🇫🇷"
}
