//
//  LoginView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    var body: some View {
        @Bindable var vm = authVM

        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Logo / Header
                        VStack(spacing: 8) {
                            Image("AppIconLaunch")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .cornerRadius(28)
                            Text("OctAIQ")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(BSColors.textPrimary)
                            Text("Sign in to unlock predictions")
                                .font(.system(size: 14))
                                .foregroundColor(BSColors.textTertiary)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 8)

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
                                placeholder: "Password",
                                text: $vm.password
                            )
                        }

                        // Forgot password
                        HStack {
                            Spacer()
                            Button {
                                showForgotPassword = true
                            } label: {
                                Text("Forgot password?")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(BSColors.accent)
                            }
                        }

                        // Error
                        if let error = authVM.errorMessage {
                            errorBanner(error)
                        }

                        // Sign In button
                        Button {
                            authVM.signIn()
                        } label: {
                            HStack(spacing: 8) {
                                if authVM.isProcessing {
                                    ProgressView().tint(.white)
                                }
                                Text("Sign In")
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

                        // Google Sign-In
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
                        
                        Spacer(minLength: 20)
                        
                        if authVM.canUseBiometric {
                            Button {
                                authVM.attemptBiometricUnlock()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: authVM.biometricIconName)
                                        .font(.system(size: 20))
                                    Text("Unlock with \(authVM.biometricDisplayName)")
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

                        Spacer(minLength: 20)

                        // Sign Up link
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 13))
                                .foregroundColor(BSColors.textTertiary)
                            Button {
                                showSignUp = true
                            } label: {
                                Text("Sign Up")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(BSColors.accent)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}
