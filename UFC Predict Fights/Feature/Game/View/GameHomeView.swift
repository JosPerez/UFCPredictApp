//
//  GameHomeView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI

struct GameHomeView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var viewModel = GameViewModel()
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                if authVM.state != .authenticated {
                    lockedGameView
                } else if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView().tint(BSColors.accent)
                } else if let error = viewModel.errorMessage {
                    ErrorStateView(message: error) {
                        viewModel.fetchEvents()
                    }
                } else {
                    content
                }
            }
            .navigationDestination(for: Int.self) { eventId in
                EventPicksView(eventId: eventId)
            }
        }
        .onAppear {
            if authVM.state == .authenticated && viewModel.events.isEmpty {
                viewModel.fetchEvents()
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
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Game")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    Spacer()
                    ProfileButton(showProfile: $showProfile)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Next event to play
                if let next = viewModel.nextOpenEvent {
                    nextEventCard(next)
                }

                // Recent results
                if let scored = viewModel.recentScoredEvent {
                    recentResultCard(scored)
                }

                // All events
                if !viewModel.events.isEmpty {
                    eventsList
                }
            }
            .padding(.bottom, 32)
        }
        .refreshable {
            viewModel.fetchEvents()
        }
    }

    // MARK: - Next Event Card

    @ViewBuilder
    private func nextEventCard(_ event: GameEventDTO) -> some View {
        NavigationLink(value: event.eventId) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Next event")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(BSColors.accent)
                        .textCase(.uppercase)
                        .kerning(1)
                    Spacer()
                    gameStatusBadge(event.status)
                }

                Text(event.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .multilineTextAlignment(.leading)

                if let loc = event.location {
                    Text(loc)
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textSecondary)
                }

                Text(formatDate(event.eventDate))
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)

                HStack(spacing: 12) {
                    // Fights
                    HStack(spacing: 4) {
                        Image(systemName: "figure.martial.arts")
                            .font(.system(size: 10))
                        Text("\(event.fightCount) Fights")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(BSColors.textSecondary)

                    // Picks progress
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 10))
                        Text("\(event.picksProgress) picks")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(event.userCompletedPicks == event.fightCount
                        ? BSColors.winGreen
                        : BSColors.textTertiary
                    )

                    Spacer()

                    // CTA
                    HStack(spacing: 4) {
                        Text(ctaLabel(event.cta))
                            .font(.system(size: 11, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(BSColors.accent)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [BSColors.accent.opacity(0.12), BSColors.surface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(BSColors.accent.opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    // MARK: - Recent Result Card

    @ViewBuilder
    private func recentResultCard(_ event: GameEventDTO) -> some View {
        NavigationLink(value: event.eventId) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent results")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(BSColors.winGreen)
                        .textCase(.uppercase)
                        .kerning(1)
                    Text(event.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                        .lineLimit(1)
                }
                Spacer()
                if let points = event.userEventPoints {
                    VStack(spacing: 2) {
                        Text("\(points)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(BSColors.winGreen)
                        Text("pts")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(BSColors.textHint)
                    }
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textHint)
            }
            .padding(14)
            .background(BSColors.surface)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    // MARK: - Events List

    @ViewBuilder
    private var eventsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All events")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(BSColors.textHint)
                .textCase(.uppercase)
                .kerning(1)
                .padding(.horizontal, 16)

            ForEach(viewModel.events) { event in
                NavigationLink(value: event.eventId) {
                    gameEventCard(event)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Event Card

    @ViewBuilder
    private func gameEventCard(_ event: GameEventDTO) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(event.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(BSColors.textPrimary)
                        .lineLimit(1)
                    gameStatusBadge(event.status)
                }

                Text(formatDate(event.eventDate))
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textTertiary)
            }

            Spacer()

            // Progress or points
            if event.isScored, let points = event.userEventPoints {
                Text("\(points) pts")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(BSColors.winGreen)
            } else {
                Text(event.picksProgress)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(event.userCompletedPicks == event.fightCount
                        ? BSColors.winGreen
                        : BSColors.textTertiary
                    )
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundColor(BSColors.textHint)
        }
        .padding(12)
        .background(BSColors.surface)
        .cornerRadius(10)
    }

    // MARK: - Locked View

    @ViewBuilder
    private var lockedGameView: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Game")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
                ProfileButton(showProfile: $showProfile)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

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
    private func gameStatusBadge(_ status: String) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case "open":      return ("Open", BSColors.winGreen)
            case "locked":    return ("Locked", BSColors.titleGold)
            case "completed": return ("Completed", BSColors.textTertiary)
            case "scored":    return ("Scored", BSColors.accentBlue)
            default:          return (status, BSColors.textHint)
            }
        }()

        Text(text.uppercased())
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(4)
    }

    private func ctaLabel(_ cta: String) -> String {
        switch cta {
        case "make_picks":   return "Make picks"
        case "edit_picks":   return "Edit picks"
        case "view_picks":   return "View picks"
        case "view_results": return "View results"
        default:             return "Open"
        }
    }

    private func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let output = DateFormatter()
        output.dateFormat = "MMMM d, yyyy"
        return output.string(from: date)
    }
}
