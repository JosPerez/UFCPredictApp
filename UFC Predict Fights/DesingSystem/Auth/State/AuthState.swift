//
//  AuthState.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import Foundation

enum AuthState: Equatable {
    case loading
    case unauthenticated
    case authenticated
    case requiresProfileCompletion
    case requiresManualLogin     // Sesión existe pero pasaron 7+ días
    case requiresBiometricUnlock // Sesión válida, biometría pendiente
    case error(String)
    
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
            (.unauthenticated, .unauthenticated),
            (.authenticated, .authenticated),
            (.requiresManualLogin, .requiresManualLogin),
            (.requiresBiometricUnlock, .requiresBiometricUnlock),
            (.requiresProfileCompletion, .requiresProfileCompletion):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}
