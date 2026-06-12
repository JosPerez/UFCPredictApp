//
//  SegmentedBar.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 10/06/26.
//
import SwiftUI

struct SegmentedBar: View {
    let segments: [(String, Double, Color)]

    private let minPct: Double = 0.05
    private let spacing: CGFloat = 2
    private let height: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let total = segments
                .map { max($0.1, minPct) }
                .reduce(0, +)

            HStack(spacing: spacing) {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                    let label = segment.0
                    let pct = segment.1
                    let color = segment.2

                    let ratio = max(pct, minPct) / total
                    let availableWidth = geo.size.width - CGFloat(segments.count - 1) * spacing
                    let width = availableWidth * ratio

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: width, height: height)
                        .overlay {
                            Text("\(label) \(Int(pct * 100))%")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                }
            }
        }
        .frame(height: height)
    }
}
