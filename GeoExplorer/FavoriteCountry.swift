// FavoriteCountry.swift
// GeoExplorer
//
// The SwiftData model for a persisted favourite.
//
// ── What is SwiftData? ────────────────────────────────────────────────────────
// SwiftData is Apple's modern persistence framework (iOS 17+). It stores data
// in a SQLite database on the device so it survives app restarts.
// You describe *what* to save using plain Swift classes — SwiftData handles
// the database automatically. No SQL, no Core Data boilerplate.
//
// Three key pieces work together:
//
//   1. @Model          — marks a class as a database entity (one Swift class
//                        = one database table; one instance = one row).
//
//   2. .modelContainer — set on the App's WindowGroup. It creates (or opens)
//                        the SQLite file and makes the database available to
//                        every view in the app via the environment.
//
//   3. @Query          — a property wrapper that lives in a View. It fetches
//                        all rows of a given @Model type and keeps the array
//                        up to date automatically. Any insert or delete
//                        instantly re-renders the views that use @Query.
//
//   (There's also @Environment(\.modelContext), which is the "write channel":
//    you call modelContext.insert() and modelContext.delete() to change data.)

import SwiftData

// `@Model` is a Swift macro — it rewrites this class behind the scenes to
// add persistence. Think of it as saying "SwiftData, please store this."
//
// We use a `class` (not a struct) because SwiftData requires reference types
// so it can track and sync changes to individual objects.
@Model
class FavoriteCountry {

    // The only data we need to persist is the country name.
    // When we want the full country details (flag, population, etc.) we
    // look up the name in the JSON-loaded array — no need to duplicate data.
    var name: String

    init(name: String) {
        self.name = name
    }
}
