//
//  AuthComponents.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import SwiftUI

// MARK: - Text Field

func authTextField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
    HStack(spacing: 12) {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundColor(BSColors.textHint)
            .frame(width: 20)

        TextField("", text: text, prompt: Text(placeholder).foregroundColor(BSColors.textHint))
            .font(.system(size: 15))
            .foregroundColor(BSColors.textPrimary)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
    .padding(14)
    .background(BSColors.surface)
    .cornerRadius(12)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(BSColors.border, lineWidth: 1)
    )
}

// MARK: - Secure Field

func authSecureField(icon: String, placeholder: String, text: Binding<String>) -> some View {
    HStack(spacing: 12) {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundColor(BSColors.textHint)
            .frame(width: 20)

        SecureField("", text: text, prompt: Text(placeholder).foregroundColor(BSColors.textHint))
            .font(.system(size: 15))
            .foregroundColor(BSColors.textPrimary)
            .textInputAutocapitalization(.never)
    }
    .padding(14)
    .background(BSColors.surface)
    .cornerRadius(12)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(BSColors.border, lineWidth: 1)
    )
}

// MARK: - Error Banner

func errorBanner(_ message: String) -> some View {
    HStack(spacing: 8) {
        Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 12))
            .foregroundColor(BSColors.lossRed)
        Text(message)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(BSColors.lossRed)
            .lineLimit(2)
        Spacer()
    }
    .padding(12)
    .background(BSColors.lossRed.opacity(0.1))
    .cornerRadius(10)
}
