//
//  ProfileSheetView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import SwiftUI

struct ProfileSheetView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutConfirm = false
    @State private var showLogin = false
    @State private var showLegal = false

    private let biometric = BiometricAuthService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 1. Profile header (only if signed in)
                        if authVM.state == .authenticated {
                            profileHeader
                        } else {
                            signInPrompt
                        }

                        // 2. Appearance
                        appearanceSection

                        // 3. Security (only if signed in + biometric available)
                        if authVM.state == .authenticated, biometric.isAvailable {
                            securitySection
                        }

                        // 4. Session (only if signed in)
                        if authVM.state == .authenticated {
                            sessionSection
                        }

                        // 5. About
                        aboutSection
                        
                        // 6. Legal (agregar)
                        legalSection

                        // 7. Logout (only if signed in)
                        if authVM.state == .authenticated {
                            logoutButton
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
            .toolbarBackground(BSColors.background, for: .navigationBar)
            .alert("Sign Out", isPresented: $showLogoutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authVM.signOut()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - 1. Profile Header
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var profileHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(BSColors.accent.opacity(0.15))
                    .frame(width: 64, height: 64)
                Text(authVM.userInitials)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(BSColors.accent)
            }

            if let name = authVM.userDisplayName {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
            }

            if let nickname = authVM.userNickname {
                Text("@\(nickname)")
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.accent)
            }

            if let email = authVM.currentUserEmail {
                Text(email)
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(BSColors.winGreen)
                    .frame(width: 6, height: 6)
                Text("Signed in")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(BSColors.winGreen)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(BSColors.surface)
        .cornerRadius(14)
    }

    @ViewBuilder
    private var signInPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle")
                .font(.system(size: 40))
                .foregroundColor(BSColors.textHint)
            Text("Not signed in")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BSColors.textTertiary)
            Text("Sign in to unlock predictions and fight details")
                .font(.system(size: 12))
                .foregroundColor(BSColors.textHint)
                .multilineTextAlignment(.center)

            Button {
                showLogin = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                    Text("Sign In")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(BSColors.accent)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(BSColors.surface)
        .cornerRadius(14)
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - 2. Appearance
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Appearance")

            ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                Button {
                    themeManager.current = theme
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: themeIcon(theme))
                            .font(.system(size: 14))
                            .foregroundColor(BSColors.accent)
                            .frame(width: 24)
                        Text(theme.rawValue)
                            .font(.system(size: 14))
                            .foregroundColor(BSColors.textPrimary)
                        Spacer()
                        if themeManager.current == theme {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(BSColors.accent)
                        }
                    }
                    .padding(12)
                }
            }
        }
        .background(BSColors.surface)
        .cornerRadius(14)
    }

    // ═══════════════════════════════════════════════
    // MARK: - 3. Security
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Security")

            HStack(spacing: 12) {
                Image(systemName: biometric.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(BSColors.accent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick unlock")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BSColors.textPrimary)
                    Text("Use \(biometric.displayName) to unlock the app")
                        .font(.system(size: 11))
                        .foregroundColor(BSColors.textTertiary)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { SessionPolicy.biometricEnabled },
                    set: { newValue in
                        if newValue {
                            authVM.enableBiometric()
                        } else {
                            authVM.disableBiometric()
                        }
                    }
                ))
                .tint(BSColors.accent)
                .labelsHidden()
            }
            .padding(12)
        }
        .background(BSColors.surface)
        .cornerRadius(14)
    }

    // ═══════════════════════════════════════════════
    // MARK: - 4. Session
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var sessionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Session")
                .padding(.bottom, 4)

            infoRow(icon: "calendar.badge.clock", label: "Last sign in", value: lastLoginText)
            Divider().background(BSColors.border).padding(.horizontal, 12)
            infoRow(icon: "clock.badge.checkmark", label: "Expires", value: sessionExpiresText)
            Divider().background(BSColors.border).padding(.horizontal, 12)
            infoRow(icon: "shield.checkered", label: "Provider", value: authProvider)
        }
        .background(BSColors.surface)
        .cornerRadius(14)
    }

    // ═══════════════════════════════════════════════
    // MARK: - 5. About
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("About")
                .padding(.bottom, 4)

            infoRow(icon: "info.circle", label: "Version", value: "2.0.0")
            Divider().background(BSColors.border).padding(.horizontal, 12)
            infoRow(icon: "brain.head.profile", label: "AI models", value: "4")
            Divider().background(BSColors.border).padding(.horizontal, 12)
            infoRow(icon: "chart.line.uptrend.xyaxis", label: "Winner accuracy", value: "71%")
            Divider().background(BSColors.border).padding(.horizontal, 12)
            infoRow(icon: "figure.martial.arts", label: "Fights analyzed", value: "7,400+")
            Divider().background(BSColors.border).padding(.horizontal, 12)
            infoRow(icon: "person.3.fill", label: "Fighters", value: "2,200+")
        }
        .background(BSColors.surface)
        .cornerRadius(14)
    }

    // ═══════════════════════════════════════════════
    // MARK: - 6. Logout
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private var logoutButton: some View {
        Button {
            showLogoutConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14))
                Text("Sign Out")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(BSColors.lossRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(BSColors.lossRed.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // ═══════════════════════════════════════════════
    // MARK: - 6. Legal
    // ═══════════════════════════════════════════════
    @ViewBuilder
    private var legalSection: some View {
        Button {
            showLegal = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 14))
                    .foregroundColor(BSColors.textSecondary)
                    .frame(width: 24)
                Text("Legal & Privacy")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textHint)
            }
            .padding(14)
            .background(BSColors.surface)
            .cornerRadius(14)
        }
        .sheet(isPresented: $showLegal) {
            LegalView()
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Components
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(BSColors.textTertiary)
            .textCase(.uppercase)
            .kerning(1)
            .padding(.horizontal, 12)
            .padding(.top, 12)
    }

    @ViewBuilder
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(BSColors.textHint)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(BSColors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func themeIcon(_ theme: AppTheme) -> String {
        switch theme {
        case .system: return "gear"
        case .dark:   return "moon.fill"
        case .light:  return "sun.max.fill"
        }
    }

    // MARK: - Session helpers

    private var lastLoginText: String {
        guard let date = SessionPolicy.lastManualLoginDate else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private var sessionExpiresText: String {
        guard let date = SessionPolicy.lastManualLoginDate else { return "—" }
        let expiry = date.addingTimeInterval(SessionPolicy.manualLoginTTL)
        if expiry < Date() { return "Expired" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: expiry, relativeTo: Date())
    }

    private var authProvider: String {
        guard let user = AuthService.shared.currentUser else { return "—" }
        if user.providerData.contains(where: { $0.providerID == "google.com" }) {
            return "Google"
        }
        return "Email"
    }
}
