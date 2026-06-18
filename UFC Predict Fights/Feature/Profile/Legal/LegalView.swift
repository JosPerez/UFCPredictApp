//
//  LegalView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import SwiftUI

struct LegalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // Privacy Policy
                        NavigationLink {
                            LegalDocView(
                                title: "Privacy Policy",
                                url: Config.privacyPolicyURL
                            )
                        } label: {
                            legalRow(
                                icon: "hand.raised.fill",
                                title: "Privacy Policy",
                                subtitle: "How we handle your data"
                            )
                        }

                        // Terms of Service
                        NavigationLink {
                            LegalDocView(
                                title: "Terms of Service",
                                url: Config.termsOfServiceURL
                            )
                        } label: {
                            legalRow(
                                icon: "doc.text.fill",
                                title: "Terms of Service",
                                subtitle: "Rules and guidelines"
                            )
                        }

                        // Data & Privacy
                        NavigationLink {
                            DataPrivacyView()
                        } label: {
                            legalRow(
                                icon: "lock.shield.fill",
                                title: "Data & Privacy",
                                subtitle: "What we collect and why"
                            )
                        }

                        // Disclaimer
                        disclaimerCard

                        // Delete account
                        deleteAccountSection
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Legal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(BSColors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(BSColors.textHint)
                    }
                }
            }
        }
    }

    // MARK: - Legal Row

    @ViewBuilder
    private func legalRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(BSColors.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BSColors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(BSColors.textHint)
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Disclaimer

    @ViewBuilder
    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(BSColors.titleGold)
                Text("Disclaimer")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
            }

            Text("OctAIQ provides AI-powered fight predictions for entertainment and informational purposes only. Predictions are not financial or betting advice. We are not affiliated with the UFC or any sports organization. All UFC-related data is used under fair use for analysis and commentary.")
                .font(.system(size: 12))
                .foregroundColor(BSColors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Delete Account

    @ViewBuilder
    private var deleteAccountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Danger zone")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(BSColors.textHint)
                .kerning(1)
                .textCase(.uppercase)

            NavigationLink {
                DeleteAccountView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(BSColors.lossRed)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete my account")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(BSColors.lossRed)
                        Text("Permanently remove your data")
                            .font(.system(size: 12))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textHint)
                }
                .padding(14)
                .background(BSColors.lossRed.opacity(0.08))
                .cornerRadius(12)
            }
        }
    }
}
