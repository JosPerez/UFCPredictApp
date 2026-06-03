//
//  FighterListView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import SwiftUI
import BlackSpartan

@MainActor
struct FighterListView: View {

    let repository: FighterRepository
    @State private var viewModel: FighterListViewModel?
    @State private var path = NavigationPath()
    @State private var showSettings = false
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                BSColors.background.ignoresSafeArea()

                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView().tint(Color(hex: "FF3B30"))
                }
            }
            .navigationDestination(for: Int.self) { fighterId in
                FighterDetailView(fighterId: fighterId)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = FighterListViewModel(repository: repository)
            }
        }
    }

    @ViewBuilder
    private func content(_ vm: FighterListViewModel) -> some View {
        VStack(spacing: 0) {
            // Nav title
            HStack {
                Text("Fighters")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(BSColors.textTertiary)
                }
                // Sync indicator
                if vm.isSyncing {
                    HStack(spacing: 4) {
                        ProgressView()
                            .tint(Color(hex: "FF3B30"))
                            .scaleEffect(0.7)
                        if let progress = vm.syncProgress {
                            Text(progress)
                                .font(.system(size: 9))
                                .foregroundColor(BSColors.textTertiary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(BSColors.textHint)
                    .font(.system(size: 16))
                TextField("", text: Bindable(vm).searchText)
                    .placeholder(when: vm.searchText.isEmpty) {
                        Text("Search fighter...").foregroundColor(BSColors.textHint)
                    }
                    .foregroundColor(BSColors.textPrimary)
                    .font(.system(size: 14))
                if !vm.searchText.isEmpty {
                    Button {
                        vm.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(BSColors.textHint)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(BSColors.surface)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 10)

            // Division pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    DivisionPill(
                        title: "All",
                        isSelected: vm.selectedWeightClass == nil
                    ) {
                        vm.selectWeightClass(nil)
                    }
                    ForEach(weightClasses, id: \.self) { wc in
                        DivisionPill(
                            title: abbreviate(wc),
                            isSelected: vm.selectedWeightClass == wc
                        ) {
                            vm.selectWeightClass(wc)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            // Count label
            HStack {
                Text("\(vm.fighterCount) fighters")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(BSColors.textHint)
                    .textCase(.uppercase)
                    .kerning(1)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)

            // List
            if vm.isLoading && vm.fighters.isEmpty {
                Spacer()
                ProgressView()
                    .tint(Color(hex: "FF3B30"))
                Spacer()
            } else if let error = vm.errorMessage {
                ErrorStateView(message: error) {
                    vm.reload()
                }
            } else if vm.fighters.isEmpty {
                EmptyStateView(message: "No fighters found")
            } else {
                List {
                    ForEach(vm.fighters, id: \.fighterId) { fighter in
                        NavigationLink(value: fighter.fighterId) {
                            FighterRow(fighter: fighter)
                        }
                        .listRowBackground(BSColors.background)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: 3, leading: 16, bottom: 3, trailing: 16
                        ))
                        .onAppear {
                            vm.loadMore(currentItem: fighter)
                        }
                    }
                    if vm.isLoading {
                        HStack {
                            Spacer()
                            ProgressView().tint(Color(hex: "FF3B30"))
                            Spacer()
                        }
                        .listRowBackground(BSColors.background)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await vm.refresh()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsSheet()
                }
            }
        }
    }

    private func abbreviate(_ weightClass: String) -> String {
        let map: [String: String] = [
            "Heavyweight": "HW", "Light Heavyweight": "LHW",
            "Middleweight": "MW", "Welterweight": "WW",
            "Lightweight": "LW", "Featherweight": "FW",
            "Bantamweight": "BW", "Flyweight": "FLW",
            "Strawweight": "SW", "Women's Bantamweight": "W·BW",
            "Women's Flyweight": "W·FLW", "Women's Strawweight": "W·SW"
        ]
        return map[weightClass] ?? weightClass
    }
}

