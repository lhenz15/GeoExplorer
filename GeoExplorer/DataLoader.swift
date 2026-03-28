// DataLoader.swift
// GeoExplorer
//
// Responsible for finding `countries.json` inside the app bundle,
// reading its raw bytes, and decoding them into [Country].
//
// Concepts introduced here:
//   • Bundle      — the package of files shipped with your app
//   • Data        — raw bytes (the JSON text as binary)
//   • JSONDecoder — converts raw JSON bytes → Swift structs
//   • fatalError  — crashes with a clear message during development
//                   (fine for programmer errors like a missing file)

import Foundation

enum DataLoader {

    // `static` means you call this as `DataLoader.loadCountries()` without
    // creating an instance — same pattern as `CountryData.all` was before.
    static func loadCountries() -> [Country] {

        // ── Step 1: Find the file ─────────────────────────────────────────
        // `Bundle.main` is the container that holds everything your app ships
        // with — Swift source (compiled), images, sounds, and JSON files.
        // `url(forResource:withExtension:)` searches the bundle for
        // "countries.json" and returns its file path, or nil if not found.
        guard let url = Bundle.main.url(forResource: "countries-en", withExtension: "json") else {
            fatalError("""
                countries-en.json not found in the app bundle.
                Make sure the file is inside the GeoExplorer/ folder in Xcode.
                """)
        }

        // ── Step 2: Read the raw bytes ────────────────────────────────────
        // `Data(contentsOf:)` reads the file from disk and returns the raw
        // bytes. JSON is just text, so this gives us all the characters in
        // the file as a blob of bytes that we can then decode.
        // `try?` converts a throwing call into an Optional — if reading fails
        // we get nil instead of a crash, and the `guard` handles it.
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not read countries-en.json from disk.")
        }

        // ── Step 3: Decode JSON → [Country] ──────────────────────────────
        // `JSONDecoder` is the translator. It reads the raw bytes and uses
        // the `Codable` conformance on `Country` to build Swift objects.
        //
        // `[Country].self` is how you pass a Swift type as a value — it says
        // "I expect an array of Country objects at the top level of this JSON."
        //
        // By default, JSONDecoder expects camelCase keys (like "funFact"),
        // which matches our JSON exactly, so no extra configuration needed.
        guard let countries = try? JSONDecoder().decode([Country].self, from: data) else {
            fatalError("Failed to decode countries-en.json — check that the JSON is valid and matches the Country struct.")
        }

        // Sort alphabetically by name so the list is always consistent.
        return countries.sorted { $0.name < $1.name }
    }
}
