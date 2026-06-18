//
//  MonthlyLeaderboardView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct MonthlyLeaderboardView: View {
    //
    private static let minPeriodKey = "2026-05"
    // State
    @State private var rows: [MonthlyLeaderboardRowDTO] = []
    @State private var selectedMonth: String = currentPeriodKey()
    @State private var isLoading = false

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Month carousel
                monthSelector
                    .padding(.top, 8)

                if isLoading && rows.isEmpty {
                    Spacer()
                    ProgressView().tint(BSColors.accent)
                    Spacer()
                } else if rows.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "trophy")
                            .font(.system(size: 32))
                            .foregroundColor(BSColors.textHint)
                        Text("No scores for this month")
                            .font(.system(size: 14))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Your rank card
                            if let me = rows.first(where: { $0.isCurrentUser }) {
                                yourRankCard(me)
                            }

                            // Rankings header
                            HStack {
                                Text("TOP PLAYERS — \(formatPeriodKeyUpper(selectedMonth))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(BSColors.textHint)
                                    .kerning(1.5)
                                Spacer()
                                Text("Monthly ranking")
                                    .font(.system(size: 11))
                                    .foregroundColor(BSColors.textHint)
                            }
                            .padding(.horizontal, 16)

                            // Player rows
                            VStack(spacing: 8) {
                                ForEach(rows) { row in
                                    playerCard(row)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("Monthly Leaderboard")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    Text(formatPeriodKey(selectedMonth))
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textTertiary)
                }
            }
        }
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { fetch() }
    }

    // MARK: - Month Selector

    @ViewBuilder
    private var monthSelector: some View {
        HStack(spacing: 16) {
            Button {
                changeMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(
                        selectedMonth == Self.minPeriodKey
                            ? BSColors.textHint
                            : BSColors.accent
                    )
                    .frame(width: 36, height: 36)
                    .background(BSColors.surface)
                    .cornerRadius(8)
            }
            .disabled(selectedMonth == Self.minPeriodKey)

            Text(formatPeriodKey(selectedMonth))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
                .frame(maxWidth: .infinity)

            Button {
                changeMonth(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(
                        selectedMonth == Self.currentPeriodKey()
                            ? BSColors.textHint
                            : BSColors.accent
                    )
                    .frame(width: 36, height: 36)
                    .background(BSColors.surface)
                    .cornerRadius(8)
            }
            .disabled(selectedMonth == Self.currentPeriodKey())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Your Rank Card

    @ViewBuilder
    private func yourRankCard(_ me: MonthlyLeaderboardRowDTO) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("YOUR RANK")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(BSColors.textHint)
                    .kerning(1.5)

                HStack(spacing: 8) {
                    Text("#\(me.rank ?? 0)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    Text(me.nickname)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                }

                Text("\(me.eventsPlayed) Events")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
            }

            Spacer()

            Text("\(me.totalPoints) pts")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(BSColors.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(BSColors.accent.opacity(0.15))
                .cornerRadius(8)
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(BSColors.accent.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Player Card

    @ViewBuilder
    private func playerCard(_ row: MonthlyLeaderboardRowDTO) -> some View {
        HStack(spacing: 12) {
            // Rank icon
            rankIcon(row.rank)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    if let rank = row.rank {
                        Text("#\(rank)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    Text(row.nickname)
                        .font(.system(size: 16, weight: row.isCurrentUser ? .bold : .semibold))
                        .foregroundColor(row.isCurrentUser ? BSColors.accent : BSColors.textPrimary)
                        .lineLimit(1)
                }
                Text("\(row.eventsPlayed) Events")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
            }

            Spacer()

            // Points
            Text("\(row.totalPoints) pts")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    row.isCurrentUser
                        ? BSColors.accent.opacity(0.5)
                        : (isTopThree(row.rank) ? rankBorderColor(row.rank).opacity(0.3) : Color.clear),
                    lineWidth: row.isCurrentUser ? 1.5 : 1
                )
        )
    }

    // MARK: - Rank Icon

    @ViewBuilder
    private func rankIcon(_ rank: Int?) -> some View {
        ZStack {
            Circle()
                .fill(rankIconBackground(rank))
                .frame(width: 40, height: 40)

            if isTopThree(rank) {
                Image(systemName: rankIconName(rank))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(rankIconColor(rank))
            } else {
                Text("\(rank ?? 0)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(BSColors.textTertiary)
            }
        }
    }

    private func isTopThree(_ rank: Int?) -> Bool {
        guard let rank else { return false }
        return rank <= 3
    }

    private func rankIconName(_ rank: Int?) -> String {
        switch rank {
        case 1:  return "trophy.fill"
        case 2:  return "medal.fill"
        case 3:  return "medal"
        default: return "number"
        }
    }

    private func rankIconColor(_ rank: Int?) -> Color {
        switch rank {
        case 1:  return BSColors.titleGold
        case 2:  return Color(hex: "C0C0C0")
        case 3:  return Color(hex: "CD7F32")
        default: return BSColors.textTertiary
        }
    }

    private func rankIconBackground(_ rank: Int?) -> Color {
        switch rank {
        case 1:  return BSColors.titleGold.opacity(0.15)
        case 2:  return Color(hex: "C0C0C0").opacity(0.12)
        case 3:  return Color(hex: "CD7F32").opacity(0.12)
        default: return BSColors.surfaceSecondary
        }
    }

    private func rankBorderColor(_ rank: Int?) -> Color {
        switch rank {
        case 1:  return BSColors.titleGold
        case 2:  return Color(hex: "C0C0C0")
        case 3:  return Color(hex: "CD7F32")
        default: return Color.clear
        }
    }

    // MARK: - Helpers

    private func fetch() {
        isLoading = true
        Task {
            do {
                rows = try await GameAPIClient.shared.getMonthlyLeaderboard(periodKey: selectedMonth)
            } catch {
                rows = []
            }
            isLoading = false
        }
    }

    private func changeMonth(_ delta: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let date = formatter.date(from: selectedMonth),
              let newDate = Calendar.current.date(byAdding: .month, value: delta, to: date) else { return }
        let newKey = formatter.string(from: newDate)
        if newKey >= Self.minPeriodKey && newKey <= Self.currentPeriodKey() {
            selectedMonth = newKey
            fetch()
        }
    }

    static func currentPeriodKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    private func formatPeriodKey(_ key: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let date = formatter.date(from: key) else { return key }
        let output = DateFormatter()
        output.dateFormat = "MMMM yyyy"
        return output.string(from: date)
    }

    private func formatPeriodKeyUpper(_ key: String) -> String {
        formatPeriodKey(key).uppercased()
    }
}
