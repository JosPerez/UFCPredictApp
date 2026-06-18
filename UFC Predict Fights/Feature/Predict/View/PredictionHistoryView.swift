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
                    Text(prediction.fighterAName.shortName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            prediction.fighterAProb > prediction.fighterBProb
                                ? BSColors.accent : BSColors.textTertiary
                        )
                }
                .frame(maxWidth: .infinity)

                // Probabilities
                VStack(spacing: 2) {
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
                    // Probability mini bar
                    GeometryReader { geo in
                        HStack(spacing: 1) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(BSColors.accent)
                                .frame(width: geo.size.width * prediction.fighterAProb)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(BSColors.accentBlue)
                        }
                    }
                    .frame(width: 80, height: 4)
                }

                // Blue corner
                VStack(spacing: 4) {
                    FighterAvatar(
                        imageUrl: prediction.fighterBImg,
                        initials: initials(prediction.fighterBName),
                        size: 36,
                        accentColor: BSColors.accentBlue
                    )
                    Text(prediction.fighterBName.shortName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            prediction.fighterBProb > prediction.fighterAProb
                                ? BSColors.accentBlue : BSColors.textTertiary
                        )
                }
                .frame(maxWidth: .infinity)
            }

            // Method + Outcome row
            if prediction.methodDecProb != nil || prediction.finishProb != nil {
                HStack(spacing: 6) {
                    // Predicted method badge
                    if let method = prediction.predictedMethod, let prob = prediction.predictedMethodProb {
                        HStack(spacing: 4) {
                            Image(systemName: methodIcon(method))
                                .font(.system(size: 8))
                            Text("\(method) \(Int(prob * 100))%")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(methodColor(method))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(methodColor(method).opacity(0.1))
                        .cornerRadius(6)
                    }

                    // Outcome badge
                    if let finish = prediction.finishProb {
                        let isFinish = finish > 0.5
                        HStack(spacing: 4) {
                            Image(systemName: isFinish ? "flame.fill" : "clock.fill")
                                .font(.system(size: 8))
                            Text(isFinish ? "Finish \(Int(finish * 100))%" : "Decision \(Int((1 - finish) * 100))%")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(isFinish ? BSColors.accent : BSColors.accentBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((isFinish ? BSColors.accent : BSColors.accentBlue).opacity(0.1))
                        .cornerRadius(6)
                    }

                    Spacer()
                }
            }

            // Bottom: confidence + date
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(confidenceColor(prediction.confidence))
                        .frame(width: 6, height: 6)
                    Text(prediction.confidence)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(confidenceColor(prediction.confidence))
                }

                Spacer()

                Text(prediction.createdAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                    .font(.system(size: 10))
                    .foregroundColor(BSColors.textHint)
            }
        }
        .padding(12)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.last?.prefix(1) ?? ""
        return "\(f)\(l)"
    }

    private func confidenceColor(_ confidence: String) -> Color {
        switch confidence {
        case "HIGH":   return BSColors.winGreen
        case "MEDIUM": return BSColors.titleGold
        default:       return BSColors.textTertiary
        }
    }

    private func methodColor(_ method: String) -> Color {
        switch method {
        case "KO/TKO": return BSColors.accent
        case "SUB":    return BSColors.winGreen
        default:       return BSColors.accentBlue
        }
    }

    private func methodIcon(_ method: String) -> String {
        switch method {
        case "KO/TKO": return "bolt.fill"
        case "SUB":    return "arrow.triangle.2.circlepath"
        default:       return "hand.raised.fill"
        }
    }
}
