//
//  BiometricUnlockView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import SwiftUI

struct BiometricUnlockView: View {
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Icon
                Image(systemName: authVM.biometricIconName)
                    .font(.system(size: 56))
                    .foregroundColor(BSColors.accent)

                Text("Welcome back")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)

                Text("Unlock with \(authVM.biometricDisplayName) to continue")
                    .font(.system(size: 14))
                    .foregroundColor(BSColors.textTertiary)

                // Error
                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(BSColors.lossRed)
                        .padding(.horizontal, 24)
                }

                // Unlock button
                Button {
                    authVM.attemptBiometricUnlock()
                } label: {
                    HStack(spacing: 10) {
                        if authVM.isProcessing {
                            ProgressView().tint(.white)
                        }
                        Image(systemName: authVM.biometricIconName)
                            .font(.system(size: 18))
                        Text("Unlock")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BSColors.accent)
                    .cornerRadius(12)
                }
                .disabled(authVM.isProcessing)
                .padding(.horizontal, 40)

                // Use password instead
                Button {
                    authVM.skipBiometric()
                } label: {
                    Text("Use password instead")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                }

                Spacer()
            }
        }
        .onAppear {
            authVM.attemptBiometricUnlock()
        }
    }
}
