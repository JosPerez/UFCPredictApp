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
import GoogleSignIn


@main
struct UFC_Predict_FightsApp: App {

    let modelContainer: ModelContainer?
    let containerError: String?
    @State private var authViewModel: AuthViewModel

    init() {
        // Inyecta la API key al pod antes de cualquier request
        BlackSpartanConfig.apiKey = Config.apiKey
        // Image Cached TTL 7 days
        ImageCacheManager.shared.clearExpired()
        // Start network monitoring
        BSNetworkManager.shared.start()
        // Start FirebaseApp
        FirebaseApp.configure()
        // Create auth view model
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
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .modelContainer(container)
            } else {
                DatabaseErrorView(message: containerError ?? "Unknown error")
            }
        }
    }
}
