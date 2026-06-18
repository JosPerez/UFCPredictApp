//
//  DataPrivacyView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import SwiftUI

struct DataPrivacyView: View {
    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    dataRow(
                        icon: "envelope.fill",
                        title: "Email",
                        description: "Used for authentication only. Never shared.",
                        stored: "Firebase Auth"
                    )
                    dataRow(
                        icon: "person.fill",
                        title: "Name & Nickname",
                        description: "Displayed on leaderboards. Nickname is public.",
                        stored: "Firebase + PostgreSQL"
                    )
                    dataRow(
                        icon: "hand.point.up.fill",
                        title: "Fight Picks",
                        description: "Your predictions per event. Used for scoring.",
                        stored: "PostgreSQL"
                    )
                    dataRow(
                        icon: "chart.bar.fill",
                        title: "Scores & Rankings",
                        description: "Calculated from your picks. Visible on leaderboards.",
                        stored: "PostgreSQL"
                    )
                    dataRow(
                        icon: "brain.head.profile",
                        title: "Prediction History",
                        description: "Cached locally on your device.",
                        stored: "Device only"
                    )
                    dataRow(
                        icon: "mappin.circle.fill",
                        title: "Location",
                        description: "Not collected.",
                        stored: "Never"
                    )
                    dataRow(
                        icon: "megaphone.fill",
                        title: "Advertising",
                        description: "No ads. No tracking. No third-party analytics.",
                        stored: "Never"
                    )

                    // Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BSColors.textPrimary)
                        Text("We collect the minimum data needed to run the app. We do not sell your data. We do not show ads. We do not track you across apps. You can delete your account and all associated data at any time.")
                            .font(.system(size: 12))
                            .foregroundColor(BSColors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(BSColors.surface)
                    .cornerRadius(12)
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Data & Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func dataRow(icon: String, title: String, description: String, stored: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(BSColors.accent)
                .frame(width: 24, alignment: .center)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BSColors.textPrimary)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Image(systemName: "server.rack")
                        .font(.system(size: 8))
                    Text(stored)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(BSColors.textHint)
            }

            Spacer()
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }
}
