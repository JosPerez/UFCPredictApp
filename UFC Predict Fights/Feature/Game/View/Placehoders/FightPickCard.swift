//
//  FightPickCard.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct FightPickCard: View {
    let fight: GameFightDTO
    let draft: EventPicksViewModel.DraftPick
    let score: FightScoreDTO?
    let isLocked: Bool
    let isScored: Bool
    let onDraftChanged: (Int?, String?, Int?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            header

            // Winner picker
            winnerPicker

            // Method (visible after winner selected)
            if draft.winnerFighterId != nil {
                methodPicker
            }

            // Round (visible if method is KO_TKO or SUBMISSION)
            if let method = draft.methodPick, method != "DECISION", draft.winnerFighterId != nil {
                roundPicker
            } else if draft.methodPick == "DECISION" && draft.winnerFighterId != nil {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                    Text("Round not needed for Decision")
                        .font(.system(size: 11))
                }
                .foregroundColor(BSColors.textHint)
            }

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
    }

    // ═══════════════════════════════════════════════
    // MARK: - Header
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(fight.fighterRName.shortName) vs \(fight.fighterBName.shortName)")
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
                name: fight.fighterRName.shortName,
                img: fight.fighterRImg,
                isSelected: draft.winnerFighterId == fight.fighterRId,
                cornerColor: BSColors.accent
            )
            fighterButton(
                id: fight.fighterBId,
                name: fight.fighterBName.shortName,
                img: fight.fighterBImg,
                isSelected: draft.winnerFighterId == fight.fighterBId,
                cornerColor: BSColors.accentBlue
            )
        }
    }

    @ViewBuilder
    private func fighterButton(id: Int, name: String, img: String?, isSelected: Bool, cornerColor: Color) -> some View {
        Button {
            guard !isLocked else { return }
            onDraftChanged(id, draft.methodPick, draft.roundPick)
        } label: {
            HStack(spacing: 10) {
                FighterAvatar(
                    imageUrl: img,
                    initials: String(name.prefix(2)).uppercased(),
                    size: 36,
                    accentColor: isSelected ? .white : cornerColor
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(isSelected ? .white : BSColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .frame(height: 36, alignment: .topLeading)
                    Text(fighterSubtext(id: id, isSelected: isSelected))
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.7) : BSColors.textHint)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? cornerColor : BSColors.surfaceSecondary)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    private func fighterSubtext(id: Int, isSelected: Bool) -> String {
        if isLocked { return "Locked selection" }
        if isSelected { return "Winner selected" }
        if draft.winnerFighterId != nil { return "Tap to switch" }
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
        let isSelected = draft.methodPick == value

        Button {
            guard !isLocked else { return }
            let newRound = value == "DECISION" ? nil : draft.roundPick
            onDraftChanged(draft.winnerFighterId, value, newRound)
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
                    let isSelected = draft.roundPick == round

                    Button {
                        guard !isLocked else { return }
                        onDraftChanged(draft.winnerFighterId, draft.methodPick, round)
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
            }
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Status Badge
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var statusBadge: some View {
        if isLocked && !isScored {
            HStack(spacing: 4) {
                Text("Locked")
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
            }
            .font(.system(size: 11, weight: .semibold))
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
        } else if draft.isComplete {
            HStack(spacing: 4) {
                Text("Complete")
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(BSColors.winGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(BSColors.winGreen.opacity(0.12))
            .cornerRadius(8)
        } else if draft.winnerFighterId != nil {
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

    private var cardBorder: Color {
        guard let score else { return Color.clear }
        if score.isVoid { return BSColors.textHint.opacity(0.3) }
        if score.bonusPoints > 0 { return BSColors.titleGold.opacity(0.5) }
        if score.totalPoints > 0 { return BSColors.winGreen.opacity(0.3) }
        return BSColors.lossRed.opacity(0.3)
    }
}
