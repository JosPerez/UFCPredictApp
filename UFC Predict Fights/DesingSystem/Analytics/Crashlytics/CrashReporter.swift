//
//  CrashReporter.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 18/06/26.
//

import Foundation
import FirebaseCrashlytics

enum CrashReporter {

    // MARK: - User Identity

    static func setUser(uid: String, nickname: String?) {
        Crashlytics.crashlytics().setUserID(uid)
        if let nickname {
            Crashlytics.crashlytics().setCustomValue(nickname, forKey: "nickname")
        }
    }

    static func clearUser() {
        Crashlytics.crashlytics().setUserID("")
    }

    // MARK: - Non-Fatal Errors

    static func recordError(_ error: Error, context: String) {
        let nsError = error as NSError
        Crashlytics.crashlytics().setCustomValue(context, forKey: "context")
        Crashlytics.crashlytics().record(error: nsError)
    }

    // MARK: - API Errors

    static func recordAPIError(endpoint: String, statusCode: Int, message: String) {
        let error = NSError(
            domain: "com.octaiq.api",
            code: statusCode,
            userInfo: [
                NSLocalizedDescriptionKey: message,
                "endpoint": endpoint,
            ]
        )
        Crashlytics.crashlytics().record(error: error)
    }

    // MARK: - Breadcrumbs

    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }

    // MARK: - Custom Keys

    static func setScreen(_ screen: String) {
        Crashlytics.crashlytics().setCustomValue(screen, forKey: "current_screen")
    }

    static func setEvent(_ eventId: Int) {
        Crashlytics.crashlytics().setCustomValue(eventId, forKey: "current_event")
    }
}
