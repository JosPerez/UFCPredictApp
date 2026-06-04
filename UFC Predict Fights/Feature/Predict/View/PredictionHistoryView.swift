//
//  PredictionHistoryView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 03/06/26.
//

import SwiftUI
import SwiftData

struct PredictionHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CachedPrediction.createdAt, order: .reverse)
    private var predictions: [CachedPrediction]

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if predictions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 32))
                        .foregroundColor(BSColors.textHint)
                    Text("No predictions yet")
                        .font(.system(size: 14))
                        .foregroundColor(BSColors.textTertiary)
                    Text("Your predictions will appear here")
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textHint)
                }
            } else {
                List {
                    ForEach(predictions) { prediction in
                        PredictionHistoryRow(prediction: prediction)
                            .listRowBackground(BSColors.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(
                                top: 3, leading: 16, bottom: 3, trailing: 16
                            ))
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(predictions[index])
                        }
                        try? modelContext.save()
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct PredictionHistoryRow: View {
    let prediction: CachedPrediction

    var body: some View {
        VStack(spacing: 10) {
            // Fighters face-off
            HStack(spacing: 0) {
                // Red corner
                VStack(spacing: 4) {
                    FighterAvatar(
                        imageUrl: prediction.fighterAImg,
                        initials: initials(prediction.fighterAName),
                        size: 36,
                        accentColor: BSColors.accent
                    )
                    Text(lastName(prediction.fighterAName))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            prediction.fighterAProb > prediction.fighterBProb
                                ? BSColors.accent : BSColors.textPrimary
                        )
                }
                .frame(maxWidth: .infinity)

                // Probabilities
                HStack(spacing: 4) {
                    Text("\(Int(prediction.fighterAProb * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(BSColors.accent)
                    Text("-")
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textHint)
                    Text("\(Int(prediction.fighterBProb * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(BSColors.accentBlue)
                }

                // Blue corner
                VStack(spacing: 4) {
                    FighterAvatar(
                        imageUrl: prediction.fighterBImg,
                        initials: initials(prediction.fighterBName),
                        size: 36,
                        accentColor: BSColors.accentBlue
                    )
                    Text(lastName(prediction.fighterBName))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            prediction.fighterBProb > prediction.fighterAProb
                                ? BSColors.accentBlue : BSColors.textPrimary
                        )
                }
                .frame(maxWidth: .infinity)
            }

            // Bottom: confidence + date
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(prediction.confidence == "HIGH"
                            ? Color(hex: "34C759")
                            : Color(hex: "888888"))
                        .frame(width: 7, height: 7)
                    Text(prediction.confidence == "HIGH" ? "High confidence" : "Low confidence")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(prediction.confidence == "HIGH"
                            ? Color(hex: "34C759")
                            : Color(hex: "888888"))
                }
                Spacer()
                Text(prediction.createdAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "888888"))
            }
        }
        .padding(12)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.last?.prefix(1) ?? ""
        return "\(f)\(l)"
    }

    private func lastName(_ name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.count > 1 ? String(parts.last ?? "") : name
    }
}
