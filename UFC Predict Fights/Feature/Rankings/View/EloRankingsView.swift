//
//  EloRankingsView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 14/06/26.
//

import SwiftUI
import BlackSpartan

struct EloRankingsView: View {
    @State private var viewModel = EloRankingsViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            // Division pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.divisions, id: \.self) { division in
                        Button {
                            viewModel.selectDivision(division)
                        } label: {
                            Text(shortName(division))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(
                                    viewModel.selectedDivision == division
                                        ? BSColors.textPrimary
                                        : BSColors.textTertiary
                                )
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.selectedDivision == division
                                        ? BSColors.accent
                                        : BSColors.surface
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 10)

            if viewModel.isLoading {
                Spacer()
                ProgressView().tint(BSColors.accent)
                Spacer()
            } else if viewModel.rankings.isEmpty {
                Spacer()
                Text("No Elo data available")
                    .font(.system(size: 14))
                    .foregroundColor(BSColors.textTertiary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(viewModel.rankings) { entry in
                            eloRow(entry)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            viewModel = EloRankingsViewModel(modelContext: modelContext)
            if viewModel.rankings.isEmpty {
                viewModel.fetch()
            }
        }
    }

    // MARK: - Row

    @ViewBuilder
    private func eloRow(_ entry: CachedEloRanking) -> some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(entry.rank)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(rankColor(entry.rank))
                .frame(width: 28, alignment: .center)

            // Avatar
            FighterAvatar(
                imageUrl: entry.imgThumb,
                initials: initials(entry.fighterName),
                size: 36,
                accentColor: BSColors.accent
            )

            // Name + record + division
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.fighterName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BSColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .layoutPriority(1)

                HStack(spacing: 6) {
                    if let record = entry.record {
                        Text(record)
                            .font(.system(size: 11))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    if viewModel.selectedDivision == "All", let wc = entry.weightClass {
                        Text(shortName(wc))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(BSColors.accentBlue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(BSColors.accentBlue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            // Elo score
            HStack(spacing: 4) {
                Text(String(format: "%.0f", entry.elo))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(eloColor(entry.elo))
                Image(systemName: eloTrend(entry.elo))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(eloColor(entry.elo))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(eloColor(entry.elo).opacity(0.1))
            .cornerRadius(8)
            
        }
        .padding(12)
        .background(BSColors.surface)
        .cornerRadius(10)
    }

    // MARK: - Helpers

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return BSColors.titleGold
        case 2, 3: return BSColors.accent
        default: return BSColors.textTertiary
        }
    }

    private func eloColor(_ elo: Double) -> Color {
        if elo >= 1700 { return BSColors.titleGold }
        if elo >= 1600 { return BSColors.winGreen }
        if elo >= 1500 { return BSColors.textPrimary }
        return BSColors.textTertiary
    }
    
    private func eloTrend(_ elo: Double) -> String {
        if elo >= 1700 { return "flame.fill" }
        if elo >= 1600 { return "arrow.up.right" }
        if elo >= 1500 { return "minus" }
        return "arrow.down.right"
    }

    private func shortName(_ division: String) -> String {
        let map: [String: String] = [
            "All": "All",
            "Flyweight": "FLW",
            "Bantamweight": "BW",
            "Featherweight": "FW",
            "Lightweight": "LW",
            "Welterweight": "WW",
            "Middleweight": "MW",
            "Light Heavyweight": "LHW",
            "Heavyweight": "HW",
            "Women's Strawweight": "W·SW",
            "Women's Flyweight": "W·FLW",
            "Women's Bantamweight": "W·BW",
        ]
        return map[division] ?? division
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.last?.prefix(1) ?? ""
        return "\(f)\(l)"
    }
}
