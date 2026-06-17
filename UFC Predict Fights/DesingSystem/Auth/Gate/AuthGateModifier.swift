//
//  AuthGateModifier.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import SwiftUI

struct AuthGateModifier: ViewModifier {
    @Environment(AuthViewModel.self) private var authVM
    @Binding var showLogin: Bool
    let destination: ProtectedDestination

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if authVM.requireAuth(for: destination) {
                    // Auth valid — let NavigationLink handle it
                } else {
                    showLogin = true
                }
            }
    }
}
