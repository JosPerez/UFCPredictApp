//
//  SessionPolicy.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import Foundation

struct SessionPolicy {
    static let manualLoginTTL: TimeInterval = 7 * 24 * 60 * 60  // 7 days

    private static let lastManualLoginKey = "lastManualLoginDate"
    private static let biometricEnabledKey = "biometricEnabled"

    // MARK: - Manual Login Date

    static var lastManualLoginDate: Date? {
        get { UserDefaults.standard.object(forKey: lastManualLoginKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastManualLoginKey) }
    }

    static func recordManualLogin() {
        lastManualLoginDate = Date()
    }

    static var isManualLoginValid: Bool {
        guard let lastLogin = lastManualLoginDate else { return false }
        return Date().timeIntervalSince(lastLogin) < manualLoginTTL
    }

    // MARK: - Biometric

    static var biometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: biometricEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: biometricEnabledKey) }
    }

    // MARK: - Logout

    static func clearSession() {
        lastManualLoginDate = nil
        biometricEnabled = false
    }
}
