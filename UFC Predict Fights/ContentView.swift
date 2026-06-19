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
    @Environment(AuthViewModel.self) private var authVM
    @State private var coordinator = AppCoordinator()
    @State private var predictionViewModel: PredictionViewModel?
    @State private var themeManager = ThemeManager()
    @State private var showLaunch = true
    @State private var showLogin = false
    // Repos — initialized once
    @State private var syncManager: SyncManager?
    @State private var fighterRepo: FighterRepository?
    @State private var eventRepo: EventRepository?
    @State private var rankingRepo: RankingRepository?
    
    var body: some View {
        
        Group {
            switch authVM.state {
            case .requiresBiometricUnlock:
                BiometricUnlockView()
            case .requiresProfileCompletion:
                ProfileCompletionView()
            default:
                // Tu TabView existente
                mainTabView
            }
        }
        
    }
    
    @ViewBuilder
    private var mainTabView: some View {
        ZStack {
            if showLaunch {
                LaunchView()
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            TabView(selection: $coordinator.selectedTab) {
                if let fighterRepo {
                    FighterListView(repository: fighterRepo)
                        .tabItem {
                            Image(systemName: "figure.mixed.cardio")
                            Text("Fighters")
                        }
                        .tag(0)
                }
                
                if let eventRepo {
                    EventListView(repository: eventRepo)
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Events")
                        }
                        .tag(1)
                }
                
                if let rankingRepo {
                    RankingsView(repository: rankingRepo)
                        .tabItem {
                            Image(systemName: "trophy")
                            Text("Rankings")
                        }
                        .tag(2)
                }
                
                Group {
                    if authVM.state == .authenticated {
                        if let vm = predictionViewModel {
                            PredictionView(viewModel: vm)
                        }
                    } else {
                        lockedPredictView
                    }
                }
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Predict")
                }
                .tag(3)
                GameHomeView()
                    .tabItem {
                        Image(systemName: "gamecontroller.fill")
                        Text("Game")
                    }
                    .tag(4)
            }
            .tint(BSColors.accent)
            .animation(.easeInOut(duration: 0.2), value: coordinator.selectedTab)
            .environment(coordinator)
            .environment(themeManager)
            .opacity(showLaunch ? 0 : 1)
        }
        .preferredColorScheme(themeManager.current.colorScheme)
        .onAppear {
            if syncManager == nil {
                let sm = SyncManager(modelContext: modelContext)
                syncManager = sm
                fighterRepo = FighterRepository(modelContext: modelContext, syncManager: sm)
                eventRepo = EventRepository(modelContext: modelContext, syncManager: sm)
                rankingRepo = RankingRepository(modelContext: modelContext, syncManager: sm)
            }
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
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .onChange(of: authVM.state) { _, newState in
            if newState == .authenticated {
                showLogin = false
            }
        }
        .onChange(of: coordinator.selectedTab) { _, newTab in
            let screens = ["Fighters", "Events", "Rankings", "Predict", "Game"]
            if newTab < screens.count {
                CrashReporter.setScreen(screens[newTab])
            }
        }
    }
    
    @ViewBuilder
    private var lockedPredictView: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 44))
                    .foregroundColor(BSColors.textHint)

                Text("Sign in to predict fights")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(BSColors.textPrimary)

                Text("Get AI-powered predictions with winner probability, method, and duration forecasts")
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button {
                    showLogin = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                        Text("Sign In")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(BSColors.accent)
                    .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
