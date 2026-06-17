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
    @Bindable var viewModel: PredictionViewModel
    @State private var showPickerA = false
    @State private var showPickerB = false
    @State private var animateBar = false
    @State private var showFactorsGuide = false
    @State private var showProfile = false


    @Environment(ThemeManager.self) private var themeManager


    var body: some View {
        NavigationStack {
            ZStack {
                BSColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Title
                        HStack {
                            Text("Predict")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(BSColors.textPrimary)                            
                            Spacer()
                            ProfileButton(showProfile: $showProfile)
                            // History
                            NavigationLink {
                                PredictionHistoryView()
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18))
                                    .foregroundColor(BSColors.accent)
                            }
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
            .preferredColorScheme(themeManager.current.colorScheme)
        }
        .sheet(isPresented: $showPickerB) {
            FighterPickerView(
                onSelect: { fighter in
                    viewModel.selectFighterB(fighter)
                },
                allowedWeightClasses: viewModel.allowedWeightClasses
            )
            .preferredColorScheme(themeManager.current.colorScheme)
        }
        .sheet(isPresented: $showFactorsGuide) {
            FactorsGuideSheet()
        }
        .sheet(isPresented: $showProfile) {
            ProfileSheetView()
        }
    }

    // MARK: - Selection Section

    private var selectionSection: some View {
        VStack(spacing: 0) {
            // Fighter A
            cornerLabel(text: "Red corner", color: BSColors.accent, systemIcon: "hand.raised.fill")
            if let fighter = viewModel.fighterA {
                selectedCard(fighter: fighter, accentColor: BSColors.accent) {
                    viewModel.clearFighterA()
                }
            } else {
                emptyCard(onTap: {
                    showPickerA = true
                },color: BSColors.accent)
            }

            // VS + Swap
            HStack {
                Rectangle()
                    .fill(BSColors.surface)
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
                    .foregroundColor(BSColors.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(BSColors.accent)
                    .cornerRadius(6)
                }
                Rectangle()
                    .fill(BSColors.surface)
                    .frame(height: 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Fighter B
            cornerLabel(text: "Blue corner", color: BSColors.accentBlue, systemIcon: "hand.raised.fill")
            if let fighter = viewModel.fighterB {
                selectedCard(fighter: fighter, accentColor: BSColors.accentBlue) {
                    viewModel.clearFighterB()
                }
            } else {
                emptyCard(onTap: {
                    showPickerB = true
                }, color: BSColors.accentBlue)
            }
            
            if viewModel.fighterA != nil && viewModel.fighterB != nil {
                if viewModel.isLoadingProfiles {
                    HStack {
                        Spacer()
                        ProgressView().tint(BSColors.accent)
                        Spacer()
                    }
                    .padding(.top, 16)
                } else if let pA = viewModel.profileA, let pB = viewModel.profileB {
                    comparisonSection(profileA: pA, profileB: pB)
                }
            }

            // Predict button
            if viewModel.canPredict {
                Button {
                    viewModel.predict()
                } label: {
                    HStack(spacing: 6) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(BSColors.textPrimary)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))
                        }
                        Text("Predict fight")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(BSColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BSColors.accent)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            } else {
                Text("Select both fighters to predict")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.accent.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BSColors.accent.opacity(0.08))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(BSColors.accent.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
            }

            // Error
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.accent)
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Pre-prediction comparison

    @ViewBuilder
    private func comparisonSection(profileA: BSFighterProfile, profileB: BSFighterProfile) -> some View {
        VStack(spacing: 12) {
            // Header
            Text("Matchup breakdown")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(BSColors.textHint)
                .textCase(.uppercase)
                .kerning(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Names header
            HStack {
                Text(lastName(profileA.fullName))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(BSColors.accent)
                Spacer()
                Text(lastName(profileB.fullName))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(BSColors.accentBlue)
            }

            // Record comparison
            comparisonRow(
                label: "Record",
                valueA: "\(profileA.recordWin)-\(profileA.recordLoss)",
                valueB: "\(profileB.recordWin)-\(profileB.recordLoss)"
            )

            // Win rate
            if let wrA = profileA.winRate, let wrB = profileB.winRate {
                comparisonBar(label: "Win rate", valA: wrA, valB: wrB, suffix: "%", multiply: 100)
            }

            // Finish rate
            if let frA = profileA.finishRate, let frB = profileB.finishRate {
                comparisonBar(label: "Finish rate", valA: frA, valB: frB, suffix: "%", multiply: 100)
            }

            // Performance stats
            let perfA = profileA.performance
            let perfB = profileB.performance

            if let a = perfA.sigStrikesLandedPm, let b = perfB.sigStrikesLandedPm {
                comparisonBar(label: "Str. / min", valA: a, valB: b)
            }

            if let a = perfA.sigStrikeDefensePct, let b = perfB.sigStrikeDefensePct {
                comparisonBar(label: "Str. defense", valA: a, valB: b, suffix: "%", multiply: 100)
            }

            if let a = perfA.takedownAvg, let b = perfB.takedownAvg {
                comparisonBar(label: "TD avg", valA: a, valB: b)
            }

            if let a = perfA.submissionAvg, let b = perfB.submissionAvg {
                comparisonBar(label: "Sub avg", valA: a, valB: b)
            }

            // Fighting style data
            if let styleA = profileA.fightingStyleData, let styleB = profileB.fightingStyleData {

                Divider().background(BSColors.border)

                // Strike targets
                if let hA = styleA.strikeTarget.headPct, let hB = styleB.strikeTarget.headPct {
                    comparisonBar(label: "Head strikes", valA: hA, valB: hB, suffix: "%", multiply: 100)
                }

                if let dA = styleA.strikePosition.distancePct, let dB = styleB.strikePosition.distancePct {
                    comparisonBar(label: "At distance", valA: dA, valB: dB, suffix: "%", multiply: 100)
                }

                if let gA = styleA.strikePosition.groundPct, let gB = styleB.strikePosition.groundPct {
                    comparisonBar(label: "On ground", valA: gA, valB: gB, suffix: "%", multiply: 100)
                }

                // Grappling
                if let tdA = styleA.grappling.tdAccuracy, let tdB = styleB.grappling.tdAccuracy {
                    comparisonBar(label: "TD accuracy", valA: tdA, valB: tdB, suffix: "%", multiply: 100)
                }

                if let cA = styleA.grappling.avgCtrlTimeSecs, let cB = styleB.grappling.avgCtrlTimeSecs {
                    comparisonRow(
                        label: "Avg control",
                        valueA: formatCtrlTime(Int(cA)),
                        valueB: formatCtrlTime(Int(cB))
                    )
                }

                // Tempo
                if let rA = styleA.tempo.cardioIndex, let rB = styleB.tempo.cardioIndex {
                    comparisonRow(
                        label: "Cardio",
                        valueA: cardioLabel(rA),
                        valueB: cardioLabel(rB)
                    )
                }
            }

            // Physical
            let physA = profileA.physical
            let physB = profileB.physical

            if let hA = physA.heightInches, let hB = physB.heightInches {
                comparisonRow(
                    label: "Height",
                    valueA: formatHeight(hA),
                    valueB: formatHeight(hB)
                )
            }

            if let rA = physA.reachInches, let rB = physB.reachInches {
                comparisonBar(label: "Reach", valA: rA, valB: rB, suffix: "\"")
            }

            if let aA = physA.age, let aB = physB.age {
                comparisonRow(label: "Age", valueA: "\(aA)", valueB: "\(aB)")
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    private func formatHeight(_ inches: Double) -> String {
        let feet = Int(inches) / 12
        let remaining = Int(inches) % 12
        return "\(feet)'\(remaining)\""
    }

    // MARK: - Comparison components

    @ViewBuilder
    private func comparisonBar(label: String, valA: Double, valB: Double, suffix: String = "", multiply: Double = 1) -> some View {
        let displayA = valA * multiply
        let displayB = valB * multiply
        let maxVal = max(displayA, displayB, 0.01)

        HStack(spacing: 8) {
            Text(suffix == "\"" ? String(format: "%.0f%@", displayA, suffix) : String(format: "%.1f%@", displayA, suffix))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 46, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            GeometryReader { geo in
                let half = (geo.size.width - 60) / 2
                HStack(spacing: 0) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(BSColors.accent)
                            .frame(width: max(half * CGFloat(displayA / maxVal), 2), height: 4)
                    }
                    .frame(width: half)

                    Text(label)
                        .font(.system(size: 8))
                        .foregroundColor(BSColors.textTertiary)
                        .frame(width: 60)

                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(BSColors.accentBlue)
                            .frame(width: max(half * CGFloat(displayB / maxVal), 2), height: 4)
                        Spacer()
                    }
                    .frame(width: half)
                }
            }
            .frame(height: 14)

            Text(suffix == "\"" ? String(format: "%.0f%@", displayB, suffix) : String(format: "%.1f%@", displayB, suffix))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 46, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    @ViewBuilder
    private func comparisonRow(label: String, valueA: String, valueB: String) -> some View {
        HStack {
            Text(valueA)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 60, alignment: .trailing)
            Spacer()
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(BSColors.textTertiary)
            Spacer()
            Text(valueB)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 60, alignment: .leading)
        }
    }

    private func formatCtrlTime(_ secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return "\(m):\(String(format: "%02d", s))"
    }

    private func cardioLabel(_ index: Double) -> String {
        if index >= 0.8 { return "Elite" }
        if index >= 0.5 { return "Good" }
        if index >= 0.3 { return "Avg" }
        return "Low"
    }
    
    // MARK: - Result Section

    @ViewBuilder
    private func resultSection(_ prediction: Prediction) -> some View {
        VStack(spacing: 16) {
            // 1. Winner prediction
            winnerCard(prediction)

            // 2. Fight outcome (Decision vs Finish)
            if let outcome = prediction.outcome {
                outcomeCard(outcome)
            }

            // 3. Predicted method (DEC / KO / SUB)
            if let method = prediction.method {
                methodCard(method)
            }

            // 4. Duration forecast
            if let duration = prediction.duration {
                durationCard(duration)
            }

            // 5. Key factors
            factorsCard(prediction)

            // New prediction button
            Button {
                animateBar = false
                viewModel.reset()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12))
                    Text("New prediction")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(BSColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(BSColors.surface)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - 1. Winner Card
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func winnerCard(_ prediction: Prediction) -> some View {
        VStack(spacing: 14) {
            // Section title
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.accent)
                Text("Winner prediction")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
                // Confidence badge
                Text(prediction.confidence)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(confidenceColor(prediction.confidence))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(confidenceColor(prediction.confidence).opacity(0.12))
                    .cornerRadius(4)
            }

            // Fighters face-off
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    FighterAvatar(
                        imageUrl: viewModel.fighterA?.imgThumb,
                        initials: initials(prediction.fighterAName),
                        size: 52,
                        accentColor: BSColors.accent
                    )
                    Text(lastName(prediction.fighterAName))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    cornerDot("Red corner", color: BSColors.accent)
                }
                .frame(maxWidth: .infinity)

                ZStack {
                    Circle()
                        .fill(BSColors.surfaceSecondary)
                        .frame(width: 32, height: 32)
                    Text("VS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(BSColors.textTertiary)
                }

                VStack(spacing: 4) {
                    FighterAvatar(
                        imageUrl: viewModel.fighterB?.imgThumb,
                        initials: initials(prediction.fighterBName),
                        size: 52,
                        accentColor: BSColors.accentBlue
                    )
                    Text(lastName(prediction.fighterBName))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    cornerDot("Blue corner", color: BSColors.accentBlue)
                }
                .frame(maxWidth: .infinity)
            }

            // Probabilities
            HStack {
                Text("\(Int(prediction.fighterAWinProb * 100))%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BSColors.accent)
                Spacer()
                Text("\(Int(prediction.fighterBWinProb * 100))%")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BSColors.accentBlue)
            }

            // Animated bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(BSColors.accent)
                        .frame(width: animateBar ? geo.size.width * prediction.fighterAWinProb : 0)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(BSColors.accentBlue)
                }
            }
            .frame(height: 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    animateBar = true
                }
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }

    // ═══════════════════════════════════════════════
    // MARK: - 2. Outcome Card (Decision vs Finish)
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func outcomeCard(_ outcome: OutcomePrediction) -> some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textSecondary)
                Text("Fight outcome")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
            }

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(Int(outcome.decisionProb * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(BSColors.accentBlue)
                    Text("Decision")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(BSColors.border)
                    .frame(width: 1, height: 40)

                VStack(spacing: 4) {
                    Text("\(Int(outcome.finishProb * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(BSColors.accent)
                    Text("Finish")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }

            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(BSColors.accentBlue)
                        .frame(width: geo.size.width * outcome.decisionProb)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(BSColors.accent)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }

    // ═══════════════════════════════════════════════
    // MARK: - 3. Method Card (DEC / KO / SUB)
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func methodCard(_ method: MethodPrediction) -> some View {
        let segments: [(String, Double, Color)] = [
            ("DEC", method.decisionProb, BSColors.accentBlue),
            ("KO/TKO", method.koTkoProb, BSColors.accent),
            ("SUB", method.submissionProb, BSColors.winGreen),
        ]
        let maxProb = segments.map(\.1).max() ?? 0

        VStack(spacing: 14) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textSecondary)
                Text("Predicted method")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
            }

            HStack(spacing: 8) {
                methodProbCard(label: "Decision", prob: method.decisionProb, icon: "hand.raised.fill", color: BSColors.accentBlue, isTop: method.decisionProb == maxProb)
                methodProbCard(label: "KO/TKO", prob: method.koTkoProb, icon: "bolt.fill", color: BSColors.accent, isTop: method.koTkoProb == maxProb)
                methodProbCard(label: "Submission", prob: method.submissionProb, icon: "arrow.triangle.2.circlepath", color: BSColors.winGreen, isTop: method.submissionProb == maxProb)
            }

            SmartSegmentedBar(segments: segments)
            Spacer()
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func methodProbCard(label: String, prob: Double, icon: String, color: Color, isTop: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isTop ? color : BSColors.textHint)
            Text("\(Int(prob * 100))%")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isTop ? color : BSColors.textTertiary)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(BSColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isTop ? color.opacity(0.08) : BSColors.surfaceSecondary)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isTop ? color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    // ═══════════════════════════════════════════════
    // MARK: - 4. Duration Card
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func durationCard(_ duration: BSDurationPrediction) -> some View {
        let rounds: [(String, Double, Color)] = [
            ("R1", duration.r1FinishProb, BSColors.accent),
            ("R2", duration.r2FinishProb, BSColors.accent.opacity(0.75)),
            ("R3", duration.r3FinishProb, BSColors.accent.opacity(0.5)),
            ("R4/5", duration.lateFinishProb, BSColors.textTertiary),
            ("DEC", duration.decisionProb, BSColors.accentBlue),
        ]
        let maxProb = rounds.map(\.1).max() ?? 1

        VStack(spacing: 14) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textSecondary)
                Text("Duration forecast")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
            }

            VStack(spacing: 8) {
                ForEach(Array(rounds.enumerated()), id: \.offset) { _, round in
                    let (label, prob, color) = round
                    HStack(spacing: 8) {
                        Text(label)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(BSColors.textSecondary)
                            .frame(width: 30, alignment: .trailing)

                        GeometryReader { geo in
                            let width = geo.size.width * CGFloat(prob / max(maxProb, 0.01))
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(BSColors.surfaceSecondary)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(color)
                                    .frame(width: max(width, 2))
                            }
                        }
                        .frame(height: 12)

                        Text("\(Int(prob * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(prob == maxProb ? color : BSColors.textTertiary)
                            .frame(width: 32, alignment: .leading)
                    }
                }
            }

            SmartSegmentedBar(segments: rounds)
            Spacer()
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }

    // ═══════════════════════════════════════════════
    // MARK: - 5. Factors Card
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func factorsCard(_ prediction: Prediction) -> some View {

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textSecondary)
                Text("Key factors")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)
                Button {
                    showFactorsGuide = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(BSColors.textHint)
                }
                Spacer()
            }
            ForEach(prediction.topFactors) { factor in
                FactorRow(
                    factor: factor,
                    fighterAName: lastName(prediction.fighterAName),
                    fighterBName: lastName(prediction.fighterBName)
                )
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .padding(.horizontal, 16)
    }
    
    // ═══════════════════════════════════════════════
    // MARK: - Shared Small Components
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func cornerDot(_ text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text(text)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(color)
        }
    }

    private func confidenceColor(_ confidence: String) -> Color {
        switch confidence {
        case "HIGH":   return BSColors.winGreen
        case "MEDIUM": return BSColors.titleGold
        default:       return BSColors.textTertiary
        }
    }
    
    // MARK: - Components

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(BSColors.textHint)
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

    private func selectedCard(fighter: CachedFighter, accentColor: Color = BSColors.accent, onClear: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            FighterAvatar(
                imageUrl: fighter.imgThumb,
                initials: fighter.initials,
                size: 36,
                accentColor: accentColor
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(fighter.fullName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(BSColors.textPrimary)
                Text("\(fighter.recordWin)W · \(fighter.recordLoss)L · \(fighter.weightClass ?? "—")")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textTertiary)
            }
            Spacer()
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(accentColor)
            }
        }
        .padding(12)
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func emptyCard(onTap: @escaping () -> Void, color: Color = BSColors.surface) -> some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(BSColors.surface)
                        .frame(width: 36, height: 36)
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "333333"))
                }
                Text("Tap to select fighter")
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textHint)
                Spacer()
            }
            .padding(12)
            .background(BSColors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6]))
            )
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func warningBanner(_ warning: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(BSColors.accent)
            VStack(alignment: .leading, spacing: 1) {
                Text("Low confidence")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(BSColors.accent)
                Text(warning.replacingOccurrences(of: "_", with: " "))
                    .font(.system(size: 10))
                    .foregroundColor(BSColors.accent.opacity(0.7))
            }
            Spacer()
        }
        .padding(12)
        .background(BSColors.accent.opacity(0.08))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(BSColors.accent.opacity(0.2), lineWidth: 0.5)
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

struct FactorRow: View {
    let factor: PredictionFactor
    let fighterAName: String
    let fighterBName: String

    private var favorsRed: Bool { factor.impact > 0 }
    private var isNeutral: Bool { abs(factor.impact) < 0.01 }

    var body: some View {
        VStack(spacing: 4) {
            // Label + direction
            HStack {
                Text(displayName(for: factor.feature))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "BBBBBB"))
                Spacer()
                if isNeutral {
                    Text("Neutral")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(BSColors.textTertiary)
                } else {
                    Text("Favors \(favorsRed ? "red" : "blue")")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(favorsRed
                            ? BSColors.accent
                            : BSColors.accentBlue)
                }
            }

            // Bar
            GeometryReader { geo in
                let barWidth = min(abs(factor.impact) / 1.0, 1.0) * (geo.size.width / 2)
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BSColors.surfaceSecondary)
                        .frame(height: 4)

                    if !isNeutral {
                        HStack(spacing: 0) {
                            if favorsRed {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(BSColors.accent)
                                    .frame(width: max(barWidth, 4), height: 4)
                                Spacer()
                            } else {
                                Spacer()
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(BSColors.accentBlue)
                                    .frame(width: max(barWidth, 4), height: 4)
                            }
                        }
                    }
                }
            }
            .frame(height: 4)
        }
    }
    
    // MARK: - Feature name mapping

    private let featureDisplayNames: [String: String] = [
        // Elo
        "elo_a":                        "Elo rating (Red)",
        "elo_b":                        "Elo rating (Blue)",
        "elo_delta":                    "Elo advantage",
        // Rankings
        "rank_a":                       "Ranking (Red)",
        "rank_b":                       "Ranking (Blue)",
        "rank_delta":                   "Ranking advantage",
        "is_ranked_a":                  "Red is ranked",
        "is_ranked_b":                  "Blue is ranked",
        // Odds
        "odds_delta":                   "Market odds edge",
        "odds_missing":                 "No odds available",
        // Career
        "diff_total_fights":            "Experience gap",
        "diff_win_rate":                "Win rate advantage",
        "diff_finish_rate":             "Finish rate edge",
        "diff_ko_rate":                 "KO rate edge",
        "diff_sub_rate":                "Submission rate edge",
        "diff_finish_loss_rate":        "Vulnerability to finishes",
        "diff_avg_finish_round":        "Avg finish round gap",
        "diff_avg_kd":                  "Knockdown average gap",
        "diff_avg_sig_str":             "Sig. strikes per fight gap",
        // Form
        "diff_win_rate_l3":             "Recent form (last 3)",
        "diff_win_rate_l5":             "Recent form (last 5)",
        "diff_last_result":             "Last fight result",
        "diff_current_streak":          "Win streak advantage",
        "diff_days_since_last_fight":   "Activity gap",
        // Physical
        "diff_height_inches":           "Height advantage",
        "diff_reach_inches":            "Reach advantage",
        "diff_leg_reach_inches":        "Leg reach advantage",
        "diff_age":                     "Age difference",
        "diff_reach_relative":          "Relative reach edge",
        // Striking
        "diff_sig_strikes_landed_pm":   "Striking volume edge",
        "diff_sig_strikes_absorbed_pm": "Damage absorbed gap",
        "diff_sig_strike_defense_pct":  "Strike defense edge",
        "diff_knockdown_avg":           "KO power advantage",
        // Grappling
        "diff_submission_avg":          "Submission threat edge",
        "diff_takedown_defense_pct":    "Takedown defense edge",
        "diff_avg_td_accuracy":         "Takedown accuracy edge",
        "diff_avg_ctrl_time_secs":      "Control time advantage",
        // Tempo
        "diff_avg_head_pct":            "Head targeting edge",
        "diff_avg_distance_pct":        "Distance fighting edge",
        "diff_r1_kd_avg":               "Round 1 aggression",
        "diff_cardio_index":            "Cardio advantage",
        // Missing flags
        "physical_missing_a":           "Missing physical data (Red)",
        "physical_missing_b":           "Missing physical data (Blue)",
        "snapshot_missing_a":           "Missing career stats (Red)",
        "snapshot_missing_b":           "Missing career stats (Blue)",
        "rank_missing_a":               "Unranked (Red)",
        "rank_missing_b":               "Unranked (Blue)",
    ]

    private func displayName(for feature: String) -> String {
        featureDisplayNames[feature] ?? feature
            .replacingOccurrences(of: "diff_", with: "")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
