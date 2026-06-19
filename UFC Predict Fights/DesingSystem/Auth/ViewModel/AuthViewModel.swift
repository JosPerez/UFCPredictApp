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
    
    private let biometric = BiometricAuthService.shared
    private let profileService = UserProfileService.shared
    var state: AuthState = .loading
    var email: String = ""
    var password: String = ""
    var userProfile: UserProfile? = nil
    var errorMessage: String? = nil
    var isProcessing: Bool = false
    
    var biometricAvailable: Bool {
        biometric.isAvailable && SessionPolicy.biometricEnabled
    }
    var biometricIconName: String {
        biometric.iconName
    }
    var biometricDisplayName: String {
        biometric.displayName
    }
    var canUseBiometric: Bool {
        biometric.isAvailable
        && SessionPolicy.biometricEnabled
        && auth.isSignedIn
        && SessionPolicy.isManualLoginValid
    }
    var currentUserEmail: String? {
        auth.currentUser?.email
    }
    
    var userInitials: String {
        if let profile = userProfile {
            let f = profile.firstName.prefix(1)
            let l = profile.lastName.prefix(1)
            return "\(f)\(l)".uppercased()
        }
        guard let email = currentUserEmail else { return "?" }
        return String(email.prefix(2)).uppercased()
    }

    var userDisplayName: String? {
        guard let profile = userProfile else { return nil }
        return "\(profile.firstName) \(profile.lastName)"
    }

    var userNickname: String? {
        userProfile?.nickname
    }
    
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
        guard let user else {
            state = .unauthenticated
            userProfile = nil
            return
        }
        
        // Check profile asynchronously
        Task {
            await checkProfileAndSetState(user: user)
        }
    }
    
    // Al final de evaluateState, cuando state == .authenticated:
    private func checkProfileAndSetState(user: User) async {
        do {
            let exists = try await profileService.profileExists(uid: user.uid)

            if !exists {
                state = .requiresProfileCompletion
                return
            }

            userProfile = try await profileService.getProfile(uid: user.uid)
            
            // Sync to backend on login
            if let nickname = userProfile?.nickname {
                await syncProfileToBackend(nickname: nickname)
            }

            if SessionPolicy.isManualLoginValid {
                if SessionPolicy.biometricEnabled && BiometricAuthService.shared.isAvailable {
                    state = .requiresBiometricUnlock
                } else {
                    state = .authenticated
                }
            } else {
                state = .requiresManualLogin
            }
        } catch {
            state = .authenticated
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
                // evaluateState se llama automáticamente por el auth listener
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
                // Auth listener fires → evaluateState → requiresProfileCompletion
            } catch {
                errorMessage = mapFirebaseError(error)
            }
            isProcessing = false
        }
    }
    
    func signInWithGoogle() {
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                try await auth.signInWithGoogle()
                clearForm()
                // Auth listener fires → evaluateState → checks Firestore
            } catch let error as AuthError {
                errorMessage = error.errorDescription
            } catch {
                let nsError = error as NSError
                if nsError.domain == "com.google.GIDSignIn" && nsError.code == -5 {
                    errorMessage = nil
                } else {
                    errorMessage = mapFirebaseError(error)
                }
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
            userProfile = nil
            clearForm()
            pendingDestination = nil
            CrashReporter.clearUser()
        } catch {
            errorMessage = "Failed to sign out"
        }
    }
    
    // MARK: - Profile Completion

    func completeProfile(firstName: String, lastName: String, nickname: String) {
        guard let user = auth.currentUser else { return }

        isProcessing = true
        errorMessage = nil

        Task {
            do {
                // Validate nickname
                let available = try await profileService.isNicknameAvailable(nickname)
                guard available else {
                    errorMessage = "Nickname already taken"
                    isProcessing = false
                    return
                }

                // Determine provider
                let provider = user.providerData.contains(where: { $0.providerID == "google.com" })
                    ? "google" : "email"

                // Create profile
                try await profileService.createProfile(
                    uid: user.uid,
                    firstName: firstName,
                    lastName: lastName,
                    nickname: nickname,
                    email: user.email ?? "",
                    provider: provider
                )

                // Load profile
                userProfile = try await profileService.getProfile(uid: user.uid)
                state = .authenticated
                
                if let profile = userProfile {
                    CrashReporter.setUser(uid: user.uid, nickname: profile.nickname)
                }
                
                // Sync with firebase
                await syncProfileToBackend(nickname: nickname)
            } catch {
                errorMessage = error.localizedDescription
            }
            isProcessing = false
        }
    }
    
    // MARK: - Route Protection
    
    private func syncProfileToBackend(nickname: String) async {
        guard let user = auth.currentUser else { return }

        do {
            let token = try await user.getIDToken()
            let url = URL(string: "\(Config.baseURL)/users/sync")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue(Config.apiKey, forHTTPHeaderField: "X-API-Key")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: String] = [
                "nickname": nickname,
                "first_name": userProfile?.firstName ?? "",
                "last_name": userProfile?.lastName ?? "",
            ]
            request.httpBody = try JSONEncoder().encode(body)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Profile synced to backend")
                } else {
                    print("Profile sync failed: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("Profile sync error: \(error)")
        }
    }
    
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
    
    // MARK: - Biometric
    
    func attemptBiometricUnlock() {
        guard canUseBiometric else {
            state = .requiresManualLogin
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await biometric.authenticate()
                if success {
                    state = .authenticated
                }
            } catch let error as BiometricError {
                if let message = error.errorDescription {
                    errorMessage = message
                }
                // On cancel or fallback, stay on current state
                if case .lockedOut = error {
                    state = .requiresManualLogin
                }
            } catch {
                errorMessage = "Authentication failed"
            }
            isProcessing = false
        }
    }
    
    func enableBiometric() {
        SessionPolicy.biometricEnabled = true
    }
    
    func disableBiometric() {
        SessionPolicy.biometricEnabled = false
    }
    
    func skipBiometric() {
        state = .authenticated
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
