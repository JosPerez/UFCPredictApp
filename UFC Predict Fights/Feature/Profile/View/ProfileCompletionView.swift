//
//  ProfileCompletionView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileCompletionView: View {
    @Environment(AuthViewModel.self) private var authVM

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var nickname: String = ""
    @State private var nicknameStatus: NicknameStatus = .idle
    @State private var nicknameCheckTask: Task<Void, Never>? = nil

    enum NicknameStatus: Equatable {
        case idle
        case checking
        case available
        case taken
        case invalid
    }

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(BSColors.accent)
                        Text("Complete your profile")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(BSColors.textPrimary)
                        Text("Tell us a bit about yourself")
                            .font(.system(size: 14))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    .padding(.top, 48)

                    // Form
                    VStack(spacing: 14) {
                        // First name
                        authTextField(
                            icon: "person.fill",
                            placeholder: "First name",
                            text: $firstName
                        )

                        // Last name
                        authTextField(
                            icon: "person.fill",
                            placeholder: "Last name",
                            text: $lastName
                        )

                        // Nickname with validation
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                Image(systemName: "at")
                                    .font(.system(size: 14))
                                    .foregroundColor(BSColors.textHint)
                                    .frame(width: 20)

                                TextField("", text: $nickname, prompt: Text("Nickname").foregroundColor(BSColors.textHint))
                                    .font(.system(size: 15))
                                    .foregroundColor(BSColors.textPrimary)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .onChange(of: nickname) { _, newValue in
                                        validateNickname(newValue)
                                    }

                                // Status indicator
                                nicknameIndicator
                            }
                            .padding(14)
                            .background(BSColors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(nicknameBorderColor, lineWidth: 1)
                            )

                            // Status message
                            nicknameMessage
                        }
                    }
                    .padding(.horizontal, 24)

                    // Error from AuthViewModel
                    if let error = authVM.errorMessage {
                        errorBanner(error)
                            .padding(.horizontal, 24)
                    }

                    // Continue button
                    Button {
                        authVM.completeProfile(
                            firstName: firstName,
                            lastName: lastName,
                            nickname: nickname
                        )
                    } label: {
                        HStack(spacing: 8) {
                            if authVM.isProcessing {
                                ProgressView().tint(.white)
                            }
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canContinue ? BSColors.accent : BSColors.accent.opacity(0.4))
                        .cornerRadius(12)
                    }
                    .disabled(!canContinue || authVM.isProcessing)
                    .padding(.horizontal, 24)

                    // Skip hint
                    Text("You can update this later in settings")
                        .font(.system(size: 11))
                        .foregroundColor(BSColors.textHint)

                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            prefillFromGoogle()
        }
    }

    // MARK: - Validation

    private var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
        && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
        && nicknameStatus == .available
    }

    private func validateNickname(_ value: String) {
        nicknameCheckTask?.cancel()

        let trimmed = value.trimmingCharacters(in: .whitespaces).lowercased()

        guard !trimmed.isEmpty else {
            nicknameStatus = .idle
            return
        }

        // Local validation
        guard trimmed.count >= 3 else {
            nicknameStatus = .invalid
            return
        }

        guard trimmed.count <= 20 else {
            nicknameStatus = .invalid
            return
        }

        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        guard trimmed.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            nicknameStatus = .invalid
            return
        }

        // Remote check with debounce
        nicknameStatus = .checking

        nicknameCheckTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce

            guard !Task.isCancelled else { return }

            do {
                let available = try await UserProfileService.shared.isNicknameAvailable(trimmed)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    nicknameStatus = available ? .available : .taken
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    nicknameStatus = .idle
                }
            }
        }
    }

    // MARK: - Nickname UI

    @ViewBuilder
    private var nicknameIndicator: some View {
        switch nicknameStatus {
        case .idle:
            EmptyView()
        case .checking:
            ProgressView()
                .scaleEffect(0.7)
                .tint(BSColors.textHint)
        case .available:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(BSColors.winGreen)
        case .taken:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(BSColors.lossRed)
        case .invalid:
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(BSColors.titleGold)
        }
    }

    @ViewBuilder
    private var nicknameMessage: some View {
        switch nicknameStatus {
        case .available:
            Text("Nickname available")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(BSColors.winGreen)
                .padding(.leading, 46)
        case .taken:
            Text("Nickname already taken")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(BSColors.lossRed)
                .padding(.leading, 46)
        case .invalid:
            Text("3-20 characters, letters, numbers and underscores only")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(BSColors.titleGold)
                .padding(.leading, 46)
        default:
            EmptyView()
        }
    }

    private var nicknameBorderColor: Color {
        switch nicknameStatus {
        case .available: return BSColors.winGreen.opacity(0.5)
        case .taken:     return BSColors.lossRed.opacity(0.5)
        case .invalid:   return BSColors.titleGold.opacity(0.5)
        default:         return BSColors.border
        }
    }

    // MARK: - Prefill

    private func prefillFromGoogle() {
        guard let user = Auth.auth().currentUser else { return }

        if let displayName = user.displayName {
            let parts = displayName.split(separator: " ", maxSplits: 1)
            if parts.count >= 1 { firstName = String(parts[0]) }
            if parts.count >= 2 { lastName = String(parts[1]) }
        }
    }
}
