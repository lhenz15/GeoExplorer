// QuizSetupView.swift
// GeoExplorer
//
// Screen 1: choose quiz mode, continent, and question count.
// Owns the NavigationStack and generates the QuizQuestion array.

import SwiftUI
import SwiftData

struct QuizSetupView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var lang: LanguageManager

    // ── SwiftData ─────────────────────────────────────────────────────────────
    @Query private var allProgress: [CountryProgress]

    // ── Settings ──────────────────────────────────────────────────────────────
    // @AppStorage reads/writes UserDefaults automatically.
    // When this is true, countries the user marked as 'known' are filtered out
    // of the question pool so they never appear as the correct answer.
    @AppStorage("excludeKnownCountries") private var excludeKnownCountries = false

    @State private var path: [QuizRoute] = []

    @State private var mode              : QuizMode = .flagToCountry
    @State private var selectedContinent : String   = "all"
    @State private var questionCount     : Int      = 10

    private let counts = [5, 10, 20, 0]   // 0 = All

    // Set of country ids (English) that the user has marked as 'known'.
    // Empty when the exclude toggle is off so no filtering happens.
    private var knownIds: Set<String> {
        guard excludeKnownCountries else { return [] }
        return Set(allProgress.filter { $0.isKnown }.map { $0.countryName })
    }

    // ── Derived values ────────────────────────────────────────────────────────
    private var availableCountries: [Country] {
        var pool = selectedContinent == "all"
            ? lang.countries
            : lang.countries.filter { $0.continent == selectedContinent }
        if mode == .mapToCountry {
            pool = pool.filter { ShapeLoader.shapeNames.contains($0.id) }
        }
        if !knownIds.isEmpty {
            pool = pool.filter { !knownIds.contains($0.id) }
        }
        return pool
    }

    private var actualCount: Int {
        questionCount == 0
            ? availableCountries.count
            : min(questionCount, availableCountries.count)
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack(path: $path) {
            Form {

                // ── Mode section ───────────────────────────────────────────
                Section(lang.t("quiz.setup.mode")) {
                    Picker("Mode", selection: $mode) {
                        ForEach(QuizMode.allCases, id: \.self) { m in
                            Text(m.localizedName(using: lang)).tag(m)
                        }
                    }
                }

                // ── Continent section ──────────────────────────────────────
                Section(lang.t("quiz.setup.continent")) {
                    Picker("Continent", selection: $selectedContinent) {
                        ForEach(lang.continents) { c in
                            Text(c.name).tag(c.id)
                        }
                    }
                }

                // ── Question count section ─────────────────────────────────
                Section(lang.t("quiz.setup.questions")) {
                    Picker("Questions", selection: $questionCount) {
                        ForEach(counts, id: \.self) { n in
                            Text(n == 0 ? lang.t("quiz.setup.all") : "\(n)").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ── Summary + Start ────────────────────────────────────────
                Section {
                    VStack(spacing: 14) {
                        HStack {
                            Label(lang.t("quiz.setup.questionsLabel"), systemImage: "questionmark.circle")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(actualCount)")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Label(lang.t("quiz.setup.region"), systemImage: "globe")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(lang.continentName(for: selectedContinent))
                                .fontWeight(.semibold)
                        }

                        Button {
                            path.append(.quiz(mode: mode, questions: generateQuestions()))
                        } label: {
                            Text(lang.t("quiz.setup.start"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(availableCountries.isEmpty)
                        .scaleOnPress()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(lang.t("quiz.title"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                }
            }

            // ── Navigation destinations ────────────────────────────────────
            .navigationDestination(for: QuizRoute.self) { route in
                switch route {
                case .quiz(let mode, let questions):
                    if mode == .mapToCountry {
                        MapQuizView(
                            questions    : questions,
                            mode         : mode,
                            continent    : selectedContinent,
                            questionCount: actualCount,
                            path         : $path
                        )
                        .id(questions.map { $0.id })
                    } else {
                        QuizView(
                            questions    : questions,
                            mode         : mode,
                            continent    : selectedContinent,
                            questionCount: actualCount,
                            path         : $path
                        )
                        .id(questions.map { $0.id })
                    }
                case .results(let score, let total, let mode, let questions, let continent, let questionCount):
                    QuizResultView(
                        score        : score,
                        total        : total,
                        mode         : mode,
                        questions    : questions,
                        continent    : continent,
                        questionCount: questionCount,
                        path         : $path
                    )
                }
            }
        }
    }

    // ── Question generation ────────────────────────────────────────────────────
    private func generateQuestions() -> [QuizQuestion] {
        QuizQuestion.generate(
            mode       : mode,
            continent  : selectedContinent,
            count      : questionCount,
            from       : lang.countries,
            excludedIds: knownIds
        )
    }
}

#Preview {
    QuizSetupView()
        .environmentObject(LanguageManager())
}
