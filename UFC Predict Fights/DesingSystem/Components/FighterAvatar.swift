//
//  FighterAvatar.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 03/06/26.
//

import SwiftUI

struct FighterAvatar: View {
    let imageUrl: String?
    let initials: String
    var size: CGFloat = 40
    var accentColor: Color = BSColors.accent

    var body: some View {
        CachedAsyncImage(url: imageUrl, size: size) {
            // Fallback: initials circle
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                Text(initials)
                    .font(.system(size: size * 0.35, weight: .bold))
                    .foregroundColor(accentColor)
            }
        }
    }
}
