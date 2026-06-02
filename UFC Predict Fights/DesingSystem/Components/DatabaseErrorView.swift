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
            Color(hex: "0A0A0A").ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "FF3B30"))
                Text("Unable to start")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "555555"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Text("Try restarting the app. If the problem persists, reinstall.")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "3a3a3a"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}
