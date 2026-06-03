//
//  ContentView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 31/05/26.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var coordinator = AppCoordinator()
    @State private var predictionViewModel: PredictionViewModel?
    @State private var themeManager = ThemeManager()
    @State private var showLaunch = true
    @State private var showSettings = false

    var body: some View {
        ZStack {
            if showLaunch {
                LaunchView()
                    .transition(.opacity)
                    .zIndex(1)
            }

            let syncManager = SyncManager(modelContext: modelContext)
            let fighterRepo = FighterRepository(modelContext: modelContext, syncManager: syncManager)
            let eventRepo   = EventRepository(modelContext: modelContext, syncManager: syncManager)

            TabView(selection: $coordinator.selectedTab) {
                FighterListView(repository: fighterRepo)
                    .tabItem {
                        Image(systemName: "figure.mixed.cardio")
                        Text("Fighters")
                    }
                    .tag(0)

                EventListView(repository: eventRepo)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Events")
                    }
                    .tag(1)

                if let vm = predictionViewModel {
                    PredictionView(viewModel: vm)
                        .tabItem {
                            Image(systemName: "bolt.fill")
                            Text("Predict")
                        }
                        .tag(2)
                }
            }
            .tint(BSColors.accent)
            .environment(coordinator)
            .environment(themeManager)
            .opacity(showLaunch ? 0 : 1)
        }
        .preferredColorScheme(themeManager.current.colorScheme)
        .onAppear {
            if predictionViewModel == nil {
                predictionViewModel = PredictionViewModel(modelContext: modelContext)
            }
            coordinator.configure(
                modelContext: modelContext,
                predictionViewModel: predictionViewModel!
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showLaunch = false
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .environment(themeManager)
                .preferredColorScheme(themeManager.current.colorScheme)
        }
    }
}

#Preview {
    ContentView()
}
