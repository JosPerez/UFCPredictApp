//
//  SmartSegmentedBar.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 10/06/26.
//
import SwiftUI

struct SmartSegmentedBar: View {
    let segments: [(String, Double, Color)]
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 4) {
                GeometryReader { geo in
                    let total = segments.map { max($0.1, 0.02) }.reduce(0, +)
                    let minWidth: CGFloat = 4
                    let spacing: CGFloat = 2
                    let availableWidth = geo.size.width - (CGFloat(segments.count - 1) * spacing)
                    
                    HStack(spacing: spacing) {
                        ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                            let (label, pct, color) = segment
                            let ratio = max(pct, 0.02) / total
                            let barWidth = max(availableWidth * ratio, minWidth)
                            let showInside = barWidth > 50
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(color)
                                .frame(width: barWidth, height: 24)
                                .overlay {
                                    if showInside {
                                        Text("\(label) \(Int(pct * 100))%")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                    }
                                }
                        }
                    }
                }
                .frame(height: 24)
                
                // Labels below for all segments
                HStack(spacing: 0) {
                    ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                        let (label, pct, color) = segment
                        Text("\(label) \(Int(pct * 100))%")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(color)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}
