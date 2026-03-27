// CountryDetailView.swift
// GeoExplorer
//
// Shown when the user taps a country in the list.

import SwiftUI
import SwiftData
import MapKit

struct CountryDetailView: View {

    let country: Country

    @EnvironmentObject var lang: LanguageManager

    @State private var flagScale: CGFloat = 0.1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Header: flag + name ──────────────────────────────────
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text(country.flag)
                            .font(.system(size: 90))
                            .scaleEffect(flagScale)
                            .onAppear {
                                withAnimation(
                                    .spring(response: 0.5, dampingFraction: 0.5)
                                ) {
                                    flagScale = 1.0
                                }
                            }
                        Text(country.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text(lang.continentName(for: country.continent))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.top, 8)

                // ── Info cards grid ──────────────────────────────────────
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    InfoCard(icon: "building.2.fill",          title: lang.t("detail.capital"),    value: country.capital)
                    InfoCard(icon: "person.3.fill",            title: lang.t("detail.population"), value: formattedPopulation)
                    InfoCard(icon: "map.fill",                 title: lang.t("detail.area"),       value: formattedArea)
                    InfoCard(icon: "globe.europe.africa.fill", title: lang.t("detail.continent"),  value: lang.continentName(for: country.continent))
                }

                // ── Fun fact ─────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Label(lang.t("detail.funFact"), systemImage: "lightbulb.fill")
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
                VStack(alignment: .leading, spacing: 10) {
                    Label(lang.t("detail.capitalLocation"), systemImage: "mappin.and.ellipse")
                        .font(.headline)

                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: country.latitude,
                            longitude: country.longitude
                        ),
                        span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
                    ))) {
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
            .screenAppear()
        }
        .background(AppColors.background)
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                FavoriteButton(countryId: country.id)
            }
        }
    }

    // ── Computed helpers ─────────────────────────────────────────────────────
    private var formattedPopulation: String {
        country.population.formatted(.number) + " \(lang.t("detail.population.suffix"))"
    }

    private var formattedArea: String {
        if country.area < 1 {
            return String(format: "%.2f km²", country.area)
        } else {
            return Int(country.area).formatted(.number) + " km²"
        }
    }
}

// ── InfoCard helper ──────────────────────────────────────────────────────────
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// ── Preview ───────────────────────────────────────────────────────────────────
#Preview {
    NavigationStack {
        CountryDetailView(country: Country(
            id: "France",
            name: "France", capital: "Paris", continent: "Europe", flag: "🇫🇷",
            population: 68_000_000, area: 551_695,
            funFact: "France is the most visited country in the world, attracting over 90 million tourists per year.",
            latitude: 48.86, longitude: 2.35
        ))
    }
    .environmentObject(LanguageManager())
    .modelContainer(for: [FavoriteCountry.self, QuizSession.self, CountryProgress.self], inMemory: true)
}
