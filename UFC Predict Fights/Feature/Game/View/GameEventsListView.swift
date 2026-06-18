//
//  GameEventsListView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import SwiftUI

struct GameEventsListView: View {
    let events: [GameEventDTO]

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(events) { event in
                        NavigationLink(value: event.eventId) {
                            eventCard(event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Events to Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Event Card

    @ViewBuilder
    private func eventCard(_ event: GameEventDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name + status
            HStack(alignment: .top) {
                Text(event.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
                statusBadge(event.status)
            }

            // Date
            Text(formatDate(event.eventDate))
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)

            // Progress row
            HStack {
                Text("\(event.fightCount) Fights")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(BSColors.textSecondary)
                Spacer()
                Text("\(event.userCompletedPicks) / \(event.fightCount)")
                    .font(.system(size: 13, weight: event.userCompletedPicks == event.fightCount ? .bold : .medium))
                    .foregroundColor(
                        event.userCompletedPicks == event.fightCount
                            ? BSColors.winGreen
                            : BSColors.textSecondary
                    )
                if event.userCompletedPicks == event.fightCount && event.fightCount > 0 {
                    Text("Complete")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(BSColors.winGreen)
                }
            }

            // Gradient progress bar
            gradientProgressBar(
                progress: event.fightCount > 0
                    ? Double(event.userCompletedPicks) / Double(event.fightCount)
                    : 0,
                isComplete: event.userCompletedPicks == event.fightCount && event.fightCount > 0
            )

            // Status message
            statusMessage(event)

            // CTA button
            Text(ctaLabel(event.cta))
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(ctaColor(event))
                .cornerRadius(10)
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
    }

    // MARK: - Status Message

    @ViewBuilder
    private func statusMessage(_ event: GameEventDTO) -> some View {
        HStack(spacing: 6) {
            Image(systemName: statusIcon(event))
                .font(.system(size: 11))
            Text(statusText(event))
                .font(.system(size: 12))
        }
        .foregroundColor(statusTextColor(event))
    }

    private func statusIcon(_ event: GameEventDTO) -> String {
        switch event.status {
        case "open":      return "lock.open.fill"
        case "locked":    return "lock.fill"
        case "scored":    return "trophy.fill"
        default:          return "clock"
        }
    }

    private func statusText(_ event: GameEventDTO) -> String {
        switch event.status {
        case "open":
            return "Locks \(formatLockTime(event.lockAt))"
        case "locked":
            return "Locked for review"
        case "scored":
            if let pts = event.userEventPoints {
                return "Results are in — \(pts) pts"
            }
            return "Results are in"
        case "completed":
            return "Awaiting results"
        default:
            return event.status
        }
    }

    private func statusTextColor(_ event: GameEventDTO) -> Color {
        switch event.status {
        case "open":      return BSColors.textTertiary
        case "locked":    return BSColors.textHint
        case "scored":    return BSColors.accentBlue
        case "completed": return BSColors.titleGold
        default:          return BSColors.textHint
        }
    }

    // MARK: - Components

    @ViewBuilder
    private func gradientProgressBar(progress: Double, isComplete: Bool) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(BSColors.surfaceSecondary)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        isComplete
                            ? LinearGradient(
                                colors: [BSColors.accent, BSColors.accentBlue, BSColors.winGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                            : LinearGradient(
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
    private func statusBadge(_ status: String) -> some View {
        Text(status.uppercased())
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(statusBadgeColor(status))
            .kerning(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusBadgeColor(status).opacity(0.15))
            .cornerRadius(6)
    }

    private func statusBadgeColor(_ status: String) -> Color {
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

    private func ctaColor(_ event: GameEventDTO) -> Color {
        switch event.status {
        case "scored":    return BSColors.accentBlue
        case "locked", "completed": return BSColors.textTertiary.opacity(0.6)
        default:          return BSColors.accent
        }
    }

    // MARK: - Formatters

    private func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let output = DateFormatter()
        output.dateFormat = "EEE, MMM d, yyyy"
        return output.string(from: date)
    }

    private func formatLockTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a zzz"
        return formatter.string(from: date)
    }
}
