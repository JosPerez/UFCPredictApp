//
//  SwiftUIView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import SwiftUI

struct FighterRow: View {
    let fighter: CachedFighter

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            FighterAvatar(
                imageUrl: fighter.imgThumb,
                initials: fighter.initials,
                size: 48
            )

            // Name + nickname + weight class
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(fighter.fullName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                        .lineLimit(1)

                    // Ranking badge (solo top 15)
                    if let rank = fighter.currentRank {
                        Text(rank == 0 ? "C" : "#\(rank)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(rank == 0 ? BSColors.titleGold : rankBadgeColor)
                            .cornerRadius(4)
                    }
                }

                if let nick = fighter.nickname, !nick.isEmpty, nick != "NaN" {
                    Text("\"\(nick)\"")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                        .italic()
                        .lineLimit(1)
                }

                Text(fighter.weightClass ?? "—")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textSecondary)
            }

            Spacer()

            // Record
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 0) {
                    VStack(spacing: 2) {
                        Text("W")
                            .foregroundColor(BSColors.winGreen)
                            .font(.system(size: 12))
                        Text("\(fighter.recordWin)")
                            .foregroundColor(BSColors.textPrimary)
                            .font(.system(size: 12, weight: .bold))
                    }
                    VStack(spacing: 2) {
                        Text("-")
                            .foregroundColor(BSColors.textPrimary)
                            .font(.system(size: 12))
                        Text("-")
                            .foregroundColor(BSColors.textPrimary)
                            .font(.system(size: 12, weight: .bold))
                    }
                    VStack(spacing: 2) {
                        Text("L")
                            .foregroundColor(BSColors.accent)
                            .font(.system(size: 12))
                        Text("\(fighter.recordLoss)")
                            .foregroundColor(BSColors.textPrimary)
                            .font(.system(size: 12, weight: .bold))
                    }
                    VStack(spacing: 2) {
                        Text("-")
                            .foregroundColor(BSColors.textPrimary)
                            .font(.system(size: 12))
                        Text("-")
                            .foregroundColor(BSColors.textPrimary)
                            .font(.system(size: 12, weight: .bold))
                    }
                    VStack(spacing: 2) {
                        Text("D")
                            .foregroundColor(BSColors.textRecord)
                            .font(.system(size: 12))
                        Text("\(fighter.recordDraw)")
                            .foregroundColor(BSColors.textPrimary)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
            }
            
//            VStack(alignment: .trailing, spacing: 2) {
//
//                HStack(spacing: 0) {
//                    Text("W")
//                        .foregroundColor(BSColors.winGreen)
//                    Text("-")
//                        .foregroundColor(BSColors.textHint)
//                    Text("L")
//                        .foregroundColor(BSColors.accent)
//                    Text("-")
//                        .foregroundColor(BSColors.textHint)
//                    Text("D")
//                        .foregroundColor(BSColors.textTertiary)
//                }
//                .font(.system(size: 12, weight: .bold))
//                Text("\(fighter.recordWin) - \(fighter.recordLoss) - \(fighter.recordDraw)")
//                    .foregroundColor(BSColors.textPrimary)
//                    .font(.system(size: 12, weight: .bold))
//
//            }
        }
        .padding(12)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    private var rankBadgeColor: Color {
        Color(light: "1C1C1E", dark: "555555")
    }
}
