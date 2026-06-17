//
//  ProfileButton.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//
import SwiftUI

struct ProfileButton: View {
    @Environment(AuthViewModel.self) private var authVM
    @Binding var showProfile: Bool

    var body: some View {
        Button {
            showProfile = true
        } label: {
            if authVM.state == .authenticated {
                // Logged in — show avatar
                ZStack {
                    Circle()
                        .fill(BSColors.accent.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Text(authVM.userInitials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(BSColors.accent)
                }
            } else {
                // Not logged in — show sign in
                Image(systemName: "person.circle")
                    .font(.system(size: 32))
                    .foregroundColor(BSColors.textHint)
            }
        }
    }
}
