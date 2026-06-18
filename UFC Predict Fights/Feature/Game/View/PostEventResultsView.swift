//
//  PostEventResultsView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct PostEventResultsView: View {
    let eventId: Int

    @State private var result: UserEventResultDTO? = nil
    @State private var eventDetail: GameEventDetailDTO? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if isLoading && result == nil {
                ProgressView().tint(BSColors.accent)
            } else if let error = errorMessage, result == nil {
                ErrorStateView(message: error) { fetch() }
            } else if let result, let detail = eventDetail {
                content(result, detail)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { fetch() }
    }

    // MARK: - Content

    @ViewBuilder
    private func content(_ result: UserEventResultDTO, _ detail: GameEventDetailDTO) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                // Summary card
                summaryCard(result)

                // Fight-by-fight breakdown
                ForEach(detail.fights) { fight in
                    let score = result.fightScores.first(where: { $0.fightId == fight.fightId })
                    let pick = detail.picks.first(where: { $0.fightId == fight.fightId })
                    fightResultCard(fight: fight, pick: pick, score: score)
                }
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - Summary Card

    @ViewBuilder
    private func summaryCard(_ result: UserEventResultDTO) -> some View {
        VStack(spacing: 14) {
            Text(result.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(BSColors.textPrimary)

            // Points + rank
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(result.totalPoints)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(BSColors.accent)
                    Text("Total points")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                }

                Rectangle()
                    .fill(BSColors.border)
                    .frame(width: 1, height: 50)

                VStack(spacing: 4) {
                    if let rank = result.rank {
                        Text("#\(rank)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(rankColor(rank))
                    } else {
                        Text("—")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(BSColors.textHint)
                    }
                    Text("of \(result.totalParticipants)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                }
            }

            // Stats row
            HStack(spacing: 0) {
                let correctWinners = result.fightScores.filter { $0.winnerPoints > 0 }.count
                let perfectPicks = result.fightScores.filter { $0.bonusPoints > 0 }.count
                let totalFights = result.fightScores.count
                let voidFights = result.fightScores.filter { $0.isVoid }.count

                statPill(label: "Correct", value: "\(correctWinners)/\(totalFights)", color: BSColors.winGreen)
                statPill(label: "Perfect", value: "\(perfectPicks)", color: BSColors.titleGold)
                statPill(label: "Void", value: "\(voidFights)", color: BSColors.textHint)
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func statPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(BSColors.textHint)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Fight Result Card

    @ViewBuilder
    private func fightResultCard(fight: GameFightDTO, pick: FightPickDTO?, score: FightScoreDTO?) -> some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                if let wc = fight.weightClass {
                    Text(wc)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(BSColors.textTertiary)
                }
                Spacer()
                resultBadge(score)
            }

            // Fighters row
            HStack(spacing: 0) {
                // Red
                VStack(spacing: 4) {
                    FighterAvatar(
                        imageUrl: fight.fighterRImg,
                        initials: initials(fight.fighterRName),
                        size: 36,
                        accentColor: BSColors.accent
                    )
                    Text(fight.fighterRName.shortName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            fight.winnerFighterId == fight.fighterRId
                                ? BSColors.winGreen : BSColors.textTertiary
                        )
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)

                // Result
                VStack(spacing: 2) {
                    if let method = fight.method {
                        Text(method)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(BSColors.textPrimary)
                    }
                    if let round = fight.round {
                        Text("R\(round)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(BSColors.textTertiary)
                    }
                }

                // Blue
                VStack(spacing: 4) {
                    FighterAvatar(
                        imageUrl: fight.fighterBImg,
                        initials: initials(fight.fighterBName),
                        size: 36,
                        accentColor: BSColors.accentBlue
                    )
                    Text(fight.fighterBName.shortName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            fight.winnerFighterId == fight.fighterBId
                                ? BSColors.winGreen : BSColors.textTertiary
                        )
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }

            // Your pick vs actual
            if let pick {
                pickComparison(fight: fight, pick: pick)
            } else {
                Text("No pick submitted")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textHint)
            }

            // Score breakdown
            if let score, !score.isVoid {
                scoreRow(score)
            }
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cardBorder(score), lineWidth: score != nil ? 1 : 0)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Pick Comparison

    @ViewBuilder
    private func pickComparison(fight: GameFightDTO, pick: FightPickDTO) -> some View {
        HStack(spacing: 0) {
            // Your pick
            VStack(spacing: 3) {
                Text("YOUR PICK")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(BSColors.textHint)
                    .kerning(1)
                Text(pickedFighterName(fight: fight, pick: pick))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(BSColors.accent)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    if let method = pick.methodPick {
                        Text(formatMethod(method))
                            .font(.system(size: 9, weight: .medium))
                    }
                    if let round = pick.roundPick {
                        Text("R\(round)")
                            .font(.system(size: 9, weight: .medium))
                    }
                }
                .foregroundColor(BSColors.textTertiary)
            }
            .frame(maxWidth: .infinity)

            // VS divider
            Image(systemName: pickMatchesWinner(fight: fight, pick: pick) ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(pickMatchesWinner(fight: fight, pick: pick) ? BSColors.winGreen : BSColors.lossRed)

            // Actual result
            VStack(spacing: 3) {
                Text("ACTUAL")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(BSColors.textHint)
                    .kerning(1)
                Text(actualWinnerName(fight))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(BSColors.winGreen)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    if let method = fight.method {
                        Text(method)
                            .font(.system(size: 9, weight: .medium))
                    }
                    if let round = fight.round {
                        Text("R\(round)")
                            .font(.system(size: 9, weight: .medium))
                    }
                }
                .foregroundColor(BSColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(10)
        .background(BSColors.surfaceSecondary)
        .cornerRadius(8)
    }

    // MARK: - Score Row

    @ViewBuilder
    private func scoreRow(_ score: FightScoreDTO) -> some View {
        HStack(spacing: 0) {
            scoreCell("Winner", pts: score.winnerPoints, color: BSColors.accent)
            scoreCell("Method", pts: score.methodPoints, color: BSColors.accentBlue)
            scoreCell("Round", pts: score.roundPoints, color: BSColors.winGreen)
            scoreCell("Bonus", pts: score.bonusPoints, color: BSColors.titleGold)

            // Total
            VStack(spacing: 2) {
                Text("\(score.totalPoints)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(score.totalPoints > 0 ? BSColors.textPrimary : BSColors.textHint)
                Text("Total")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(BSColors.textHint)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func scoreCell(_ label: String, pts: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(pts > 0 ? "+\(pts)" : "0")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(pts > 0 ? color : BSColors.textHint)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(BSColors.textHint)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Result Badge

    @ViewBuilder
    private func resultBadge(_ score: FightScoreDTO?) -> some View {
        if let score {
            if score.isVoid {
                badge("VOID", color: BSColors.textHint)
            } else if score.bonusPoints > 0 {
                badge("PERFECT", color: BSColors.titleGold)
            } else if score.winnerPoints > 0 {
                badge("\(score.totalPoints) PTS", color: BSColors.winGreen)
            } else {
                badge("0 PTS", color: BSColors.lossRed)
            }
        }
    }

    @ViewBuilder
    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(4)
    }

    // MARK: - Helpers

    private func fetch() {
        isLoading = true
        Task {
            do {
                async let resultTask = GameAPIClient.shared.getMyEventResults(eventId: eventId)
                async let detailTask = GameAPIClient.shared.getGameEventDetail(eventId: eventId)
                result = try await resultTask
                eventDetail = try await detailTask
            } catch {
                errorMessage = "Failed to load results"
            }
            isLoading = false
        }
    }

    private func pickedFighterName(fight: GameFightDTO, pick: FightPickDTO) -> String {
        if pick.winnerFighterId == fight.fighterRId {
            return fight.fighterRName.shortName
        }
        return fight.fighterBName.shortName
    }

    private func actualWinnerName(_ fight: GameFightDTO) -> String {
        if fight.winnerFighterId == fight.fighterRId {
            return fight.fighterRName.shortName
        }
        if fight.winnerFighterId == fight.fighterBId {
            return fight.fighterBName.shortName
        }
        return "—"
    }

    private func pickMatchesWinner(fight: GameFightDTO, pick: FightPickDTO) -> Bool {
        fight.winnerFighterId == pick.winnerFighterId
    }

    private func formatMethod(_ method: String) -> String {
        switch method {
        case "KO_TKO":     return "KO/TKO"
        case "SUBMISSION":  return "SUB"
        case "DECISION":    return "DEC"
        default:            return method
        }
    }

    private func cardBorder(_ score: FightScoreDTO?) -> Color {
        guard let score else { return Color.clear }
        if score.isVoid { return BSColors.textHint.opacity(0.3) }
        if score.bonusPoints > 0 { return BSColors.titleGold.opacity(0.5) }
        if score.totalPoints > 0 { return BSColors.winGreen.opacity(0.3) }
        return BSColors.lossRed.opacity(0.3)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1:    return BSColors.titleGold
        case 2, 3: return BSColors.accent
        default:   return BSColors.textPrimary
        }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.last?.prefix(1) ?? ""
        return "\(f)\(l)"
    }
}
