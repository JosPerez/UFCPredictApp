//
//  MonthlyLeaderboardView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct MonthlyLeaderboardView: View {
    @State private var rows: [MonthlyLeaderboardRowDTO] = []
    @State private var selectedMonth: String = currentPeriodKey()
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Month selector
                monthSelector

                if isLoading && rows.isEmpty {
                    Spacer()
                    ProgressView().tint(BSColors.accent)
                    Spacer()
                } else if rows.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 32))
                            .foregroundColor(BSColors.textHint)
                        Text("No scores for this month")
                            .font(.system(size: 14))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 6) {
                            columnHeader

                            ForEach(rows) { row in
                                monthlyRow(row)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationTitle("Monthly Rankings")
        .navigationBarTitleDisplayMode(.inline)
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
                    .foregroundColor(BSColors.accent)
            }

            Text(formatPeriodKey(selectedMonth))
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
                .frame(width: 140)

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
            }
            .disabled(selectedMonth == Self.currentPeriodKey())
        }
        .padding(.vertical, 12)
    }

    // MARK: - Column Header

    @ViewBuilder
    private var columnHeader: some View {
        HStack(spacing: 0) {
            Text("#")
                .frame(width: 30)
            Text("Player")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("EVT")
                .frame(width: 32)
            Text("PP")
                .frame(width: 32)
            Text("PTS")
                .frame(width: 44)
        }
        .font(.system(size: 9, weight: .bold))
        .foregroundColor(BSColors.textHint)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    // MARK: - Row

    @ViewBuilder
    private func monthlyRow(_ row: MonthlyLeaderboardRowDTO) -> some View {
        HStack(spacing: 0) {
            // Rank
            Text(row.rank != nil ? "#\(row.rank!)" : "—")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(rankColor(row.rank))
                .frame(width: 30)

            // Nickname
            HStack(spacing: 6) {
                Text(row.nickname)
                    .font(.system(size: 14, weight: row.isCurrentUser ? .bold : .medium))
                    .foregroundColor(row.isCurrentUser ? BSColors.accent : BSColors.textPrimary)
                    .lineLimit(1)
                if row.isCurrentUser {
                    Text("YOU")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(BSColors.accent)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(BSColors.accent.opacity(0.12))
                        .cornerRadius(3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Events played
            Text("\(row.eventsPlayed)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(BSColors.textTertiary)
                .frame(width: 32)

            // Perfect picks
            Text("\(row.perfectPicks)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(row.perfectPicks > 0 ? BSColors.titleGold : BSColors.textTertiary)
                .frame(width: 32)

            // Total points
            Text("\(row.totalPoints)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(row.isCurrentUser ? BSColors.accent : BSColors.textPrimary)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(row.isCurrentUser ? BSColors.accent.opacity(0.06) : BSColors.surface)
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

    private func fetch() {
        isLoading = true
        Task {
            do {
                rows = try await GameAPIClient.shared.getMonthlyLeaderboard(periodKey: selectedMonth)
            } catch {
                errorMessage = "Failed to load leaderboard"
            }
            isLoading = false
        }
    }

    private func changeMonth(_ delta: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let date = formatter.date(from: selectedMonth) else { return }
        guard let newDate = Calendar.current.date(byAdding: .month, value: delta, to: date) else { return }
        let newKey = formatter.string(from: newDate)
        if newKey <= Self.currentPeriodKey() {
            selectedMonth = newKey
            fetch()
        }
    }

    static func currentPeriodKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
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

    private func rankColor(_ rank: Int?) -> Color {
        switch rank {
        case 1:    return BSColors.titleGold
        case 2, 3: return BSColors.accent
        default:   return BSColors.textTertiary
        }
    }
}
