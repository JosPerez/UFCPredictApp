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
            let rankingRepo = RankingRepository(modelContext: modelContext, syncManager: syncManager)

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

                RankingsView(repository: rankingRepo)
                    .tabItem {
                        Image(systemName: "trophy")
                        Text("Rankings")
                    }
                    .tag(2)

                if let vm = predictionViewModel {
                    PredictionView(viewModel: vm)
                        .tabItem {
                            Image(systemName: "bolt.fill")
                            Text("Predict")
                        }
                        .tag(3)
                }
            }
            .tint(BSColors.accent)
            .animation(.easeInOut(duration: 0.2), value: coordinator.selectedTab)
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
