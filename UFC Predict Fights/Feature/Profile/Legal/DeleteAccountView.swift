//
//  DeleteAccountView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import SwiftUI
import FirebaseAuth

struct DeleteAccountView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    @State private var confirmText = ""
    @State private var isDeleting = false
    @State private var errorMessage: String? = nil
    @State private var showFinalConfirm = false

    private let confirmWord = "DELETE"

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Warning
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(BSColors.lossRed)

                        Text("Delete your account?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(BSColors.textPrimary)

                        Text("This will permanently delete:")
                            .font(.system(size: 14))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    .padding(.top, 20)

                    // What gets deleted
                    VStack(alignment: .leading, spacing: 8) {
                        deleteItem("Your account and login credentials")
                        deleteItem("Your profile (name, nickname)")
                        deleteItem("All fight picks and history")
                        deleteItem("All scores and leaderboard entries")
                        deleteItem("Prediction history")
                    }
                    .padding(14)
                    .background(BSColors.lossRed.opacity(0.06))
                    .cornerRadius(12)

                    // Cannot undo
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.uturn.left.circle.fill")
                            .font(.system(size: 14))
                        Text("This action cannot be undone")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(BSColors.lossRed)

                    // Confirm input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type \(confirmWord) to confirm")
                            .font(.system(size: 13))
                            .foregroundColor(BSColors.textTertiary)

                        TextField("", text: $confirmText, prompt: Text(confirmWord).foregroundColor(BSColors.textHint))
                            .font(.system(size: 15))
                            .foregroundColor(BSColors.textPrimary)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(BSColors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        confirmText == confirmWord
                                            ? BSColors.lossRed.opacity(0.5)
                                            : BSColors.border,
                                        lineWidth: 1
                                    )
                            )
                    }

                    // Error
                    if let error = errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                            Text(error)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(BSColors.lossRed)
                    }

                    // Delete button
                    Button {
                        showFinalConfirm = true
                    } label: {
                        HStack(spacing: 8) {
                            if isDeleting {
                                ProgressView().tint(.white)
                            }
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14))
                            Text("Delete my account")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            confirmText == confirmWord
                                ? BSColors.lossRed
                                : BSColors.lossRed.opacity(0.3)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(confirmText != confirmWord || isDeleting)

                    // Cancel
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel, keep my account")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BSColors.textTertiary)
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Final confirmation", isPresented: $showFinalConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete forever", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all data. This cannot be undone.")
        }
    }

    @ViewBuilder
    private func deleteItem(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 11))
                .foregroundColor(BSColors.lossRed)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(BSColors.textSecondary)
        }
    }

    private func deleteAccount() {
        isDeleting = true
        errorMessage = nil

        Task {
            do {
                guard let user = Auth.auth().currentUser else {
                    errorMessage = "No user session found"
                    isDeleting = false
                    return
                }

                // 1. Delete Firestore profile
                try await UserProfileService.shared.deleteProfile(uid: user.uid)

                // 2. Delete Firebase Auth account
                try await user.delete()

                // 3. Clear local state
                await MainActor.run {
                    authVM.signOut()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    if (error as NSError).code == AuthErrorCode.requiresRecentLogin.rawValue {
                        errorMessage = "Please sign out, sign back in, and try again"
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    isDeleting = false
                }
            }
        }
    }
}
