//
//  RankingsView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 05/06/26.
//

import SwiftUI
import BlackSpartan

@MainActor
struct RankingsView: View {
    // Variables
    let repository: RankingRepository
    // Environment
    @Environment(AuthViewModel.self) private var authVM
    // State
    @State private var showLogin = false
    @State private var viewModel: RankingsViewModel?
    @State private var path = NavigationPath()
    @State private var rankingType: RankingType = .ufc
    @State private var showProfile = false

    enum RankingType: String, CaseIterable {
        case ufc = "UFC"
        case elo = "Elo"
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                BSColors.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Title + segment
                    HStack {
                        Text("Rankings")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(BSColors.textPrimary)
                        Spacer()
                        ProfileButton(showProfile: $showProfile)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Toggle
                    HStack(spacing: 0) {
                        ForEach(RankingType.allCases, id: \.self) { type in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    rankingType = type
                                }
                            } label: {
                                Text(type.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(
                                        rankingType == type
                                        ? BSColors.textPrimary
                                        : BSColors.textTertiary
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        rankingType == type
                                        ? BSColors.accent
                                        : Color.clear
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(3)
                    .background(BSColors.surface)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    
                    // Content
                    switch rankingType {
                    case .ufc:
                        // Tu contenido actual de rankings UFC
                        if let viewModel {
                            content(viewModel)
                        }
                    case .elo:
                        EloRankingsView()
                    }
                }
                .navigationDestination(for: Int.self) { fighterId in
                    FighterDetailView(fighterId: fighterId)
                }
            }
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileSheetView()
            }
            .onChange(of: authVM.state) { _, newState in
                if newState == .unauthenticated {
                    path = NavigationPath()
                    showLogin = false
                }
                if newState == .authenticated {
                    showLogin = false
                    if let dest = authVM.completePendingNavigation() {
                        if case .fighterDetail(let id) = dest {
                            path.append(id)
                        }
                    }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = RankingsViewModel(repository: repository)
                }
            }
        }
    }

    @ViewBuilder
    private func content(_ vm: RankingsViewModel) -> some View {
        VStack(spacing: 0) {
            HStack {
                if vm.isSyncing {
                    ProgressView()
                        .tint(BSColors.accent)
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Division pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    DivisionPill(
                        title: "All",
                        isSelected: vm.selectedDivision == nil
                    ) {
                        vm.selectDivision(nil)
                    }
                    ForEach(vm.divisionNames, id: \.self) { name in
                        DivisionPill(
                            title: abbreviate(name),
                            isSelected: vm.selectedDivision == name
                        ) {
                            vm.selectDivision(name)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            // Content
            if vm.isLoading && vm.rankings.isEmpty {
                Spacer()
                ProgressView().tint(BSColors.accent)
                Spacer()
            } else if let error = vm.errorMessage {
                ErrorStateView(message: error) {
                    vm.loadFromCache()
                }
            } else if vm.groupedDivisions.isEmpty {
                EmptyStateView(message: "No rankings available")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(vm.groupedDivisions.enumerated()), id: \.element.id) { index, division in
                            divisionSection(division)
                                .opacity(vm.isLoading ? 0 : 1)
                                .offset(y: vm.isLoading ? 20 : 0)
                                .animation(
                                    .easeOut(duration: 0.4).delay(Double(index) * 0.08),
                                    value: vm.isLoading
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await vm.refresh()
                }
                .tint(BSColors.accent)
            }
        }
    }

    @ViewBuilder
    private func divisionSection(_ division: RankingsViewModel.DivisionGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(division.weightClass)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(BSColors.textTertiary)
                .textCase(.uppercase)
                .kerning(1)

            if let champion = division.champion {
                Button {
                    navigateToFighter(champion.fighterId)
                } label: {
                    championCard(champion)
                }
                .buttonStyle(.plain)
            }
            
            ForEach(division.ranked, id: \.fighterId) { fighter in
                Button {
                    navigateToFighter(fighter.fighterId)
                } label: {
                    rankedRow(fighter)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func championCard(_ fighter: CachedRanking) -> some View {
        HStack(spacing: 12) {
            FighterAvatar(
                imageUrl: fighter.imgThumb,
                initials: fighter.initials,
                size: 50,
                accentColor: BSColors.titleGold
            )
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11))
                        .foregroundColor(BSColors.titleGold)
                    Text("Champion")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BSColors.titleGold)
                }
                Text(fighter.fullName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Text("\(fighter.recordWin)W · \(fighter.recordLoss)L · \(fighter.recordDraw)D")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(BSColors.textHint)
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(BSColors.titleGold.opacity(0.3), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func rankedRow(_ fighter: CachedRanking) -> some View {
        HStack(spacing: 10) {
            Text("#\(fighter.rank)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 32, alignment: .center)
            FighterAvatar(
                imageUrl: fighter.imgThumb,
                initials: fighter.initials,
                size: 36
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(fighter.fullName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BSColors.textPrimary)
                    .lineLimit(1)
                Text("\(fighter.recordWin)W · \(fighter.recordLoss)L")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textTertiary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(BSColors.textHint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(BSColors.surface)
        .cornerRadius(10)
    }

    private func abbreviate(_ weightClass: String) -> String {
        let map: [String: String] = [
            "Heavyweight": "HW", "Light Heavyweight": "LHW",
            "Middleweight": "MW", "Welterweight": "WW",
            "Lightweight": "LW", "Featherweight": "FW",
            "Bantamweight": "BW", "Flyweight": "FLW",
            "Strawweight": "SW", "Women's Bantamweight": "W·BW",
            "Women's Flyweight": "W·FLW", "Women's Strawweight": "W·SW",
            "Women's Featherweight": "W·FW",
        ]
        return map[weightClass] ?? weightClass
    }
    
    // Helper
    private func navigateToFighter(_ id: Int) {
        if authVM.state == .authenticated {
            path.append(id)
        } else {
            authVM.pendingDestination = .fighterDetail(id)
            showLogin = true
        }
    }
}
