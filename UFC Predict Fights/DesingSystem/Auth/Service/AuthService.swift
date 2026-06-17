//
//  AuthService.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

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

    // MARK: - Google Sign-In

    @MainActor
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.missingRootViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingGoogleToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        try await Auth.auth().signIn(with: credential)
        SessionPolicy.recordManualLogin()
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        SessionPolicy.clearSession()
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case missingClientID
    case missingRootViewController
    case missingGoogleToken

    var errorDescription: String? {
        switch self {
        case .missingClientID:          return "Firebase client ID not found"
        case .missingRootViewController: return "Unable to present Google Sign-In"
        case .missingGoogleToken:       return "Google authentication failed"
        }
    }
}
