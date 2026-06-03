//
//  LaunchView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 03/06/26.
//

import SwiftUI

struct LaunchView: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.85
    @State private var isFinished = false

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            VStack(spacing: 20) {
                // App icon
                Image("AppIconLaunch")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(28)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // App name
                VStack(spacing: 4) {
                    Text("OctAIQ")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    Text("MMA Fight Predictor")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "888888"))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1.0
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeIn(duration: 0.3)) {
                    isFinished = true
                }
            }
        }
    }

    var finished: Bool { isFinished }
}
