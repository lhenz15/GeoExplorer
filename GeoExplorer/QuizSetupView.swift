// QuizSetupView.swift
// GeoExplorer
//
// Screen 1: choose quiz mode, continent, and question count.
// Owns the NavigationStack and generates the QuizQuestion array.

import SwiftUI

struct QuizSetupView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var lang: LanguageManager

    @State private var path: [QuizRoute] = []

    @State private var mode              : QuizMode = .flagToCountry
    @State private var selectedContinent : String   = "all"
    @State private var questionCount     : Int      = 10

    private let counts = [5, 10, 20]

    // ── Derived values ────────────────────────────────────────────────────────
    private var availableCountries: [Country] {
        selectedContinent == "all"
            ? lang.countries
            : lang.countries.filter { $0.continent == selectedContinent }
    }

    private var actualCount: Int {
        min(questionCount, availableCountries.count)
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
                            Text("\(n)").tag(n)
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
    private func generateQuestions() -> [QuizQuestion] {
        QuizQuestion.generate(
            mode     : mode,
            continent: selectedContinent,
            count    : questionCount,
            from     : lang.countries
        )
    }
}

#Preview {
    QuizSetupView()
        .environmentObject(LanguageManager())
}
