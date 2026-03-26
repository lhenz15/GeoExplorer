// CountryDetailView.swift
// GeoExplorer
//
// Shown when the user taps a country in the list.
// New concepts introduced here:
//   • MapKit  — Apple's mapping framework
//   • ScrollView — lets content taller than the screen scroll
//   • LazyVGrid — a grid that only renders visible cells (efficient)
//   • private struct — a helper view scoped to this file only

import SwiftUI
import MapKit   // gives us Map, Marker, MKCoordinateRegion, CLLocationCoordinate2D

struct CountryDetailView: View {

    // `let` (constant) because we never change the country on this screen.
    let country: Country

    var body: some View {
        // ScrollView makes the whole page scrollable — important when the
        // content (cards + map) is taller than the phone screen.
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Header: flag + name ──────────────────────────────────
                // `HStack { Spacer() ... Spacer() }` is a common SwiftUI
                // trick to centre content horizontally.
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text(country.flag)
                            .font(.system(size: 90))
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text(country.continent)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 8)

                // ── Info cards grid ──────────────────────────────────────
                // LazyVGrid splits the screen into equal columns.
                // `GridItem(.flexible())` means "take whatever space is available".
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    InfoCard(icon: "building.2.fill",        title: "Capital",    value: country.capital)
                    InfoCard(icon: "person.3.fill",          title: "Population", value: formattedPopulation)
                    InfoCard(icon: "map.fill",               title: "Area",       value: formattedArea)
                    InfoCard(icon: "globe.europe.africa.fill", title: "Continent", value: country.continent)
                }

                // ── Fun fact ─────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Label("Fun Fact", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Text(country.funFact)
                        .font(.body)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // ── Map ──────────────────────────────────────────────────
                // `Map` is SwiftUI's built-in map view (iOS 17+).
                // `initialPosition` sets where the camera starts.
                // `MKCoordinateRegion` defines the visible area:
                //   • `center` is the lat/long of the capital
                //   • `span` controls the zoom level — bigger numbers = more zoomed out
                VStack(alignment: .leading, spacing: 10) {
                    Label("Capital Location", systemImage: "mappin.and.ellipse")
                        .font(.headline)

                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: country.latitude,
                            longitude: country.longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
                    ))) {
                        // `Marker` drops a pin on the map at the capital's coordinates.
                        Marker(country.capital, coordinate: CLLocationCoordinate2D(
                            latitude: country.latitude,
                            longitude: country.longitude
                        ))
                    }
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(16)
        }
        // `.inline` keeps the title small in the nav bar (the big flag is the hero).
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
        // Place the heart button in the top-right corner of the nav bar.
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                FavoriteButton(countryName: country.name)
            }
        }
    }

    // ── Computed helpers ─────────────────────────────────────────────────────
    // These live inside the view struct but outside `body`.
    // Swift's `.formatted(.number)` adds thousands separators automatically.

    private var formattedPopulation: String {
        country.population.formatted(.number) + " people"
    }

    private var formattedArea: String {
        // Vatican is 0.44 km² — show decimals for tiny countries.
        if country.area < 1 {
            return String(format: "%.2f km²", country.area)
        } else {
            return Int(country.area).formatted(.number) + " km²"
        }
    }
}

// ── InfoCard helper ──────────────────────────────────────────────────────────
// `private` means only code in this file can use InfoCard.
// It's a self-contained mini-view, which is the SwiftUI way of keeping
// `body` readable by extracting repeated UI into small pieces.
private struct InfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                // `fixedSize` lets the text grow vertically instead of truncating.
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
// Xcode renders this in the Canvas without running the whole app.
#Preview {
    NavigationStack {
        CountryDetailView(country: Country(
            name: "France", capital: "Paris", continent: "Europe", flag: "🇫🇷",
            population: 68_000_000, area: 551_695,
            funFact: "France is the most visited country in the world, attracting over 90 million tourists per year.",
            latitude: 48.86, longitude: 2.35
        ))
    }
}
