//
//  SignUpView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    @State private var confirmPassword: String = ""
    @State private var localError: String? = nil

    var body: some View {
        @Bindable var vm = authVM

        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(BSColors.accent)
                            Text("Create Account")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(BSColors.textPrimary)
                            Text("Join OctAIQ and predict smarter")
                                .font(.system(size: 14))
                                .foregroundColor(BSColors.textTertiary)
                        }
                        .padding(.top, 32)

                        // Form
                        VStack(spacing: 14) {
                            authTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $vm.email,
                                keyboard: .emailAddress
                            )

                            authSecureField(
                                icon: "lock.fill",
                                placeholder: "Password (8+ characters)",
                                text: $vm.password
                            )

                            authSecureField(
                                icon: "lock.rotation",
                                placeholder: "Confirm password",
                                text: $confirmPassword
                            )
                        }

                        // Error
                        if let error = localError ?? authVM.errorMessage {
                            errorBanner(error)
                        }

                        // Sign Up button
                        Button {
                            createAccount()
                        } label: {
                            HStack(spacing: 8) {
                                if authVM.isProcessing {
                                    ProgressView().tint(.white)
                                }
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(BSColors.accent)
                            .cornerRadius(12)
                        }
                        .disabled(authVM.isProcessing)

                        // Divider
                        HStack(spacing: 12) {
                            Rectangle().fill(BSColors.border).frame(height: 1)
                            Text("or")
                                .font(.system(size: 12))
                                .foregroundColor(BSColors.textHint)
                            Rectangle().fill(BSColors.border).frame(height: 1)
                        }

                        // Google
                        Button {
                            authVM.signInWithGoogle()
                        } label: {
                            HStack(spacing: 10) {
                                Image("icon-google-logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                Text("Continue with Google")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(BSColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(BSColors.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(BSColors.border, lineWidth: 1)
                            )
                        }
                        .disabled(authVM.isProcessing)
                    }
                    .padding(.horizontal, 24)
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
            .toolbarBackground(.clear, for: .navigationBar)
            .onChange(of: authVM.state) { _, newState in
                if newState == .authenticated {
                    dismiss()
                }
            }
        }
    }

    private func createAccount() {
        localError = nil
        guard authVM.password == confirmPassword else {
            localError = "Passwords don't match"
            return
        }
        authVM.signUp()
    }
}
