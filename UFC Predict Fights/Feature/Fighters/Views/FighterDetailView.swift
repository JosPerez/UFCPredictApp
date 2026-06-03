//
//  FighterDetailView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import SwiftUI
import BlackSpartan

struct FighterDetailView: View {
    let fighterId: Int
    @State private var viewModel: FighterDetailViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(fighterId: Int) {
        self.fighterId = fighterId
        _viewModel = State(initialValue: FighterDetailViewModel(fighterId: fighterId))
    }

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(Color(hex: "FF3B30"))
            } else if let error = viewModel.errorMessage {
                ErrorStateView(message: error) {
                    viewModel.retry(fighterId: fighterId)
                }
            } else if let profile = viewModel.profile {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection(profile)
                        recordSection(profile)
                        Divider().background(BSColors.surface).padding(.vertical, 12)
                        winMethodsSection(profile)
                        Divider().background(BSColors.surface).padding(.vertical, 12)
                        winRoundsSection(profile)
                        Divider().background(BSColors.surface).padding(.vertical, 12)
                        performanceSection(profile)
                        Divider().background(BSColors.surface).padding(.vertical, 12)
                        physicalSection(profile)
                        Divider().background(BSColors.surface).padding(.vertical, 12)
                        recentFightsSection(profile)
                        predictButton(profile)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Header

    @ViewBuilder
    private func headerSection(_ p: BSFighterProfile) -> some View {
        HStack(spacing: 14) {
            // Avatar con imagen o iniciales
            FighterAvatar(
                imageUrl: p.imgThumb,
                initials: p.initials,
                size: 60
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(p.fullName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                HStack(spacing: 6) {
                    if let wc = p.weightClass {
                        Text(wc)
                            .font(.system(size: 12))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    if p.isActive {
                        Text("Active")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "FF3B30"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "FF3B30").opacity(0.15))
                            .cornerRadius(4)
                    }
                    if p.currentStreak > 0 {
                        Text("\(p.currentStreak)W streak")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "34C759"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "34C759").opacity(0.15))
                            .cornerRadius(4)
                    } else if p.currentStreak < 0 {
                        Text("\(abs(p.currentStreak))L streak")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "FF3B30"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "FF3B30").opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                HStack(spacing: 12) {
                    if let style = p.fightingStyle {
                        Label(style, systemImage: "figure.martial.arts")
                            .font(.system(size: 10))
                            .foregroundColor(BSColors.textHint)
                    }
                    if let gym = p.trainsAt {
                        Label(gym, systemImage: "building.2")
                            .font(.system(size: 10))
                            .foregroundColor(BSColors.textHint)
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Record

    @ViewBuilder
    private func recordSection(_ p: BSFighterProfile) -> some View {
        HStack(spacing: 8) {
            StatCard(value: "\(p.recordWin)", label: "Wins", accent: true)
            StatCard(value: "\(p.recordLoss)", label: "Losses", accent: false)
            if let wr = p.winRate {
                StatCard(value: "\(Int(wr * 100))%", label: "Win rate", accent: true)
            }
            if let fr = p.finishRate {
                StatCard(value: "\(Int(fr * 100))%", label: "Finish", accent: false)
            }
        }
    }

    // MARK: - Win Methods

    @ViewBuilder
    private func winMethodsSection(_ p: BSFighterProfile) -> some View {
        let m = p.winMethods
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Victories by method")
            MethodBar(label: "KO/TKO", count: m.koTko, pct: m.koPct)
            MethodBar(label: "Submission", count: m.submission, pct: m.subPct)
            MethodBar(label: "Decision", count: m.decision, pct: m.decPct)
        }
    }

    // MARK: - Win Rounds

    @ViewBuilder
    private func winRoundsSection(_ p: BSFighterProfile) -> some View {
        let r = p.winRounds
        let maxVal = Double(max(r.r1, r.r2, r.r3, r.r4, r.r5, 1))
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Finishes by round")
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(
                    [("R1", r.r1), ("R2", r.r2), ("R3", r.r3), ("R4", r.r4), ("R5", r.r5)],
                    id: \.0
                ) { label, value in
                    VStack(spacing: 4) {
                        Text("\(value)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(value > 0 ? Color(hex: "FF3B30") : BSColors.textHint)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(value > 0 ? Color(hex: "FF3B30") : BSColors.surface)
                            .frame(height: max(CGFloat(Double(value) / maxVal) * 50, 4))
                        Text(label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
        }
    }

    // MARK: - Performance

    @ViewBuilder
    private func performanceSection(_ p: BSFighterProfile) -> some View {
        let s = p.performance
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Performance stats")
            if let v = s.sigStrikesLandedPm {
                StatBar(label: "Sig. strikes / min", value: v, max: 8.0)
            }
            if let v = s.sigStrikesAbsorbedPm {
                StatBar(label: "Sig. strikes absorbed", value: v, max: 8.0)
            }
            if let v = s.sigStrikeDefensePct {
                StatBar(label: "Strike defense", value: v * 100, max: 100, isPercent: true)
            }
            if let v = s.takedownAvg {
                StatBar(label: "Takedown avg", value: v, max: 6.0)
            }
            if let v = s.takedownDefensePct {
                StatBar(label: "TD defense", value: v * 100, max: 100, isPercent: true)
            }
            if let v = s.submissionAvg {
                StatBar(label: "Submission avg", value: v, max: 3.0)
            }
            if let v = s.knockdownAvg {
                StatBar(label: "Knockdown avg", value: v, max: 3.0)
            }
        }
    }

    // MARK: - Physical

    @ViewBuilder
    private func physicalSection(_ p: BSFighterProfile) -> some View {
        let ph = p.physical
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Physical")
            HStack(spacing: 8) {
                if let h = ph.heightInches {
                    PhysicalCard(value: formatHeight(h), label: "Height")
                }
                if let r = ph.reachInches {
                    PhysicalCard(value: "\(Int(r))\"", label: "Reach")
                }
                if let lr = ph.legReachInches {
                    PhysicalCard(value: "\(Int(lr))\"", label: "Leg reach")
                }
                if let a = ph.age {
                    PhysicalCard(value: "\(a)", label: "Age")
                }
            }
        }
    }

    // MARK: - Recent Fights

    @ViewBuilder
    private func recentFightsSection(_ p: BSFighterProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Recent fights")
            ForEach(p.recentFights) { fight in
                RecentFightRow(fight: fight)
            }
        }
    }

    // MARK: - Predict Button
    @MainActor
    @ViewBuilder
    private func predictButton(_ p: BSFighterProfile) -> some View {
        Button {
            coordinator.predictWithFighter(id: p.id)
        } label: {
            HStack {
                Image(systemName: "bolt.fill")
                Text("Predict with this fighter")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(BSColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(hex: "FF3B30"))
            .cornerRadius(10)
        }
        .padding(.top, 24)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(BSColors.textHint)
            .textCase(.uppercase)
            .kerning(1)
    }

    private func formatHeight(_ inches: Double) -> String {
        let feet = Int(inches) / 12
        let remaining = Int(inches) % 12
        return "\(feet)'\(remaining)\""
    }
}

// MARK: - Subcomponents

struct MethodBar: View {
    let label: String
    let count: Int
    let pct: Double

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "777777"))
                .frame(width: 80, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(BSColors.surface)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "FF3B30"))
                        .frame(width: geo.size.width * max(pct, 0.02))
                }
            }
            .frame(height: 6)
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "FF3B30"))
                .frame(width: 24, alignment: .trailing)
            Text("\(Int(pct * 100))%")
                .font(.system(size: 10))
                .foregroundColor(BSColors.textTertiary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct PhysicalCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(BSColors.textHint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(BSColors.surface)
        .cornerRadius(8)
    }
}

struct RecentFightRow: View {
    let fight: BSRecentFight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: result + method + title badge
            HStack {
                // Result badge
                Text(fight.result == "WIN" ? "W" : fight.result == "LOSS" ? "L" : "D")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .frame(width: 28, height: 28)
                    .background(
                        fight.result == "WIN"
                            ? Color(hex: "34C759")
                            : fight.result == "LOSS"
                                ? Color(hex: "FF3B30")
                                : BSColors.textTertiary
                    )
                    .cornerRadius(6)

                // Method badge
                if let method = fight.method {
                    Text(methodAbbr(method, round: fight.round))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isFinish(method) ? Color(hex: "FF3B30") : Color(hex: "888888"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            isFinish(method)
                                ? Color(hex: "FF3B30").opacity(0.12)
                                : BSColors.surfaceSecondary
                        )
                        .cornerRadius(5)
                }

                Spacer()

                if fight.isTitleFight {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 11))
                        Text("Title")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "FFD700"))
                }
            }

            // Opponent name
            Text(fight.opponentName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(BSColors.textPrimary)

            // Event + date
            Text(fight.eventName)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "777777"))
                .lineLimit(1)

            // Stats row
            HStack(spacing: 12) {
                if fight.knockdowns > 0 {
                    StatChip(
                        label: "KD",
                        value: "\(fight.knockdowns)",
                        accent: true
                    )
                }
            }
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    private func methodAbbr(_ method: String, round: Int?) -> String {
        let r = round.map { "R\($0)" } ?? ""
        return "\(method) \(r)".trimmingCharacters(in: .whitespaces)
    }

    private func isFinish(_ method: String) -> Bool {
        method == "KO/TKO" || method == "SUB"
    }
}

struct StatChip: View {
    let label: String
    let value: String
    let accent: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(BSColors.textTertiary)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(accent ? Color(hex: "FF3B30") : BSColors.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(BSColors.surfaceSecondary)
        .cornerRadius(6)
    }
}
