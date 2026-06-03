//
//  ThemeManager.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 03/06/26.
//

import SwiftUI
import Observation

enum AppTheme: String, CaseIterable {
    case system = "System"
    case dark   = "Dark"
    case light  = "Light"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark:   return .dark
        case .light:  return .light
        }
    }
}

@MainActor
@Observable
final class ThemeManager {

    var current: AppTheme {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "app_theme")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "app_theme") ?? "System"
        self.current = AppTheme(rawValue: saved) ?? .system
    }
}
