//
//  EventDetailView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import SwiftUI
import BlackSpartan

@MainActor
struct EventDetailView: View {
    let eventId: Int
    var preselectedFightId: Int? = nil
    @State private var viewModel: EventDetailViewModel
    @State private var selectedFightIndex: Int = 0
    @Environment(AppCoordinator.self) private var coordinator

    init(eventId: Int, preselectedFightId: Int? = nil) {
        self.eventId = eventId
        self.preselectedFightId = preselectedFightId
        _viewModel = State(initialValue: EventDetailViewModel(eventId: eventId))
    }

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(BSColors.accent)
            } else if let error = viewModel.errorMessage {
                ErrorStateView(message: error) {
                    viewModel.retry(eventId: eventId)
                }
            } else if let event = viewModel.event {
                let fights = Array(event.fights.reversed())
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        eventHeader(event)
                        fightSelector(fights)
                        if !fights.isEmpty {
                            let fight = fights[selectedFightIndex]
                            if event.isUpcoming {
                                upcomingFightContent(fight, event: event)
                            } else {
                                completedFightContent(fight, event: event)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.clear, for: .navigationBar)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Event Header
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func eventHeader(_ event: BSEventDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(event.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)

                if event.isUpcoming {
                    if event.titleFights > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 8))
                            Text("Title fight")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(BSColors.accent)
                        .cornerRadius(4)
                    }
                } else {
                    Text("Completed")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(BSColors.winGreen)
                        .cornerRadius(4)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
                Text(event.location ?? "Location TBD")
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textSecondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textTertiary)
                Text(event.eventDate.formatEventDate())
                    .font(.system(size: 13))
                    .foregroundColor(BSColors.textTertiary)
            }

            // Countdown for upcoming
            if event.isUpcoming {
                countdownRow(event.eventDate)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private func countdownRow(_ dateStr: String) -> some View {
        let days = daysUntil(dateStr)
        if days > 0 {
            HStack(spacing: 8) {
                countdownBox(value: days, label: "Days")
                countdownBox(value: 0, label: "Hrs")
                countdownBox(value: 0, label: "Mins")
            }
            .padding(.top, 6)
        }
    }

    @ViewBuilder
    private func countdownBox(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(BSColors.textHint)
                .textCase(.uppercase)
        }
        .frame(width: 50)
        .padding(.vertical, 6)
        .background(BSColors.surface)
        .cornerRadius(8)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Fight Selector
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func fightSelector(_ fights: [BSEventFight]) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(fights.enumerated()), id: \.element.id) { index, fight in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFightIndex = index
                            }
                        } label: {
                            VStack(spacing: 3) {
                                HStack(spacing: 4) {
                                    Text(lastName(fight.fighterRName))
                                        .font(.system(size: 10, weight: selectedFightIndex == index ? .bold : .regular))
                                    Text("vs")
                                        .font(.system(size: 8))
                                        .foregroundColor(BSColors.textHint)
                                    Text(lastName(fight.fighterBName))
                                        .font(.system(size: 10, weight: selectedFightIndex == index ? .bold : .regular))
                                }
                                .foregroundColor(selectedFightIndex == index ? .white : BSColors.textTertiary)

                                if fight.isTitleFight {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 7))
                                        .foregroundColor(BSColors.titleGold)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedFightIndex == index ? BSColors.accent : BSColors.surface)
                            .cornerRadius(8)
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: selectedFightIndex) { _, newValue in
                withAnimation { proxy.scrollTo(newValue, anchor: .center) }
            }
        }
        .padding(.bottom, 16)
        .onAppear {
            if let fightId = preselectedFightId,
               let index = fights.firstIndex(where: { $0.fightId == fightId }) {
                selectedFightIndex = index
            }
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - COMPLETED FIGHT CONTENT
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func completedFightContent(_ fight: BSEventFight, event: BSEventDetail) -> some View {
        VStack(spacing: 12) {
            completedFightCard(fight)
            completedFightStats(fight)
            if fight.oddsFighterRProb != nil {
                marketConsensus(fight)
            }
            aiAnalysis(fight)
            predictButton(fight, label: "Predict rematch")
        }
    }

    @ViewBuilder
    private func completedFightCard(_ fight: BSEventFight) -> some View {
        VStack(spacing: 0) {
            // Weight class + title
            HStack(spacing: 4) {
                if fight.isTitleFight {
                    Text("Title fight")
                        .foregroundColor(BSColors.titleGold)
                }
                if let wc = fight.weightClass {
                    Text(fight.isTitleFight ? "· \(wc)" : wc)
                        .foregroundColor(BSColors.textTertiary)
                }
                Spacer()
            }
            .font(.system(size: 9, weight: .bold))
            .textCase(.uppercase)
            .padding(.bottom, 16)

            // Fighters
            HStack(spacing: 0) {
                // Red corner
                fighterColumn(
                    name: fight.fighterRName,
                    img: fight.fighterRImg,
                    record: fight.fighterRRecord,
                    isWinner: fight.fighterRWinner == true,
                    cornerColor: BSColors.accent,
                    cornerLabel: "Red corner",
                    rank: nil,
                    isUpcoming: false
                )

                // Method center
                VStack(spacing: 4) {
                    Text(fight.method ?? "—")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(methodColor(fight.method))
                    if let round = fight.round, let time = fight.timeSecs {
                        Text("Round \(round) · \(formatTime(time))")
                            .font(.system(size: 11))
                            .foregroundColor(BSColors.textTertiary)
                    }
                    if let detail = fight.methodDetail, !detail.isEmpty {
                        Text(detail)
                            .font(.system(size: 10))
                            .foregroundColor(BSColors.textHint)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                .frame(width: 100)

                // Blue corner
                fighterColumn(
                    name: fight.fighterBName,
                    img: fight.fighterBImg,
                    record: fight.fighterBRecord,
                    isWinner: fight.fighterBWinner == true,
                    cornerColor: BSColors.accentBlue,
                    cornerLabel: "Blue corner",
                    rank: nil,
                    isUpcoming: false
                )
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(fight.isTitleFight ? BSColors.titleGold.opacity(0.3) : Color.clear, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func completedFightStats(_ fight: BSEventFight) -> some View {
        let hasStats = fight.fighterRSigStr > 0 || fight.fighterBSigStr > 0
            || fight.fighterRKd > 0 || fight.fighterBKd > 0

        if hasStats {
            VStack(alignment: .leading, spacing: 14) {
                Text("Fight stats")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)

                if fight.fighterRSigStr > 0 || fight.fighterBSigStr > 0 {
                    comparisonBarInt(label: "Sig. strikes", valA: fight.fighterRSigStr, valB: fight.fighterBSigStr)
                }
                if fight.fighterRSigStrAttempted > 0 || fight.fighterBSigStrAttempted > 0 {
                    comparisonBarInt(label: "Str. attempted", valA: fight.fighterRSigStrAttempted, valB: fight.fighterBSigStrAttempted)
                }
                if fight.fighterRTdLanded > 0 || fight.fighterBTdLanded > 0 {
                    comparisonBarInt(label: "Takedowns", valA: fight.fighterRTdLanded, valB: fight.fighterBTdLanded)
                }
                if fight.fighterRCtrlSecs > 0 || fight.fighterBCtrlSecs > 0 {
                    comparisonBarTime(label: "Control time", secsA: fight.fighterRCtrlSecs, secsB: fight.fighterBCtrlSecs)
                }
                if fight.fighterRKd > 0 || fight.fighterBKd > 0 {
                    comparisonBarInt(label: "Knockdowns", valA: fight.fighterRKd, valB: fight.fighterBKd)
                }
                if fight.fighterRSubAtt > 0 || fight.fighterBSubAtt > 0 {
                    comparisonBarInt(label: "Sub attempts", valA: fight.fighterRSubAtt, valB: fight.fighterBSubAtt)
                }
            }
            .padding(16)
            .background(BSColors.surface)
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - UPCOMING FIGHT CONTENT
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func upcomingFightContent(_ fight: BSEventFight, event: BSEventDetail) -> some View {
        VStack(spacing: 12) {
            upcomingFightCard(fight)
            upcomingCareerStats(fight)
            strengthsWeaknesses(fight)
            if fight.oddsFighterRProb != nil {
                marketConsensus(fight)
            }
            predictButton(fight, label: "Predict this fight")
        }
    }

    @ViewBuilder
    private func upcomingFightCard(_ fight: BSEventFight) -> some View {
        VStack(spacing: 0) {
            // Weight class
            HStack(spacing: 4) {
                if fight.isTitleFight {
                    Text("Title fight")
                        .foregroundColor(BSColors.titleGold)
                }
                if let wc = fight.weightClass {
                    Text(fight.isTitleFight ? "· \(wc)" : wc)
                        .foregroundColor(BSColors.textTertiary)
                }
                Spacer()
            }
            .font(.system(size: 9, weight: .bold))
            .textCase(.uppercase)
            .padding(.bottom, 16)

            // Fighters
            HStack(spacing: 0) {
                fighterColumn(
                    name: fight.fighterRName,
                    img: fight.fighterRImg,
                    record: fight.fighterRRecord,
                    isWinner: false,
                    cornerColor: BSColors.accent,
                    cornerLabel: "Red corner",
                    rank: nil,
                    isUpcoming: true
                )

                VStack(spacing: 4) {
                    Text("VS")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(BSColors.textHint)
                    if let wc = fight.weightClass {
                        Text(wc)
                            .font(.system(size: 9))
                            .foregroundColor(BSColors.textTertiary)
                    }
                }
                .frame(width: 80)

                fighterColumn(
                    name: fight.fighterBName,
                    img: fight.fighterBImg,
                    record: fight.fighterBRecord,
                    isWinner: false,
                    cornerColor: BSColors.accentBlue,
                    cornerLabel: "Blue corner",
                    rank: nil,
                    isUpcoming: true
                )
            }
        }
        .padding(16)
        .background(BSColors.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(fight.isTitleFight ? BSColors.titleGold.opacity(0.3) : Color.clear, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func upcomingCareerStats(_ fight: BSEventFight) -> some View {
        let hasCareerStats = fight.fighterRSlpm != nil || fight.fighterBSlpm != nil

        if hasCareerStats {
            VStack(alignment: .leading, spacing: 14) {
                Text("Career comparison")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)

                HStack {
                    Text(lastName(fight.fighterRName))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BSColors.accent)
                    Spacer()
                    Text(lastName(fight.fighterBName))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(BSColors.accentBlue)
                }

                if let a = fight.fighterRSlpm, let b = fight.fighterBSlpm {
                    comparisonBar(label: "Str. / min", valA: a, valB: b)
                }
                if let a = fight.fighterRSapm, let b = fight.fighterBSapm {
                    comparisonBar(label: "Str. absorbed", valA: a, valB: b)
                }
                if let a = fight.fighterRStrDef, let b = fight.fighterBStrDef {
                    comparisonBar(label: "Str. defense", valA: a * 100, valB: b * 100, suffix: "%")
                }
                if let a = fight.fighterRKdAvg, let b = fight.fighterBKdAvg {
                    comparisonBar(label: "KD avg", valA: a, valB: b)
                }
                if let a = fight.fighterRSubAvg, let b = fight.fighterBSubAvg {
                    comparisonBar(label: "Sub avg", valA: a, valB: b)
                }
                if let a = fight.fighterRTdDef, let b = fight.fighterBTdDef {
                    comparisonBar(label: "TD defense", valA: a * 100, valB: b * 100, suffix: "%")
                }
            }
            .padding(16)
            .background(BSColors.surface)
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func strengthsWeaknesses(_ fight: BSEventFight) -> some View {
        let rStrengths = generateStrengths(fight, isRed: true)
        let bStrengths = generateStrengths(fight, isRed: false)
        let rWeaknesses = generateWeaknesses(fight, isRed: true)
        let bWeaknesses = generateWeaknesses(fight, isRed: false)

        if !rStrengths.isEmpty || !bStrengths.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Strengths
                HStack(alignment: .top, spacing: 16) {
                    // Red strengths
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Strengths")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(BSColors.accent)
                            .textCase(.uppercase)
                        ForEach(rStrengths, id: \.self) { s in
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(BSColors.winGreen)
                                Text(s)
                                    .font(.system(size: 11))
                                    .foregroundColor(BSColors.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Blue strengths
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Strengths")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(BSColors.accentBlue)
                            .textCase(.uppercase)
                        ForEach(bStrengths, id: \.self) { s in
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(BSColors.winGreen)
                                Text(s)
                                    .font(.system(size: 11))
                                    .foregroundColor(BSColors.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Weaknesses
                if !rWeaknesses.isEmpty || !bWeaknesses.isEmpty {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Weaknesses")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(BSColors.accent)
                                .textCase(.uppercase)
                            ForEach(rWeaknesses, id: \.self) { w in
                                HStack(spacing: 5) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(BSColors.accent)
                                    Text(w)
                                        .font(.system(size: 11))
                                        .foregroundColor(BSColors.textTertiary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Weaknesses")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(BSColors.accentBlue)
                                .textCase(.uppercase)
                            ForEach(bWeaknesses, id: \.self) { w in
                                HStack(spacing: 5) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(BSColors.accent)
                                    Text(w)
                                        .font(.system(size: 11))
                                        .foregroundColor(BSColors.textTertiary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .background(BSColors.surface)
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Market Consensus (shared)
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func marketConsensus(_ fight: BSEventFight) -> some View {
        if let probR = fight.oddsFighterRProb, let probB = fight.oddsFighterBProb {
            VStack(spacing: 12) {
                HStack {
                    Text("Market consensus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    Spacer()
                    if let sources = fight.oddsNumSources {
                        Text("Pre-fight odds · \(sources) sources")
                            .font(.system(size: 9))
                            .foregroundColor(BSColors.textHint)
                    }
                }

                HStack {
                    Text("\(Int(probR * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(BSColors.accent)
                    Spacer()
                    Text("\(Int(probB * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(BSColors.accentBlue)
                }

                HStack {
                    Text(lastName(fight.fighterRName))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(BSColors.accent)
                    Spacer()
                    Text(lastName(fight.fighterBName))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(BSColors.accentBlue)
                }

                HStack {
                    cornerDot("Red corner", color: BSColors.accent)
                    Spacer()
                    cornerDot("Blue corner", color: BSColors.accentBlue)
                }

                GeometryReader { geo in
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(BSColors.accent)
                            .frame(width: geo.size.width * probR)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(BSColors.accentBlue)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("\(Int(probR * 100))% Favorite")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(BSColors.accent)
                    Spacer()
                    Text("\(Int(probB * 100))% Underdog")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(BSColors.accentBlue)
                }
            }
            .padding(16)
            .background(BSColors.surface)
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - AI Analysis (completed only)
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func aiAnalysis(_ fight: BSEventFight) -> some View {
        let insights = generateInsights(fight)
        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                        .foregroundColor(BSColors.accent)
                    Text("AI Analysis")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(BSColors.accent)
                }

                ForEach(Array(insights.enumerated()), id: \.offset) { _, insight in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(BSColors.accent)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(insight)
                            .font(.system(size: 13))
                            .foregroundColor(BSColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(16)
            .background(BSColors.surface)
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Predict Button (shared)
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func predictButton(_ fight: BSEventFight, label: String) -> some View {
        Button {
            coordinator.predictRematch(
                fighterAId: fight.fighterRId,
                fighterBId: fight.fighterBId
            )
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(BSColors.accent)
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Shared Fighter Column
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func fighterColumn(name: String, img: String?, record: String?, isWinner: Bool, cornerColor: Color, cornerLabel: String, rank: Int?, isUpcoming: Bool) -> some View {
        VStack(spacing: 6) {
            FighterAvatar(
                imageUrl: img,
                initials: initials(name),
                size: 64,
                accentColor: cornerColor
            )
            
            // Name
            Text(name)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Record
            if let record = record {
                Text(record)
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.textTertiary)
            }
            
            if !isUpcoming {
                if isWinner {
                    Text("Winner")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(BSColors.winGreen)
                        .cornerRadius(4)
                } else {
                    Text("Loss")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                }
            }

            HStack(spacing: 4) {
                Circle()
                    .fill(cornerColor)
                    .frame(width: 5, height: 5)
                Text(cornerLabel)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(cornerColor)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Comparison Bars
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func comparisonBarInt(label: String, valA: Int, valB: Int) -> some View {
        let maxVal = max(valA, valB, 1)
        HStack(spacing: 6) {
            Text("\(valA)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 36, alignment: .trailing)
            barCenter(label: label, ratioA: CGFloat(valA) / CGFloat(maxVal), ratioB: CGFloat(valB) / CGFloat(maxVal))
            Text("\(valB)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 36, alignment: .leading)
        }
    }

    @ViewBuilder
    private func comparisonBar(label: String, valA: Double, valB: Double, suffix: String = "") -> some View {
        let maxVal = max(valA, valB, 0.01)
        HStack(spacing: 6) {
            Text(String(format: "%.1f", valA) + suffix)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 42, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            barCenter(label: label, ratioA: CGFloat(valA / maxVal), ratioB: CGFloat(valB / maxVal))
            Text(String(format: "%.1f", valB) + suffix)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 42, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    @ViewBuilder
    private func comparisonBarTime(label: String, secsA: Int, secsB: Int) -> some View {
        let maxVal = max(secsA, secsB, 1)
        HStack(spacing: 6) {
            Text(formatTime(secsA))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 36, alignment: .trailing)
            barCenter(label: label, ratioA: CGFloat(secsA) / CGFloat(maxVal), ratioB: CGFloat(secsB) / CGFloat(maxVal))
            Text(formatTime(secsB))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 36, alignment: .leading)
        }
    }

    @ViewBuilder
    private func barCenter(label: String, ratioA: CGFloat, ratioB: CGFloat) -> some View {
        GeometryReader { geo in
            let half = (geo.size.width - 70) / 2
            HStack(spacing: 0) {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BSColors.accent)
                        .frame(width: max(half * ratioA, 2), height: 5)
                }
                .frame(width: half)
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(BSColors.textTertiary)
                    .frame(width: 70)
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BSColors.accentBlue)
                        .frame(width: max(half * ratioB, 2), height: 5)
                    Spacer()
                }
                .frame(width: half)
            }
        }
        .frame(height: 16)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Small Components
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func cornerDot(_ text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 10))
                .foregroundColor(BSColors.textTertiary)
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - AI Generators
    // ═══════════════════════════════════════════════

    private func generateInsights(_ fight: BSEventFight) -> [String] {
        var insights: [String] = []
        let rName = lastName(fight.fighterRName)
        let bName = lastName(fight.fighterBName)
        let winnerName = fight.fighterRWinner == true ? rName : bName
        let loserName = fight.fighterRWinner == true ? bName : rName

        if let method = fight.method {
            switch method {
            case "KO/TKO":
                let winnerKd = fight.fighterRWinner == true ? fight.fighterRKd : fight.fighterBKd
                if winnerKd > 0 {
                    insights.append("\(winnerName) secured a \(method) victory with \(winnerKd) knockdown\(winnerKd > 1 ? "s" : ""), demonstrating superior striking power.")
                } else {
                    insights.append("\(winnerName) earned a \(method) finish, showcasing offensive pressure that overwhelmed \(loserName).")
                }
            case "SUB":
                let detail = fight.methodDetail ?? "submission"
                let winnerTd = fight.fighterRWinner == true ? fight.fighterRTdLanded : fight.fighterBTdLanded
                let winnerCtrl = fight.fighterRWinner == true ? fight.fighterRCtrlSecs : fight.fighterBCtrlSecs
                if winnerTd > 0 {
                    insights.append("\(winnerName)'s grappling proved decisive — \(winnerTd) successful takedown\(winnerTd > 1 ? "s" : "")\(winnerCtrl > 0 ? " and \(formatTime(winnerCtrl)) control time" : "") set up the \(detail.lowercased()) finish.")
                } else {
                    insights.append("\(winnerName) secured a \(detail.lowercased()) finish, demonstrating elite grappling skills.")
                }
            case "DEC":
                let detail = fight.methodDetail ?? "decision"
                insights.append("\(winnerName) earned a \(detail.lowercased()) victory, controlling the fight across all rounds.")
            default: break
            }
        }

        let sigDiff = abs(fight.fighterRSigStr - fight.fighterBSigStr)
        if sigDiff > 15 {
            let more = fight.fighterRSigStr > fight.fighterBSigStr ? rName : bName
            let less = fight.fighterRSigStr > fight.fighterBSigStr ? bName : rName
            let moreVal = max(fight.fighterRSigStr, fight.fighterBSigStr)
            let lessVal = min(fight.fighterRSigStr, fight.fighterBSigStr)
            insights.append("\(more) landed \(moreVal) significant strikes compared to \(less)'s \(lessVal), a clear striking advantage.")
        }

        let ctrlDiff = abs(fight.fighterRCtrlSecs - fight.fighterBCtrlSecs)
        if ctrlDiff > 60 {
            let more = fight.fighterRCtrlSecs > fight.fighterBCtrlSecs ? rName : bName
            insights.append("\(more) dominated grappling exchanges with \(formatTime(max(fight.fighterRCtrlSecs, fight.fighterBCtrlSecs))) of control time.")
        }

        if let probR = fight.oddsFighterRProb, let probB = fight.oddsFighterBProb {
            let wasUpset = (fight.fighterRWinner == true && probR < 0.4) || (fight.fighterBWinner == true && probB < 0.4)
            if wasUpset {
                let pct = fight.fighterRWinner == true ? Int(probR * 100) : Int(probB * 100)
                insights.append("\(winnerName) pulled off an upset as a \(pct)% underdog, defying market expectations.")
            }
        }

        return Array(insights.prefix(3))
    }

    private func generateStrengths(_ fight: BSEventFight, isRed: Bool) -> [String] {
        var strengths: [String] = []
        let slpm   = isRed ? fight.fighterRSlpm : fight.fighterBSlpm
        let strDef = isRed ? fight.fighterRStrDef : fight.fighterBStrDef
        let subAvg = isRed ? fight.fighterRSubAvg : fight.fighterBSubAvg
        let kdAvg  = isRed ? fight.fighterRKdAvg : fight.fighterBKdAvg
        let tdDef  = isRed ? fight.fighterRTdDef : fight.fighterBTdDef

        if let s = slpm, s > 4.0 { strengths.append("High striking output") }
        if let d = strDef, d > 0.55 { strengths.append("Strong strike defense") }
        if let sub = subAvg, sub > 1.0 { strengths.append("Submission threat") }
        if let kd = kdAvg, kd > 1.0 { strengths.append("KO power") }
        if let td = tdDef, td > 0.7 { strengths.append("Takedown defense") }
        if fight.isTitleFight { strengths.append("Championship experience") }

        return Array(strengths.prefix(3))
    }

    private func generateWeaknesses(_ fight: BSEventFight, isRed: Bool) -> [String] {
        var weaknesses: [String] = []
        let slpm   = isRed ? fight.fighterRSlpm : fight.fighterBSlpm
        let sapm   = isRed ? fight.fighterRSapm : fight.fighterBSapm
        let strDef = isRed ? fight.fighterRStrDef : fight.fighterBStrDef
        let tdDef  = isRed ? fight.fighterRTdDef : fight.fighterBTdDef

        if let s = slpm, s < 2.5 { weaknesses.append("Low strike volume") }
        if let d = strDef, d < 0.45 { weaknesses.append("Vulnerable to strikes") }
        if let a = sapm, a > 4.0 { weaknesses.append("Absorbs too many strikes") }
        if let td = tdDef, td < 0.5 { weaknesses.append("Weak takedown defense") }

        return Array(weaknesses.prefix(2))
    }

    // ═══════════════════════════════════════════════
    // MARK: - Helpers
    // ═══════════════════════════════════════════════

    private func lastName(_ name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.count > 1 ? String(parts.last ?? "") : name
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.last?.prefix(1) ?? ""
        return "\(f)\(l)"
    }

    private func formatTime(_ secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return "\(m):\(String(format: "%02d", s))"
    }

    private func daysUntil(_ dateStr: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        return max(days, 0)
    }

    private func methodColor(_ method: String?) -> Color {
        guard let m = method else { return BSColors.textTertiary }
        switch m {
        case "KO/TKO": return BSColors.accent
        case "SUB": return BSColors.accentBlue
        case "DEC": return BSColors.textSecondary
        default: return BSColors.textTertiary
        }
    }
}
