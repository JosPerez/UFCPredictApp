//
//  GameHomeView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

enum GameNavigation: Hashable {
    case eventLeaderboard(Int, String)
    case monthlyLeaderboard
    case postEventResults(Int)
    case eventsList
}

struct GameHomeView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var viewModel = GameViewModel()
    @State private var topPlayers: [MonthlyLeaderboardRowDTO] = []
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                if authVM.state != .authenticated {
                    lockedGameView
                } else if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView().tint(BSColors.accent)
                } else {
                    content
                }
            }
            .navigationDestination(for: Int.self) { eventId in
                EventPicksView(eventId: eventId)
            }
            .navigationDestination(for: GameNavigation.self) { nav in
                switch nav {
                case .eventLeaderboard(let id, let name):
                    EventLeaderboardView(eventId: id, eventName: name)
                case .monthlyLeaderboard:
                    MonthlyLeaderboardView()
                case .postEventResults(let id):
                    PostEventResultsView(eventId: id)
                case .eventsList:
                    GameEventsListView(events: viewModel.events)
                }
            }
        }
        .onAppear {
            GameLogger.screenOpened("GameHome")
            
            if authVM.state == .authenticated && viewModel.events.isEmpty {
                viewModel.fetchEvents()
                fetchTopPlayers()
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileSheetView()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                header

                // Featured event card
                if let next = viewModel.nextOpenEvent {
                    featuredEventCard(next)
                } else if let recent = viewModel.recentScoredEvent {
                    featuredEventCard(recent)
                }

                // Quick actions
                quickActions

                // Leaderboard preview
                leaderboardPreview
            }
            .padding(.bottom, 32)
        }
        .refreshable {
            viewModel.fetchEvents()
            fetchTopPlayers()
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Game")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Text("Make your picks. Climb the leaderboard.")
                    .font(.system(size: 14))
                    .foregroundColor(BSColors.textTertiary)
            }
            Spacer()
            ProfileButton(showProfile: $showProfile)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Featured Event Card

    @ViewBuilder
    private func featuredEventCard(_ event: GameEventDTO) -> some View {
        NavigationLink(value: event.eventId) {
            VStack(alignment: .leading, spacing: 12) {
                // Top row: status + fights + trophy
                HStack {
                    gameStatusBadge(event.status)

                    Text("\(event.fightCount) Fights")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(BSColors.textSecondary)

                    Spacer()

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 22))
                        .foregroundColor(statusColor(event.status).opacity(0.6))
                }

                // Event name
                Text(event.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .multilineTextAlignment(.leading)

                // Date
                Text(formatDate(event.eventDate))
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textTertiary)

                // Progress
                HStack {
                    Text("\(event.userCompletedPicks) / \(event.fightCount) picks completed")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(BSColors.textSecondary)
                    Spacer()
                    let pct = event.fightCount > 0
                        ? Int((Double(event.userCompletedPicks) / Double(event.fightCount)) * 100)
                        : 0
                    Text("\(pct)%")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                }

                // Gradient progress bar
                gradientProgressBar(
                    progress: event.fightCount > 0
                        ? Double(event.userCompletedPicks) / Double(event.fightCount)
                        : 0
                )

                // CTA button
                Text(ctaLabel(event.cta))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ctaColor(event.cta))
                    .cornerRadius(10)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(BSColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(statusColor(event.status).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    // MARK: - Quick Actions

    @ViewBuilder
    private var quickActions: some View {
        HStack(spacing: 10) {
            NavigationLink(value: GameNavigation.eventsList) {
                quickActionButton(
                    icon: "calendar",
                    label: "Events to Play"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: GameNavigation.monthlyLeaderboard) {
                quickActionButton(
                    icon: "trophy",
                    label: "Monthly Leaderboard"
                )
            }
            .buttonStyle(.plain)

            if let scored = viewModel.recentScoredEvent {
                NavigationLink(value: GameNavigation.postEventResults(scored.eventId)) {
                    quickActionButton(
                        icon: "checkmark.circle",
                        label: "Latest Results"
                    )
                }
                .buttonStyle(.plain)
            } else {
                quickActionButton(
                    icon: "checkmark.circle",
                    label: "Latest Results"
                )
                .opacity(0.4)
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func quickActionButton(icon: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(BSColors.textSecondary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(BSColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(BSColors.border, lineWidth: 0.5)
        )
    }

    // MARK: - Leaderboard Preview

    @ViewBuilder
    private var leaderboardPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOP PLAYERS THIS MONTH")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(BSColors.textHint)
                        .kerning(1.5)
                    Text("Leaderboard Preview")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                }
                Spacer()
                NavigationLink(value: GameNavigation.monthlyLeaderboard) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 18))
                        .foregroundColor(BSColors.textSecondary)
                }
            }

            if topPlayers.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "trophy")
                            .font(.system(size: 20))
                            .foregroundColor(BSColors.textHint)
                        Text("No scores yet this month")
                            .font(.system(size: 12))
                            .foregroundColor(BSColors.textHint)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                VStack(spacing: 6) {
                    ForEach(topPlayers.prefix(3)) { player in
                        topPlayerRow(player)
                    }
                }
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func topPlayerRow(_ player: MonthlyLeaderboardRowDTO) -> some View {
        HStack(spacing: 12) {
            Text("#\(player.rank ?? 0)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(rankColor(player.rank))
                .frame(width: 28)

            Text(player.nickname)
                .font(.system(size: 15, weight: player.isCurrentUser ? .bold : .semibold))
                .foregroundColor(player.isCurrentUser ? BSColors.accent : BSColors.textPrimary)
                .lineLimit(1)

            if player.isCurrentUser {
                Text("YOU")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(BSColors.accent)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(BSColors.accent.opacity(0.12))
                    .cornerRadius(3)
            }

            Spacer()

            Text("\(player.totalPoints) pts")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(BSColors.surfaceSecondary)
        .cornerRadius(8)
    }

    // MARK: - Locked View

    @ViewBuilder
    private var lockedGameView: some View {
        VStack(spacing: 16) {
            header
            Spacer()
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 44))
                .foregroundColor(BSColors.textHint)
            Text("Sign in to play")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(BSColors.textPrimary)
            Text("Predict fight outcomes, earn points, and compete on the leaderboard")
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Components

    @ViewBuilder
    private func gradientProgressBar(progress: Double) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(BSColors.surfaceSecondary)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [BSColors.accent, BSColors.accentBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(progress))
            }
        }
        .frame(height: 6)
    }

    @ViewBuilder
    private func gameStatusBadge(_ status: String) -> some View {
        Text(status.uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(statusColor(status))
            .kerning(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor(status).opacity(0.15))
            .cornerRadius(6)
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "open":      return BSColors.winGreen
        case "locked":    return BSColors.textTertiary
        case "completed": return BSColors.titleGold
        case "scored":    return BSColors.accentBlue
        default:          return BSColors.textHint
        }
    }

    private func ctaLabel(_ cta: String) -> String {
        switch cta {
        case "make_picks":   return "Make Picks"
        case "edit_picks":   return "Edit Picks"
        case "view_picks":   return "View Picks"
        case "view_results": return "View Results"
        default:             return "Open"
        }
    }

    private func ctaColor(_ cta: String) -> Color {
        switch cta {
        case "view_results": return BSColors.accentBlue
        case "view_picks":   return BSColors.textTertiary
        default:             return BSColors.accent
        }
    }

    private func rankColor(_ rank: Int?) -> Color {
        switch rank {
        case 1:    return BSColors.titleGold
        case 2, 3: return BSColors.accent
        default:   return BSColors.textTertiary
        }
    }

    private func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let output = DateFormatter()
        output.dateFormat = "EEE, MMM d, yyyy"
        return output.string(from: date)
    }

    // MARK: - Fetch Top Players

    private func fetchTopPlayers() {
        Task {
            do {
                topPlayers = try await GameAPIClient.shared.getMonthlyLeaderboard()
            } catch {
                topPlayers = []
            }
        }
    }
}
