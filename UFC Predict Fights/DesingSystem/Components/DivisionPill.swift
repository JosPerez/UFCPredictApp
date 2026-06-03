//
//  DivisionPill.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import SwiftUI
// TODO: - Divide the file into small components
// DivisionPill.swift
struct DivisionPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? BSColors.textPrimary : BSColors.textTertiary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(isSelected ? Color(hex: "FF3B30") : BSColors.surface)
                .cornerRadius(20)
        }
    }
}

// StatCard.swift
struct StatCard: View {
    let value: String
    let label: String
    let accent: Bool

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(accent ? Color(hex: "FF3B30") : BSColors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(BSColors.textHint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(BSColors.surface)
        .cornerRadius(8)
    }
}

// StatBar.swift
struct StatBar: View {
    let label: String
    let value: Double
    let max: Double
    var isPercent: Bool = false
    var unit: String = ""

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "777777"))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(BSColors.surface)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "FF3B30"))
                            .frame(width: geo.size.width * min(value / max, 1.0))
                    }
                }
                .frame(width: 80, height: 4)

                Text(displayValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .frame(width: 40, alignment: .trailing)
            }
        }
    }

    private var displayValue: String {
        if isPercent { return "\(Int(value))%" }
        if unit.isEmpty { return String(format: "%.1f", value) }
        return "\(Int(value))\(unit)"
    }
}

// ErrorStateView.swift
struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36))
                .foregroundColor(BSColors.textHint)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)
                .multilineTextAlignment(.center)
            Button("Retry", action: retry)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "FF3B30"))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(hex: "FF3B30").opacity(0.15))
                .cornerRadius(8)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// EmptyStateView.swift
struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("🥊")
                .font(.system(size: 36))
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)
            Spacer()
        }
    }
}
