//
//  ForgotPasswordView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    @State private var emailSent = false

    var body: some View {
        @Bindable var vm = authVM

        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    if emailSent {
                        // Success state
                        VStack(spacing: 12) {
                            Image(systemName: "envelope.badge.shield.half.filled")
                                .font(.system(size: 48))
                                .foregroundColor(BSColors.winGreen)
                            Text("Email Sent")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(BSColors.textPrimary)
                            Text("Check your inbox for a password reset link")
                                .font(.system(size: 14))
                                .foregroundColor(BSColors.textTertiary)
                                .multilineTextAlignment(.center)

                            Button {
                                dismiss()
                            } label: {
                                Text("Back to Login")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(BSColors.accent)
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        // Form state
                        VStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 40))
                                .foregroundColor(BSColors.accent)
                            Text("Reset Password")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(BSColors.textPrimary)
                            Text("Enter your email and we'll send you a reset link")
                                .font(.system(size: 14))
                                .foregroundColor(BSColors.textTertiary)
                                .multilineTextAlignment(.center)
                        }

                        authTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $vm.email,
                            keyboard: .emailAddress
                        )
                        .padding(.horizontal, 24)

                        if let error = authVM.errorMessage {
                            errorBanner(error)
                                .padding(.horizontal, 24)
                        }

                        Button {
                            sendReset()
                        } label: {
                            HStack(spacing: 8) {
                                if authVM.isProcessing {
                                    ProgressView().tint(.white)
                                }
                                Text("Send Reset Link")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(BSColors.accent)
                            .cornerRadius(12)
                        }
                        .disabled(authVM.isProcessing)
                        .padding(.horizontal, 24)
                    }

                    Spacer()
                }
            }
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
        }
    }

    private func sendReset() {
        authVM.resetPassword()
        // Check after a delay if no error appeared
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if authVM.errorMessage == nil {
                withAnimation { emailSent = true }
            }
        }
    }
}
