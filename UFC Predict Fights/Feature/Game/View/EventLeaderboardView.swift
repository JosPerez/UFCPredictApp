//
//  EventLeaderboardView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct EventLeaderboardView: View {
    let eventId: Int
    let eventName: String

    @State private var rows: [EventLeaderboardRowDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if isLoading && rows.isEmpty {
                ProgressView().tint(BSColors.accent)
            } else if let error = errorMessage, rows.isEmpty {
                ErrorStateView(message: error) { fetch() }
            } else if rows.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 32))
                        .foregroundColor(BSColors.textHint)
                    Text("No scores yet")
                        .font(.system(size: 14))
                        .foregroundColor(BSColors.textTertiary)
                }
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        // Header
                        Text(eventName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(BSColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        // Column header
                        columnHeader

                        // Rows
                        ForEach(rows) { row in
                            leaderboardRow(row)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { fetch() }
    }

    // MARK: - Column Header

    @ViewBuilder
    private var columnHeader: some View {
        HStack(spacing: 0) {
            Text("#")
                .frame(width: 30)
            Text("Player")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("W")
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
    private func leaderboardRow(_ row: EventLeaderboardRowDTO) -> some View {
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

            // Correct winners
            Text("\(row.correctWinners)")
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
                rows = try await GameAPIClient.shared.getEventLeaderboard(eventId: eventId)
            } catch {
                errorMessage = "Failed to load leaderboard"
            }
            isLoading = false
        }
    }

    private func rankColor(_ rank: Int?) -> Color {
        switch rank {
        case 1:    return BSColors.titleGold
        case 2, 3: return BSColors.accent
        default:   return BSColors.textTertiary
        }
    }
}
