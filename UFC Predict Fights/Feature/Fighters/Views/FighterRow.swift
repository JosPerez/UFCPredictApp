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
        VStack(alignment: .leading, spacing: 0) {
            // Top: avatar + name + win rate
            HStack(spacing: 10) {
                FighterAvatar(
                    imageUrl: fighter.imgThumb,
                    initials: fighter.initials,
                    size: 44
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(fighter.fullName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                        .lineLimit(1)
                    Text(fighter.weightClass ?? "—")
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textSecondary)
                }

                Spacer()
                
                VStack(spacing: 16) {
                    Text(winRateText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(BSColors.accent)
                    Text("win rate")
                            .font(.system(size: 11))
                            .foregroundColor(BSColors.textTertiary)
                }
            }

            // Bottom: record
            HStack(spacing: 16) {
                recordItem(value: fighter.recordWin, label: "W", color: Color(hex: "34C759"))
                recordItem(value: fighter.recordLoss, label: "L", color: BSColors.accent)
                recordItem(value: fighter.recordDraw, label: "D", color: Color(hex: "888888"))
            }
            .padding(.top, 8)
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func recordItem(value: Int, label: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Text("\(value)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(BSColors.textTertiary)
        }
    }

    private var winRateText: String {
        let rate = fighter.winRate
        guard rate > 0 else { return "—" }
        return "\(Int(rate * 100))%"
    }
}
