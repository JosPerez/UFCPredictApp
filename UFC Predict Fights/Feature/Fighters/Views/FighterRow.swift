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
            ZStack {
                Circle()
                    .fill(Color(hex: "1C1C1E"))
                    .frame(width: 40, height: 40)
                Text(fighter.initials)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "FF3B30"))
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(fighter.fullName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(fighter.recordWin)W · \(fighter.recordLoss)L · \(fighter.weightClass ?? "—")")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "555555"))
            }

            Spacer()

            // Win rate
            VStack(alignment: .trailing, spacing: 1) {
                Text(winRateText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "FF3B30"))
                Text("Win rate")
                    .font(.system(size: 9))
                    .foregroundColor(Color(hex: "3a3a3a"))
            }
        }
        .padding(.vertical, 6)
    }

    private var winRateText: String {
        let rate = fighter.winRate
        guard rate > 0 else { return "—" }
        return "\(Int(rate * 100))%"
    }
}
