//
//  PerformanceChart.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 10/06/26.
//
import SwiftUI

// MARK: - Performance Card

struct PerformanceCard: View {
    let title: String
    let radarItems: [RadarItem]
    let stats: [PerformanceStat]

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold))
                .tracking(1)
                .foregroundColor(BSColors.accent)

            RadarChart(items: radarItems)
                .frame(height: 200)
                .padding(.horizontal, 4)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(stats) { stat in
                    PerformanceStatCard(stat: stat)
                }
            }
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }
}

// MARK: - Radar Chart

struct RadarChart: View {
    let items: [RadarItem]
    private let levels = 4

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size * 0.34

            ZStack {
                radarGrid(center: center, radius: radius)
                axisLines(center: center, radius: radius)
                filledShape(center: center, radius: radius)
                strokeShape(center: center, radius: radius)
                points(center: center, radius: radius)
                labels(center: center, radius: radius + 22)
            }
        }
    }

    private func angle(for index: Int) -> Angle {
        let step = 360.0 / Double(items.count)
        return .degrees(-90 + step * Double(index))
    }

    private func point(center: CGPoint, radius: CGFloat, index: Int, value: Double = 1) -> CGPoint {
        let a = angle(for: index).radians
        let r = radius * CGFloat(max(0, min(value, 1)))
        return CGPoint(x: center.x + cos(a) * r, y: center.y + sin(a) * r)
    }

    @ViewBuilder
    private func radarGrid(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(1...levels, id: \.self) { level in
            let lr = radius * CGFloat(level) / CGFloat(levels)
            Path { path in
                for i in items.indices {
                    let p = point(center: center, radius: lr, index: i)
                    if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
                }
                path.closeSubpath()
            }
            .stroke(BSColors.textHint.opacity(0.3), lineWidth: 0.5)
        }
    }

    @ViewBuilder
    private func axisLines(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(items.indices, id: \.self) { i in
            Path { path in
                path.move(to: center)
                path.addLine(to: point(center: center, radius: radius, index: i))
            }
            .stroke(BSColors.textHint.opacity(0.15), lineWidth: 0.5)
        }
    }

    private func filledShape(center: CGPoint, radius: CGFloat) -> some View {
        Path { path in
            for i in items.indices {
                let p = point(center: center, radius: radius, index: i, value: items[i].value)
                if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            path.closeSubpath()
        }
        .fill(BSColors.accent.opacity(0.2))
    }

    private func strokeShape(center: CGPoint, radius: CGFloat) -> some View {
        Path { path in
            for i in items.indices {
                let p = point(center: center, radius: radius, index: i, value: items[i].value)
                if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            path.closeSubpath()
        }
        .stroke(BSColors.accent, lineWidth: 2)
    }

    @ViewBuilder
    private func points(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(items.indices, id: \.self) { i in
            let p = point(center: center, radius: radius, index: i, value: items[i].value)
            Circle()
                .fill(BSColors.accent)
                .frame(width: 6, height: 6)
                .position(p)
        }
    }

    @ViewBuilder
    private func labels(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(items.indices, id: \.self) { i in
            let p = point(center: center, radius: radius, index: i)
            Text(items[i].label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(BSColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .position(p)
        }
    }
}

// MARK: - Stat Card

struct PerformanceStatCard: View {
    let stat: PerformanceStat

    var body: some View {
        VStack(spacing: 6) {
            switch stat.style {
            case .valueFirst:
                Text(stat.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(stat.title)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(BSColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

            case .titleFirst:
                Text(stat.title)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(BSColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(stat.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(BSColors.surfaceSecondary)
        .cornerRadius(8)
    }
}

// MARK: - Models

struct RadarItem: Identifiable {
    let id = UUID()
    let label: String
    let value: Double // 0.0 - 1.0
}

struct PerformanceStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let style: PerformanceStatStyle
}

enum PerformanceStatStyle {
    case valueFirst
    case titleFirst
}
