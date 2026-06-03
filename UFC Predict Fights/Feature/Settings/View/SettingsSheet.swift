//
//  SettingsSheet.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 03/06/26.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    // Theme selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Appearance")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(BSColors.textTertiary)
                            .textCase(.uppercase)
                            .kerning(1)

                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Button {
                                themeManager.current = theme
                            } label: {
                                HStack {
                                    Image(systemName: iconFor(theme))
                                        .font(.system(size: 16))
                                        .foregroundColor(BSColors.accent)
                                        .frame(width: 24)
                                    Text(theme.rawValue)
                                        .font(.system(size: 15))
                                        .foregroundColor(BSColors.textPrimary)
                                    Spacer()
                                    if themeManager.current == theme {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(BSColors.accent)
                                    }
                                }
                                .padding(12)
                                .background(BSColors.surface)
                                .cornerRadius(10)
                            }
                        }
                    }

                    // App info
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(BSColors.textTertiary)
                            .textCase(.uppercase)
                            .kerning(1)

                        VStack(spacing: 0) {
                            infoRow(label: "Version", value: "1.0.0")
                            Divider().background(BSColors.border)
                            infoRow(label: "Model accuracy", value: "66.3%")
                            Divider().background(BSColors.border)
                            infoRow(label: "Fighters", value: "931")
                        }
                        .background(BSColors.surface)
                        .cornerRadius(10)
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(BSColors.accent)
                }
            }
        }
    }

    private func iconFor(_ theme: AppTheme) -> String {
        switch theme {
        case .system: return "gear"
        case .dark:   return "moon.fill"
        case .light:  return "sun.max.fill"
        }
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(BSColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BSColors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}
