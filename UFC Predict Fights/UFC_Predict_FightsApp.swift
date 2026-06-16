//
//  UFC_Predict_FightsApp.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 31/05/26.
//

import SwiftUI
import SwiftData
import BlackSpartan
import FirebaseCore

@main
struct UFC_Predict_FightsApp: App {

    let modelContainer: ModelContainer?
    let containerError: String?
    @State private var authViewModel: AuthViewModel

    init() {
        BSNetworkManager.shared.start()
        FirebaseApp.configure()
        authViewModel = AuthViewModel()
        do {
            modelContainer = try SwiftDataContainer.create()
            containerError = nil
        } catch {
            modelContainer = nil
            containerError = "Database initialization failed: \(error.localizedDescription)"
            print("[SwiftData] Unexpected error: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                ContentView()
                    .environment(authViewModel)
                    .modelContainer(container)
            } else {
                DatabaseErrorView(message: containerError ?? "Unknown error")
            }
        }
    }
}
