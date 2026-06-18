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
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 12) {
                    // Header
                    eventHeader(detail)
                    
                    // Progress + lock
                    progressSection
                    
                    // Locked banner (only if locked/scored, not in progress section)
                    if viewModel.isScored {
                        scoredBanner(detail)
                    }
                    
                    // Fight cards
                    ForEach(detail.fights) { fight in
                        FightPickCard(
                            fight: fight,
                            draft: viewModel.draftFor(fightId: fight.fightId),
                            score: viewModel.scoreFor(fightId: fight.fightId),
                            isLocked: viewModel.isLocked,
                            isScored: viewModel.isScored,
                            onDraftChanged: { winnerId, method, round in
                                viewModel.updateDraft(
                                    fightId: fight.fightId,
                                    winnerFighterId: winnerId,
                                    methodPick: method,
                                    roundPick: round
                                )
                            }
                        )
                    }
                    Spacer(minLength: 24)
                }
                .padding(.bottom, 32)
            }
            .refreshable {
                viewModel.loadEvent(eventId: eventId)
            }
            // Floating save/reset bar
            if !viewModel.isLocked {
                actionBar
            }
        }
    }
    
    // MARK: - Action Bar
    
    @ViewBuilder
    private var actionBar: some View {
        VStack(spacing: 0) {
            Divider().background(BSColors.border)
            
            VStack(spacing: 8) {
                // Save state feedback
                saveStateBanner
                
                HStack(spacing: 10) {
                    // Reset button
                    Button {
                        viewModel.resetAllDrafts()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12))
                            Text("Reset")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(BSColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(BSColors.surfaceSecondary)
                        .cornerRadius(10)
                    }
                    
                    // Save button
                    Button {
                        viewModel.saveAllDirtyPicks()
                    } label: {
                        HStack(spacing: 6) {
                            if viewModel.saveState == .saving {
                                ProgressView().scaleEffect(0.7).tint(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                            }
                            Text(saveButtonText)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.hasDirtyPicks
                            ? BSColors.accent
                            : BSColors.accent.opacity(0.4)
                        )
                        .cornerRadius(10)
                    }
                    .disabled(!viewModel.hasDirtyPicks || viewModel.saveState == .saving)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(BSColors.background)
        }
    }
    
    @ViewBuilder
    private var saveStateBanner: some View {
        switch viewModel.saveState {
        case .saved:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                Text("All picks saved")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(BSColors.winGreen)
            .transition(.opacity)
        case .failed(let msg):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                Text(msg)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(BSColors.lossRed)
            .transition(.opacity)
        default:
            EmptyView()
        }
    }
    
    private var saveButtonText: String {
        if viewModel.saveState == .saving { return "Saving..." }
        let count = viewModel.dirtyCount
        if count == 0 { return "Save picks" }
        return "Save \(count) pick\(count > 1 ? "s" : "")"
    }
    
    // MARK: - Scored Banner
    
    @ViewBuilder
    private func scoredBanner(_ detail: GameEventDetailDTO) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Event scored")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.accentBlue)
                Text("\(viewModel.totalPoints) points earned")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
            }
            
            Spacer()
            
            NavigationLink(value: GameNavigation.eventLeaderboard(detail.eventId, detail.name)) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                    Text("Leaderboard")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(BSColors.titleGold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(BSColors.titleGold.opacity(0.12))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            
            NavigationLink(value: GameNavigation.postEventResults(detail.eventId)) {
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 10))
                    Text("Results")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(BSColors.accentBlue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(BSColors.accentBlue.opacity(0.12))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Header
    
    @ViewBuilder
    private func eventHeader(_ detail: GameEventDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(detail.name.replacingOccurrences(of: "UFC ", with: "UFC ") + " Picks")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                
                Spacer()
                
                // Status badge
                Text(detail.status.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(statusColor(detail.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(detail.status).opacity(0.15))
                    .cornerRadius(6)
            }
            
            // Date + fight count
            HStack(spacing: 6) {
                Text(detail.eventDate.formatEventDate())
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textTertiary)
                Text("·")
                    .foregroundColor(BSColors.textHint)
                Text("\(detail.fightCount) fights")
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
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
    
    // MARK: - Progress Section
    
    @ViewBuilder
    private var progressSection: some View {
        VStack(spacing: 10) {
            // Lock countdown + percentage
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.isLocked ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 12))
                    if viewModel.isLocked {
                        Text("Picks locked")
                            .font(.system(size: 14, weight: .semibold))
                    } else if !lockCountdown.isEmpty {
                        Text("Picks lock in \(lockCountdown)")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .foregroundColor(countdownColor)
                
                Spacer()
                
                // Percentage
                let pct = viewModel.totalFights > 0
                ? Int((Double(viewModel.completedPicks) / Double(viewModel.totalFights)) * 100)
                : 0
                Text("\(pct)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(BSColors.surfaceSecondary)
                    .cornerRadius(6)
            }
            
            // Completed text
            Text("\(viewModel.completedPicks) of \(viewModel.totalFights) completed")
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Gradient progress bar
            GeometryReader { geo in
                let progress = viewModel.totalFights > 0
                ? CGFloat(viewModel.completedPicks) / CGFloat(viewModel.totalFights)
                : 0
                
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(BSColors.surfaceSecondary)
                    
                    // Gradient fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [BSColors.accent, BSColors.accentBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                        .animation(.easeOut(duration: 0.4), value: viewModel.completedPicks)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
    
    
    // MARK: - Helpers
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "open":      return BSColors.winGreen
        case "locked":    return BSColors.titleGold
        case "completed": return BSColors.textTertiary
        case "scored":    return BSColors.accentBlue
        default:          return BSColors.textHint
        }
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
