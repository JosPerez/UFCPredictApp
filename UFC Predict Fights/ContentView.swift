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
    @State private var predictionViewModel = PredictionViewModel()

    var body: some View {
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

            PredictionView(viewModel: predictionViewModel)
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Predict")
                }
                .tag(2)
        }
        .tint(Color(hex: "FF3B30"))
        .environment(coordinator)
        .onAppear {
            coordinator.configure(
                modelContext: modelContext,
                predictionViewModel: predictionViewModel
            )
        }
    }
}

#Preview {
    ContentView()
}
