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
    var size: CGFloat = 44
    var accentColor: Color = Color(hex: "FF3B30")

    private var resolvedUrl: URL? {
        guard let raw = imageUrl, !raw.isEmpty else { return nil }

        // Filtrar placeholder de UFC
        if raw.contains("no-profile-image") { return nil }

        // URL completa
        if raw.hasPrefix("http") {
            return URL(string: raw)
        }

        // URL relativa — ignorar
        return nil
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.12))
                .frame(width: size, height: size)

            if let url = resolvedUrl {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure:
                        initialsText
                    case .empty:
                        initialsText
                    @unknown default:
                        initialsText
                    }
                }
            } else {
                initialsText
            }
        }
        .frame(width: size, height: size)
    }

    private var initialsText: some View {
        Text(initials)
            .font(.system(size: size * 0.3, weight: .bold))
            .foregroundColor(accentColor)
    }
}
