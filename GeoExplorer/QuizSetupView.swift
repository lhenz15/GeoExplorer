// QuizSetupView.swift
// GeoExplorer
//
// Screen 1: choose quiz mode, continent, and question count.
// Owns the NavigationStack and generates the QuizQuestion array.

import SwiftUI

struct QuizSetupView: View {

    // ── Dismiss ───────────────────────────────────────────────────────────────
    // Closes the fullScreenCover when the user taps the × button.
    @Environment(\.dismiss) private var dismiss

    // ── Navigation state ──────────────────────────────────────────────────────
    @State private var path: [QuizRoute] = []

    // ── Setup selections ──────────────────────────────────────────────────────
    @State private var mode              : QuizMode = .flagToCountry
    @State private var selectedContinent : String   = "All"
    @State private var questionCount     : Int      = 10

    // ── Data ──────────────────────────────────────────────────────────────────
    private let countries  = DataLoader.loadCountries()
    private let continents = ["All", "Africa", "Americas", "Asia", "Europe", "Oceania"]
    private let counts     = [5, 10, 20]

    // ── Derived values ────────────────────────────────────────────────────────
    private var availableCountries: [Country] {
        selectedContinent == "All"
            ? countries
            : countries.filter { $0.continent == selectedContinent }
    }

    // Clamp to pool size so we never ask for more questions than countries exist.
    private var actualCount: Int {
        min(questionCount, availableCountries.count)
    }

    // ── Body ──────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationStack(path: $path) {
            Form {

                // ── Mode section ───────────────────────────────────────────
                // 4 options → default Form Picker style (taps to a sub-list)
                // is cleaner than .segmented for more than 2-3 choices.
                Section("Quiz Mode") {
                    Picker("Mode", selection: $mode) {
                        ForEach(QuizMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                }

                // ── Continent section ──────────────────────────────────────
                Section("Continent") {
                    Picker("Continent", selection: $selectedContinent) {
                        ForEach(continents, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                }

                // ── Question count section ─────────────────────────────────
                Section("Number of Questions") {
                    Picker("Questions", selection: $questionCount) {
                        ForEach(counts, id: \.self) { n in
                            Text("\(n)").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ── Summary + Start ────────────────────────────────────────
                Section {
                    VStack(spacing: 14) {
                        HStack {
                            Label("Questions", systemImage: "questionmark.circle")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(actualCount)")
                                .fontWeight(.semibold)
                        }
                        HStack {
                            Label("Region", systemImage: "globe")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(selectedContinent)
                                .fontWeight(.semibold)
                        }

                        Button {
                            path.append(.quiz(mode: mode, questions: generateQuestions()))
                        } label: {
                            Text("Start Quiz")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(availableCountries.isEmpty)
                        // scaleOnPress() adds a spring scale-down on press
                        // so the button gives instant tactile feedback.
                        .scaleOnPress()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Quiz")
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
                    // ── .id() explained ────────────────────────────────────
                    // SwiftUI's .id(_:) tags a view with an identity value.
                    // When the value changes, SwiftUI treats this as a brand-new
                    // view: it destroys the old one (resetting all @State vars
                    // to their defaults) and mounts a fresh instance.
                    //
                    // Without .id(), NavigationStack notices that path[0] is
                    // still a .quiz case and keeps the existing QuizView alive,
                    // just updating its `questions` let-property.  All @State
                    // vars — currentIndex, score, isShowingFeedback — stay at
                    // whatever they were when the previous round ended.
                    //
                    // questions.map { $0.id } produces a [UUID] whose value
                    // is unique for every new quiz round (Play Again creates
                    // fresh QuizQuestion instances with new UUIDs).
                    QuizView(
                        questions    : questions,
                        mode         : mode,
                        continent    : selectedContinent,
                        questionCount: actualCount,
                        path         : $path
                    )
                    .id(questions.map { $0.id })
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
    // Delegates to the static generator in Quiz.swift so QuizResultView
    // (Play Again) can produce a fresh batch with the exact same logic.
    private func generateQuestions() -> [QuizQuestion] {
        QuizQuestion.generate(mode: mode, continent: selectedContinent, count: questionCount)
    }
}

#Preview {
    QuizSetupView()
}
