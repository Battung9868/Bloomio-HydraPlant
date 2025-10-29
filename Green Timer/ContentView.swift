//
//  ContentView.swift
//  Green Timer
//
//  Created by Садыг Садыгов on 25.10.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PlantViewModel()
    
    var body: some View {
            TabView {
                HomeView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                JournalView(viewModel: viewModel)
                    .tabItem {
                        Label("Journal", systemImage: "book.fill")
                    }

                SettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        .tint(Color(red: 0.45, green: 0.82, blue: 0.52))
        .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
