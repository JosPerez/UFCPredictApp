//
//  BSColor.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 03/06/26.
//

import SwiftUI

struct BSColors {

    // MARK: - Backgrounds
    static let background = Color(
        light: "F2F2F7",
        dark:  "0A0A0A"
    )
    static let surface = Color(
        light: "FFFFFF",
        dark:  "1C1C1E"
    )
    static let surfaceSecondary = Color(
        light: "E5E5EA",
        dark:  "252525"
    )

    // MARK: - Text
    static let textPrimary = Color(
        light: "000000",
        dark:  "FFFFFF"
    )
    static let textSecondary = Color(
        light: "555555",
        dark:  "AAAAAA"
    )
    static let textTertiary = Color(
        light: "888888",
        dark:  "666666"
    )
    static let textHint = Color(
        light: "BBBBBB",
        dark:  "3A3A3A"
    )

    // MARK: - Accents (same in both modes)
    static let accent      = Color(hex: "FF3B30")
    static let accentBlue  = Color(hex: "3B82F6")
    static let winGreen    = Color(hex: "34C759")
    static let titleGold   = Color(hex: "FFD700")

    // MARK: - Borders
    static let border = Color(
        light: "D1D1D6",
        dark:  "1A1A1A"
    )
}

// MARK: - Adaptive Color initializer

extension Color {
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}

// MARK: - Placeholder extension for TextField

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
