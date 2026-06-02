//
//  ContentView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 31/05/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let syncManager = SyncManager(modelContext: modelContext)
        let fighterRepo = FighterRepository(modelContext: modelContext, syncManager: syncManager)
        let eventRepo   = EventRepository(modelContext: modelContext, syncManager: syncManager)

        TabView {
            //
            FighterListView(repository: fighterRepo)
                .tabItem {
                    Image(systemName: "figure.mixed.cardio")
                    Text("Fighters")
                }
            //
            EventListView(repository: eventRepo)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
            //
            PredictionView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Predict")
                }
        }
        .tint(Color(hex: "FF3B30"))
    }
}
#Preview {
    ContentView()
}
