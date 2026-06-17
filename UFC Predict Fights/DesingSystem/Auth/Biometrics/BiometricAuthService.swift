//
//  BiometricAuthService.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import Foundation
import LocalAuthentication

final class BiometricAuthService {

    static let shared = BiometricAuthService()
    private init() {}

    enum BiometricType {
        case faceID
        case touchID
        case none
    }

    var availableType: BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID:  return .faceID
        case .touchID: return .touchID
        default:       return .none
        }
    }

    var isAvailable: Bool {
        availableType != .none
    }

    var iconName: String {
        switch availableType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .none:    return "lock.fill"
        }
    }

    var displayName: String {
        switch availableType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        case .none:    return "Biometrics"
        }
    }

    func authenticate() async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricError.notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock OctAIQ"
            )
            return success
        } catch let authError as LAError {
            switch authError.code {
            case .userCancel, .appCancel, .systemCancel:
                throw BiometricError.cancelled
            case .userFallback:
                throw BiometricError.fallbackToPassword
            case .biometryLockout:
                throw BiometricError.lockedOut
            default:
                throw BiometricError.failed
            }
        }
    }
}

enum BiometricError: LocalizedError {
    case notAvailable
    case cancelled
    case fallbackToPassword
    case lockedOut
    case failed

    var errorDescription: String? {
        switch self {
        case .notAvailable:      return "Biometric authentication not available"
        case .cancelled:         return nil  // Don't show error for cancel
        case .fallbackToPassword: return nil
        case .lockedOut:         return "Biometric locked. Use your password"
        case .failed:            return "Biometric authentication failed"
        }
    }
}
