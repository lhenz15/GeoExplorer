# 🌍 GeoExplorer

An iOS app for studying world countries, their capitals, and flags — built with SwiftUI.

## Features

### Part 1 — Country List
- Browse all ~195 world countries in a clean, scrollable list
- Each row shows the flag emoji, country name, and capital city
- **Search bar** — filter by country name or capital in real time
- **Continent filter pills** — quickly narrow the list to Africa, Americas, Asia, Europe, or Oceania

### Part 2 — Country Detail View
- Tap any country to open a full detail screen
- Large flag emoji header
- Info cards showing capital, population, area (km²), and continent
- Fun fact about each country
- Live **MapKit map** centred on the capital city with a pin marker

### Part 3 — JSON Data Layer
- Country data moved from a hardcoded Swift array to a bundled `countries.json` file
- `DataLoader` reads and decodes the JSON using Swift's `Codable` protocol

### Part 4 — Flashcard Study Mode
- **Tab bar** navigation — Countries and Flashcards tabs
- **Setup screen** — choose mode, continent filter, and card count with pickers
- **Two study modes:** Flag → Country name, or Country → Capital city
- **3D flip animation** — tap a card to reveal the answer with a spring-animated Y-axis rotation
- **Previous / Next navigation** — move freely through the deck
- **Results screen** — study the same set again or return to setup

## Tech Stack

- **SwiftUI** — declarative UI framework
- **MapKit** — embedded interactive maps
- **Codable / JSONDecoder** — JSON data loading
- **Swift** — no external dependencies
- Requires **iOS 17+**

## Project Structure

```
GeoExplorer/
├── GeoExplorerApp.swift        # App entry point
├── ContentView.swift           # Root TabView
├── Country.swift               # Data model (Codable)
├── CountryData.swift           # Retired placeholder
├── countries.json              # Bundled country data (~195 countries)
├── DataLoader.swift            # JSON → [Country] via Codable
├── CountryListView.swift       # List with search and continent filter
├── CountryDetailView.swift     # Detail screen with info cards and map
├── Flashcard.swift             # Flashcard model + route enum
├── FlashcardSetupView.swift    # Study mode setup (mode, continent, count)
├── FlashcardView.swift         # Card session with 3D flip animation
└── FlashcardResultView.swift   # End-of-session results
```

## Screenshots

> _Coming soon_

## Roadmap

- [x] Flag quiz mode
- [x] Capital quiz mode
- [ ] Score tracking (mark cards as known/unknown)
- [ ] Progress persistence
