//
//  EventPicksView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct EventPicksView: View {
    let eventId: Int
    @State private var viewModel = EventPicksViewModel()
    @State private var lockCountdown: String = ""
    @State private var countdownTimer: Timer? = nil
    @State private var justLocked = false

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if viewModel.isLoading && viewModel.eventDetail == nil {
                ProgressView().tint(BSColors.accent)
            } else if let error = viewModel.errorMessage, viewModel.eventDetail == nil {
                ErrorStateView(message: error) {
                    viewModel.loadEvent(eventId: eventId)
                }
            } else if let detail = viewModel.eventDetail {
                eventContent(detail)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if viewModel.eventDetail == nil {
                viewModel.loadEvent(eventId: eventId)
            }
            startCountdown()
        }
        .onDisappear {
            countdownTimer?.invalidate()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func eventContent(_ detail: GameEventDetailDTO) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                eventHeader(detail)

                // Locked banner
                if viewModel.isLocked {
                    lockedBanner(detail.status)
                }

                // Progress
                progressBar

                // Fight cards
                ForEach(detail.fights) { fight in
                    FightPickCard(
                        fight: fight,
                        pick: viewModel.pickFor(fightId: fight.fightId),
                        score: viewModel.scoreFor(fightId: fight.fightId),
                        saveState: viewModel.saveStateFor(fightId: fight.fightId),
                        isLocked: viewModel.isLocked,
                        isScored: viewModel.isScored,
                        onPickChanged: { winnerId, method, round in
                            viewModel.submitPick(
                                fightId: fight.fightId,
                                winnerFighterId: winnerId,
                                methodPick: method,
                                roundPick: round
                            )
                        }
                    )
                }
            }
            .padding(.bottom, 32)
        }
        .refreshable {
            viewModel.loadEvent(eventId: eventId)
        }
    }

    // MARK: - Header

    @ViewBuilder
    private func eventHeader(_ detail: GameEventDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(detail.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(BSColors.textPrimary)

            if let loc = detail.location {
                Text(loc)
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textSecondary)
            }

            HStack(spacing: 12) {
                // Lock time
                HStack(spacing: 4) {
                    Image(systemName: "lock.badge.clock")
                        .font(.system(size: 10))
                    if viewModel.isLocked {
                        Text("Locked")
                            .font(.system(size: 11, weight: .medium))
                    } else if !lockCountdown.isEmpty {
                        Text("Locks in \(lockCountdown)")
                            .font(.system(size: 11, weight: .medium))
                    } else {
                        Text("Locks \(formatLockTime(detail.lockAt))")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundColor(countdownColor)

                // Score (if scored)
                if viewModel.isScored {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("\(viewModel.totalPoints) points")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(BSColors.winGreen)
                }
                
                if viewModel.isScored {
                    NavigationLink(value: GameNavigation.eventLeaderboard(detail.eventId, detail.name)) {
                        HStack(spacing: 6) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 11))
                            Text("View leaderboard")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(BSColors.titleGold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(BSColors.titleGold.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                
                if viewModel.isScored {
                    HStack(spacing: 8) {
                        NavigationLink(value: GameNavigation.eventLeaderboard(detail.eventId, detail.name)) {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 11))
                                Text("Leaderboard")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(BSColors.titleGold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(BSColors.titleGold.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        NavigationLink(value: GameNavigation.postEventResults(detail.eventId)) {
                            HStack(spacing: 6) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 11))
                                Text("My results")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(BSColors.accentBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(BSColors.accentBlue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }

    // MARK: - Locked Banner

    @ViewBuilder
    private func lockedBanner(_ status: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: status == "scored" ? "checkmark.seal.fill" : "lock.fill")
                .font(.system(size: 12))
            Text(status == "scored"
                 ? "Event scored — view your results below"
                 : "Event locked — picks are no longer accepted"
            )
            .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(status == "scored" ? BSColors.accentBlue : BSColors.titleGold)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background((status == "scored" ? BSColors.accentBlue : BSColors.titleGold).opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }

    // MARK: - Progress

    @ViewBuilder
    private var progressBar: some View {
        HStack(spacing: 8) {
            Text("\(viewModel.completedPicks)/\(viewModel.totalFights) picks completed")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(viewModel.allComplete ? BSColors.winGreen : BSColors.textTertiary)

            Spacer()

            if viewModel.allComplete {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                    Text("All set")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(BSColors.winGreen)
            }
        }
        .padding(.horizontal, 16)

        // Bar
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(BSColors.surfaceSecondary)
                RoundedRectangle(cornerRadius: 3)
                    .fill(viewModel.allComplete ? BSColors.winGreen : BSColors.accent)
                    .frame(width: geo.size.width * CGFloat(viewModel.completedPicks) / max(CGFloat(viewModel.totalFights), 1))
                    .animation(.easeOut(duration: 0.3), value: viewModel.completedPicks)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

    private func formatLockTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
    // MARK: - Countdown

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                updateCountdown()
            }
        }
    }

    private func updateCountdown() {
        guard let detail = viewModel.eventDetail else { return }

        let now = Date()
        let lockAt = detail.lockAt
        let remaining = lockAt.timeIntervalSince(now)

        if remaining <= 0 {
            lockCountdown = ""
            countdownTimer?.invalidate()

            // Auto-refresh if just locked
            if !justLocked && !viewModel.isLocked {
                justLocked = true
                viewModel.loadEvent(eventId: eventId)
            }
            return
        }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60

        if hours > 24 {
            let days = hours / 24
            lockCountdown = "\(days)d \(hours % 24)h"
        } else if hours > 0 {
            lockCountdown = "\(hours)h \(minutes)m"
        } else {
            lockCountdown = "\(minutes)m \(seconds)s"
        }
    }
    
    private var countdownColor: Color {
        if viewModel.isLocked { return BSColors.lossRed }
        guard let detail = viewModel.eventDetail else { return BSColors.textTertiary }
        let remaining = detail.lockAt.timeIntervalSince(Date())
        if remaining < 3600 { return BSColors.lossRed }      // < 1 hour = red
        if remaining < 86400 { return BSColors.titleGold }    // < 1 day = gold
        return BSColors.textTertiary
    }
}
