//
//  PredictionView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import SwiftUI
import BlackSpartan

@MainActor
struct PredictionView: View {
    @State private var viewModel = PredictionViewModel()
    @State private var showPickerA = false
    @State private var showPickerB = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0A0A").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Title
                        HStack {
                            Text("Predict")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)

                        // Warning banner
                        if let warning = viewModel.prediction?.warning {
                            warningBanner(warning)
                        }

                        if let prediction = viewModel.prediction {
                            resultSection(prediction)
                        } else {
                            selectionSection
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showPickerA) {
            FighterPickerView { fighter in
                viewModel.selectFighterA(fighter)
            }
        }
        .sheet(isPresented: $showPickerB) {
            FighterPickerView(
                onSelect: { fighter in
                    viewModel.selectFighterB(fighter)
                },
                allowedWeightClasses: viewModel.allowedWeightClasses
            )
        }
    }

    // MARK: - Selection Section

    private var selectionSection: some View {
        VStack(spacing: 0) {
            // Fighter A
            cornerLabel(text: "Red corner", color: Color(hex: "FF3B30"), systemIcon: "hand.raised.fill")
            if let fighter = viewModel.fighterA {
                selectedCard(fighter: fighter, accentColor: Color(hex: "FF3B30")) {
                    viewModel.clearFighterA()
                }
            } else {
                emptyCard(onTap: {
                    showPickerA = true
                },color: Color(hex: "FF3B30"))
            }

            // VS + Swap
            HStack {
                Rectangle()
                    .fill(Color(hex: "1C1C1E"))
                    .frame(height: 0.5)
                Button {
                    viewModel.swapFighters()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 10))
                        Text("VS")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FF3B30"))
                    .cornerRadius(6)
                }
                Rectangle()
                    .fill(Color(hex: "1C1C1E"))
                    .frame(height: 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Fighter B
            cornerLabel(text: "Blue corner", color: Color(hex: "3B82F6"), systemIcon: "hand.raised.fill")
            if let fighter = viewModel.fighterB {
                selectedCard(fighter: fighter, accentColor: Color(hex: "3B82F6")) {
                    viewModel.clearFighterB()
                }
            } else {
                emptyCard(onTap: {
                    showPickerB = true
                }, color: Color(hex: "3B82F6"))
            }

            // Predict button
            if viewModel.canPredict {
                Button {
                    viewModel.predict()
                } label: {
                    HStack(spacing: 6) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))
                        }
                        Text("Predict fight")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "FF3B30"))
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            } else {
                Text("Select both fighters to predict")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "FF3B30").opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "FF3B30").opacity(0.08))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "FF3B30").opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            }

            // Error
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "FF3B30"))
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Result Section

    @ViewBuilder
    private func resultSection(_ prediction: Prediction) -> some View {
        VStack(spacing: 16) {
            // Fighters face-off
            HStack(spacing: 0) {
                fighterResult(
                    name: prediction.fighterAName,
                    prob: prediction.fighterAWinProb,
                    isWinner: prediction.fighterAWinProb > prediction.fighterBWinProb
                )

                VStack(spacing: 2) {
                    Text("VS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "FF3B30"))
                }
                .frame(width: 30)

                fighterResult(
                    name: prediction.fighterBName,
                    prob: prediction.fighterBWinProb,
                    isWinner: prediction.fighterBWinProb > prediction.fighterAWinProb
                )
            }
            .padding(.horizontal, 16)

            // Probability bar
            VStack(spacing: 6) {
                HStack {
                    Text("\(Int(prediction.fighterAWinProb * 100))%")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "FF3B30"))
                    Spacer()
                    Text("\(Int(prediction.fighterBWinProb * 100))%")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "555555"))
                }
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "FF3B30"))
                            .frame(width: geo.size.width * prediction.fighterAWinProb)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "333333"))
                    }
                }
                .frame(height: 10)

                HStack {
                    Text(lastName(prediction.fighterAName))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "FF3B30"))
                    Spacer()
                    Text(lastName(prediction.fighterBName))
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "555555"))
                }
            }
            .padding(.horizontal, 16)

            // Confidence
            HStack {
                Text(prediction.confidence)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(
                        prediction.confidence == "HIGH"
                            ? Color(hex: "FF3B30")
                            : Color(hex: "888888")
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        prediction.confidence == "HIGH"
                            ? Color(hex: "FF3B30").opacity(0.12)
                            : Color(hex: "333333")
                    )
                    .cornerRadius(6)
                Spacer()
            }
            .padding(.horizontal, 16)

            // Top factors
            VStack(alignment: .leading, spacing: 8) {
                Text("Key factors")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "3a3a3a"))
                    .textCase(.uppercase)
                    .kerning(1)

                ForEach(prediction.topFactors) { factor in
                    FactorRow(
                        factor: factor,
                        fighterAName: lastName(prediction.fighterAName),
                        fighterBName: lastName(prediction.fighterBName)
                    )
                }
            }
            .padding(.horizontal, 16)

            // New prediction button
            Button {
                viewModel.reset()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12))
                    Text("New prediction")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Color(hex: "FF3B30"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Components

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "3a3a3a"))
                .textCase(.uppercase)
                .kerning(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
    
    private func cornerLabel(text: String, color: Color, systemIcon: String) -> some View {
        HStack(spacing: 6) {
            // Guante
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 20, height: 20)
                Image(systemName: systemIcon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(color)
            }
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(color)
                .textCase(.uppercase)
                .kerning(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    private func selectedCard(fighter: CachedFighter, accentColor: Color = Color(hex: "FF3B30"), onClear: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 14))
                    .foregroundColor(accentColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(fighter.fullName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text("\(fighter.recordWin)W · \(fighter.recordLoss)L · \(fighter.weightClass ?? "—")")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "555555"))
            }
            Spacer()
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(accentColor)
            }
        }
        .padding(12)
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(12)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func emptyCard(onTap: @escaping () -> Void, color: Color = Color(hex: "1C1C1E")) -> some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "1C1C1E"))
                        .frame(width: 36, height: 36)
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "333333"))
                }
                Text("Tap to select fighter")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "3a3a3a"))
                Spacer()
            }
            .padding(12)
            .background(Color(hex: "1C1C1E"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6]))
            )
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func fighterResult(name: String, prob: Double, isWinner: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isWinner ? Color(hex: "FF3B30").opacity(0.15) : Color(hex: "252525"))
                    .frame(width: 44, height: 44)
                Text(initials(name))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isWinner ? Color(hex: "FF3B30") : Color(hex: "555555"))
            }
            Text(lastName(name))
                .font(.system(size: 13, weight: isWinner ? .bold : .regular))
                .foregroundColor(isWinner ? Color(hex: "FF3B30") : Color(hex: "888888"))
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func warningBanner(_ warning: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "FF3B30"))
            VStack(alignment: .leading, spacing: 1) {
                Text("Low confidence")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "FF3B30"))
                Text(warning.replacingOccurrences(of: "_", with: " "))
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "FF3B30").opacity(0.7))
            }
            Spacer()
        }
        .padding(12)
        .background(Color(hex: "FF3B30").opacity(0.08))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "FF3B30").opacity(0.2), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Helpers

    private func initials(_ fullName: String) -> String {
        let parts = fullName.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.last?.prefix(1) ?? ""
        return "\(f)\(l)"
    }

    private func lastName(_ fullName: String) -> String {
        let parts = fullName.split(separator: " ")
        return parts.count > 1 ? String(parts.last ?? "") : fullName
    }
}

// MARK: - Factor Row

struct FactorRow: View {
    let factor: PredictionFactor
    let fighterAName: String
    let fighterBName: String

    var body: some View {
        HStack(spacing: 8) {
            Text(formatFeature(factor.feature))
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "777777"))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                // Bar
                GeometryReader { geo in
                    let width = min(abs(factor.impact) / 1.0, 1.0) * geo.size.width
                    ZStack(alignment: factor.impact >= 0 ? .leading : .trailing) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "1C1C1E"))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(factor.impact >= 0 ? Color(hex: "FF3B30") : Color(hex: "444444"))
                            .frame(width: max(width, 4))
                    }
                }
                .frame(width: 60, height: 4)

                // Value
                Text(String(format: "%+.2f", factor.impact))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(
                        factor.impact >= 0 ? Color(hex: "FF3B30") : Color(hex: "555555")
                    )
                    .frame(width: 40, alignment: .trailing)
            }
        }
    }

    private func formatFeature(_ feature: String) -> String {
        feature
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
