// ContentView.swift
// GeoExplorer
//
// The root view that Xcode wires up by default. We just hand off to
// CountryListView so the project entry point stays where Xcode expects it.

import SwiftUI

struct ContentView: View {
    var body: some View {
        CountryListView()
    }
}

#Preview {
    ContentView()
}
