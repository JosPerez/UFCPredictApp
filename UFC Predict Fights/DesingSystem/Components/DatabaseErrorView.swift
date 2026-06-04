//
//  DatabaseErrorView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import SwiftUI

struct DatabaseErrorView: View {
    let message: String

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(BSColors.accent)
                Text("Unable to start")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Text("Try restarting the app. If the problem persists, reinstall.")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textHint)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}
