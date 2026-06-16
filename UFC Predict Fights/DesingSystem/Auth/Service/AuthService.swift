//
//  AuthService.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import Foundation
import FirebaseAuth

final class AuthService {

    static let shared = AuthService()
    private init() {}

    var currentUser: User? {
        Auth.auth().currentUser
    }

    var isSignedIn: Bool {
        currentUser != nil
    }

    // MARK: - Email / Password

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
        SessionPolicy.recordManualLogin()
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
        SessionPolicy.recordManualLogin()
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: - Google Sign-In (implemented in Phase 3)

    func signInWithGoogle() async throws {
        // Placeholder — Phase 3
        fatalError("Not implemented yet")
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        SessionPolicy.clearSession()
    }
}
