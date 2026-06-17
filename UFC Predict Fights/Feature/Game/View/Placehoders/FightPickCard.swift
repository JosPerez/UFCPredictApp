//
//  FightPickCard.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct FightPickCard: View {
    let fight: GameFightDTO
    let pick: FightPickDTO?
    let score: FightScoreDTO?
    let saveState: EventPicksViewModel.SaveState
    let isLocked: Bool
    let isScored: Bool
    let onPickChanged: (Int, String?, Int?) -> Void

    @State private var selectedWinner: Int? = nil
    @State private var selectedMethod: String? = nil
    @State private var selectedRound: Int? = nil
    @State private var initialized = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: names + badge
            header

            // Winner selection
            winnerPicker

            // Method (visible after winner selected)
            if selectedWinner != nil {
                methodPicker
            }

            // Round (visible if method is KO_TKO or SUBMISSION)
            if let method = selectedMethod, method != "DECISION", selectedWinner != nil {
                roundPicker
            } else if selectedMethod == "DECISION" && selectedWinner != nil {
                // Decision hint
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                    Text("Round not needed for Decision")
                        .font(.system(size: 11))
                }
                .foregroundColor(BSColors.textHint)
            }

            // Save status
            saveIndicator

            // Score breakdown (if scored)
            if let score, isScored {
                scoreBreakdown(score)
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(cardBorder, lineWidth: isScored ? 1 : 0)
        )
        .padding(.horizontal, 16)
        .onAppear {
            if !initialized {
                selectedWinner = pick?.winnerFighterId
                selectedMethod = pick?.methodPick
                selectedRound = pick?.roundPick
                initialized = true
            }
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Header
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(lastName(fight.fighterRName)) vs \(lastName(fight.fighterBName))")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)

                HStack(spacing: 6) {
                    if let wc = fight.weightClass {
                        Text(wc)
                            .font(.system(size: 12))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    if fight.isTitleFight {
                        Text("·")
                            .foregroundColor(BSColors.textHint)
                        Text("Title Fight")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(BSColors.titleGold)
                    } else if fight.scheduledRounds == 5 {
                        Text("·")
                            .foregroundColor(BSColors.textHint)
                        Text("Main Event")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(BSColors.accent)
                    }
                }
            }

            Spacer()
            statusBadge
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Winner Picker
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var winnerPicker: some View {
        HStack(spacing: 8) {
            fighterButton(
                id: fight.fighterRId,
                name: lastName(fight.fighterRName),
                isSelected: selectedWinner == fight.fighterRId,
                cornerColor: BSColors.accent
            )

            fighterButton(
                id: fight.fighterBId,
                name: lastName(fight.fighterBName),
                isSelected: selectedWinner == fight.fighterBId,
                cornerColor: BSColors.accentBlue
            )
        }
    }

    @ViewBuilder
    private func fighterButton(id: Int, name: String, isSelected: Bool, cornerColor: Color) -> some View {
        Button {
            guard !isLocked else { return }
            selectedWinner = id
            sendPick()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "figure.martial.arts")
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : BSColors.textHint)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isSelected ? .white : BSColors.textPrimary)

                    Text(fighterSubtext(id: id, isSelected: isSelected))
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.7) : BSColors.textHint)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? cornerColor
                    : BSColors.surfaceSecondary
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    private func fighterSubtext(id: Int, isSelected: Bool) -> String {
        if isLocked {
            return isSelected ? "Locked selection" : "Locked selection"
        }
        if isSelected {
            return "Winner selected"
        }
        if selectedWinner != nil {
            return "Tap to switch"
        }
        return "Tap to select"
    }

    // ═══════════════════════════════════════════════
    // MARK: - Method Picker
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var methodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("METHOD")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(BSColors.textHint)
                .kerning(1)

            HStack(spacing: 8) {
                methodPill("KO/TKO", value: "KO_TKO")
                methodPill("Decision", value: "DECISION")
                methodPill("Submission", value: "SUBMISSION")
            }
        }
    }

    @ViewBuilder
    private func methodPill(_ label: String, value: String) -> some View {
        let isSelected = selectedMethod == value

        Button {
            guard !isLocked else { return }
            selectedMethod = value
            if value == "DECISION" {
                selectedRound = nil
            }
            sendPick()
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : BSColors.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? BSColors.accent.opacity(0.8) : BSColors.surfaceSecondary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Round Picker
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var roundPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ROUND")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(BSColors.textHint)
                .kerning(1)

            HStack(spacing: 8) {
                ForEach(1...fight.scheduledRounds, id: \.self) { round in
                    roundPill(round)
                }
            }
        }
    }

    @ViewBuilder
    private func roundPill(_ round: Int) -> some View {
        let isSelected = selectedRound == round

        Button {
            guard !isLocked else { return }
            selectedRound = round
            sendPick()
        } label: {
            Text("R\(round)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isSelected ? .white : BSColors.textSecondary)
                .frame(width: 44, height: 36)
                .background(isSelected ? BSColors.accent.opacity(0.8) : BSColors.surfaceSecondary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Status Badge
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var statusBadge: some View {
        if isLocked && !isScored {
            HStack(spacing: 4) {
                Text("Locked")
                    .font(.system(size: 11, weight: .semibold))
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
            }
            .foregroundColor(BSColors.textHint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(BSColors.surfaceSecondary)
            .cornerRadius(8)
        } else if isScored, let score {
            if score.isVoid {
                badgeView("Void", color: BSColors.textHint)
            } else if score.bonusPoints > 0 {
                badgeView("Perfect ★", color: BSColors.titleGold)
            } else if score.totalPoints > 0 {
                badgeView("\(score.totalPoints) pts", color: BSColors.winGreen)
            } else {
                badgeView("0 pts", color: BSColors.lossRed)
            }
        } else if isComplete {
            HStack(spacing: 4) {
                Text("Complete")
                    .font(.system(size: 11, weight: .semibold))
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundColor(BSColors.winGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(BSColors.winGreen.opacity(0.12))
            .cornerRadius(8)
        } else if selectedWinner != nil {
            badgeView("Incomplete", color: BSColors.titleGold)
        }
    }

    @ViewBuilder
    private func badgeView(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .cornerRadius(8)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Save Indicator
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var saveIndicator: some View {
        switch saveState {
        case .saving:
            HStack(spacing: 6) {
                ProgressView().scaleEffect(0.6).tint(BSColors.textHint)
                Text("Saving...")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textHint)
            }
        case .saved:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11))
                Text("Saved")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(BSColors.winGreen)
        case .failed(let msg):
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 11))
                Text(msg)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
            .foregroundColor(BSColors.lossRed)
        default:
            EmptyView()
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Score Breakdown
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func scoreBreakdown(_ score: FightScoreDTO) -> some View {
        if score.isVoid {
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 11))
                Text("Fight voided — no points awarded")
                    .font(.system(size: 11))
            }
            .foregroundColor(BSColors.textHint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(BSColors.surfaceSecondary)
            .cornerRadius(8)
        } else {
            HStack(spacing: 0) {
                scoreItem("Winner", pts: score.winnerPoints, color: BSColors.accent)
                scoreItem("Method", pts: score.methodPoints, color: BSColors.accentBlue)
                scoreItem("Round", pts: score.roundPoints, color: BSColors.winGreen)
                scoreItem("Bonus", pts: score.bonusPoints, color: BSColors.titleGold)
                scoreItem("Total", pts: score.totalPoints, color: BSColors.textPrimary, isBold: true)
            }
            .padding(.vertical, 8)
            .background(BSColors.surfaceSecondary)
            .cornerRadius(8)
        }
    }

    @ViewBuilder
    private func scoreItem(_ label: String, pts: Int, color: Color, isBold: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text("\(pts)")
                .font(.system(size: isBold ? 16 : 13, weight: isBold ? .bold : .semibold))
                .foregroundColor(pts > 0 ? color : BSColors.textHint)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(BSColors.textHint)
        }
        .frame(maxWidth: .infinity)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Helpers
    // ═══════════════════════════════════════════════

    private var isComplete: Bool {
        guard selectedWinner != nil, let method = selectedMethod else { return false }
        if method == "DECISION" { return true }
        return selectedRound != nil
    }

    private func sendPick() {
        guard let winner = selectedWinner else { return }
        onPickChanged(winner, selectedMethod, selectedRound)
    }

    private var cardBorder: Color {
        guard let score else { return Color.clear }
        if score.isVoid { return BSColors.textHint.opacity(0.3) }
        if score.bonusPoints > 0 { return BSColors.titleGold.opacity(0.5) }
        if score.totalPoints > 0 { return BSColors.winGreen.opacity(0.3) }
        return BSColors.lossRed.opacity(0.3)
    }

    private func lastName(_ name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.count > 1 ? String(parts.last ?? "") : name
    }
}
