//
//  AuthViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import Foundation
import Observation
import FirebaseAuth

@Observable
final class AuthViewModel {

    var state: AuthState = .loading
    var email: String = ""
    var password: String = ""
    var errorMessage: String? = nil
    var isProcessing: Bool = false

    // Pending destination after login
    var pendingDestination: ProtectedDestination? = nil

    private let auth = AuthService.shared
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Auth State Listener

    private func listenToAuthChanges() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.evaluateState(user: user)
            }
        }
    }

    private func evaluateState(user: User?) {
        guard user != nil else {
            state = .unauthenticated
            return
        }

        if SessionPolicy.isManualLoginValid {
            state = .authenticated
        } else {
            state = .requiresManualLogin
        }
    }

    // MARK: - Actions

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your email and password"
            return
        }

        isProcessing = true
        errorMessage = nil

        Task {
            do {
                try await auth.signIn(email: email, password: password)
                clearForm()
                state = .authenticated
            } catch {
                errorMessage = mapFirebaseError(error)
            }
            isProcessing = false
        }
    }

    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your email and password"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isProcessing = true
        errorMessage = nil

        Task {
            do {
                try await auth.signUp(email: email, password: password)
                clearForm()
                state = .authenticated
            } catch {
                errorMessage = mapFirebaseError(error)
            }
            isProcessing = false
        }
    }

    func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Enter your email"
            return
        }

        isProcessing = true
        errorMessage = nil

        Task {
            do {
                try await auth.resetPassword(email: email)
                errorMessage = nil
                // Show success (handled in view)
            } catch {
                errorMessage = mapFirebaseError(error)
            }
            isProcessing = false
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            state = .unauthenticated
            clearForm()
            pendingDestination = nil
        } catch {
            errorMessage = "Failed to sign out"
        }
    }

    // MARK: - Route Protection

    func requireAuth(for destination: ProtectedDestination) -> Bool {
        if state == .authenticated {
            return true
        }
        pendingDestination = destination
        return false
    }

    func completePendingNavigation() -> ProtectedDestination? {
        let dest = pendingDestination
        pendingDestination = nil
        return dest
    }

    // MARK: - Helpers

    private func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
    }

    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain else { return error.localizedDescription }

        switch AuthErrorCode(rawValue: nsError.code) {
        case .wrongPassword:          return "Incorrect password"
        case .invalidEmail:           return "Invalid email address"
        case .emailAlreadyInUse:      return "Email already in use"
        case .userNotFound:           return "Account not found"
        case .weakPassword:           return "Password is too weak"
        case .networkError:           return "Network error. Check your connection"
        case .tooManyRequests:        return "Too many attempts. Try again later"
        case .userDisabled:           return "Account has been disabled"
        case .invalidCredential:      return "Invalid credentials"
        default:                      return error.localizedDescription
        }
    }
}
