//
//  FighterDetailView.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import SwiftUI
import BlackSpartan

struct EventNavigation: Hashable {
    let eventId: Int
}

@MainActor
struct FighterDetailView: View {
    let fighterId: Int
    @State private var viewModel: FighterDetailViewModel
    @State private var selectedTab: Int = 0
    @Environment(AppCoordinator.self) private var coordinator

    init(fighterId: Int) {
        self.fighterId = fighterId
        _viewModel = State(initialValue: FighterDetailViewModel(fighterId: fighterId))
    }

    var body: some View {
        ZStack {
            BSColors.background.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(BSColors.accent)
            } else if let error = viewModel.errorMessage {
                ErrorStateView(message: error) {
                    viewModel.retry(fighterId: fighterId)
                }
            } else if let profile = viewModel.profile {
                VStack(spacing: 0) {
                    // Header — siempre visible
                    if selectedTab == 0 {
                        largeHeader(profile)
                    } else {
                        compactHeader(profile)
                    }

                    // Tab selector
                    tabSelector

                    // Tab content
                    TabView(selection: $selectedTab) {
                        overviewTab(profile).tag(0)
                        statsTab(profile).tag(1)
                        fightsTab(profile).tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: EventNavigation.self) { nav in
            EventDetailView(eventId: nav.eventId)
        }
    }

    // MARK: - Large Header (Overview)

    @ViewBuilder
    private func largeHeader(_ p: BSFighterProfile) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Avatar + Name
            HStack(spacing: 14) {
                FighterAvatar(
                    imageUrl: p.imgThumb,
                    initials: p.initials,
                    size: 64,
                    accentColor: p.currentRank == 0 ? BSColors.titleGold : BSColors.accent
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text(p.fullName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)

                    if let nick = p.nickname, !nick.isEmpty {
                        Text("\"\(nick)\"")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(BSColors.accent)
                            .italic()
                    }

                    // Badges
                    HStack(spacing: 6) {
                        if p.isActive {
                            badgePill("Active", dotColor: BSColors.winGreen, bg: BSColors.winGreen)
                        }
                        if let wc = p.weightClass {
                            badgePill(wc, bg: BSColors.surfaceSecondary, textColor: BSColors.textPrimary)
                        }
                        if let rank = p.currentRank {
                            badgePill(
                                rank == 0 ? "Champion" : "#\(rank)",
                                bg: rank == 0 ? BSColors.titleGold : BSColors.surfaceSecondary,
                                textColor: rank == 0 ? .black : BSColors.textPrimary
                            )
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Compact Header (Stats/Fights/Predict)

    @ViewBuilder
    private func compactHeader(_ p: BSFighterProfile) -> some View {
        HStack(spacing: 10) {
            FighterAvatar(
                imageUrl: p.imgThumb,
                initials: p.initials,
                size: 36,
                accentColor: p.currentRank == 0 ? BSColors.titleGold : BSColors.accent
            )
            Text(p.fullName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(BSColors.textPrimary)

            if let nick = p.nickname, !nick.isEmpty {
                Text("\"\(nick)\"")
                    .font(.system(size: 11))
                    .foregroundColor(BSColors.accent)
                    .italic()
            }
            Spacer()

            if p.isActive {
                badgePill("Active", dotColor: BSColors.winGreen, bg: BSColors.winGreen)
            }
            if let rank = p.currentRank {
                badgePill(
                    rank == 0 ? "C" : "#\(rank)",
                    bg: rank == 0 ? BSColors.titleGold : BSColors.surfaceSecondary,
                    textColor: rank == 0 ? .black : BSColors.textPrimary
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(Array(["Overview", "Stats", "Fights"].enumerated()), id: \.offset) { index, title in
                Button {
                    withAnimation { selectedTab = index }
                } label: {
                    VStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 13, weight: selectedTab == index ? .bold : .regular))
                            .foregroundColor(selectedTab == index ? BSColors.accent : BSColors.textTertiary)
                        Rectangle()
                            .fill(selectedTab == index ? BSColors.accent : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .background(BSColors.background)
    }

    // ═══════════════════════════════════════════════
    // MARK: - TAB 1: Overview
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func overviewTab(_ p: BSFighterProfile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Info grid
                infoGrid(p)

                // Win methods
                winMethodsCard(p)

                // Fight style
                if let style = p.fightingStyleData {
                    performanceSection(p)
                }

                // Predict button
                Button {
                    coordinator.predictWithFighter(id: p.id)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Predict fight")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(BSColors.accent)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Performance Section (Overview)

    @ViewBuilder
    private func performanceSection(_ p: BSFighterProfile) -> some View {
        let radarItems = buildRadarItems(p)
        let stats = buildPerformanceStats(p)

        if !radarItems.isEmpty {
            PerformanceCard(
                title: "Performance",
                radarItems: radarItems,
                stats: stats
            )
        }
    }

    private func buildRadarItems(_ p: BSFighterProfile) -> [RadarItem] {
        var items: [RadarItem] = []

        // Striking (SLpM normalized: 8.0 = max UFC)
        if let slpm = p.performance.sigStrikesLandedPm {
            items.append(RadarItem(label: "Striking", value: min(slpm / 8.0, 1.0)))
        }

        // Grappling (TD defense + sub avg)
        if let tdDef = p.performance.takedownDefensePct {
            items.append(RadarItem(label: "Grappling", value: tdDef))
        }

        // Defense (strike defense)
        if let strDef = p.performance.sigStrikeDefensePct {
            items.append(RadarItem(label: "Defense", value: strDef))
        }

        // Power (KD avg normalized: 2.0 = max)
        if let kdAvg = p.performance.knockdownAvg {
            items.append(RadarItem(label: "Power", value: min(kdAvg / 2.0, 1.0)))
        }

        // Win rate
        if let wr = p.winRate {
            items.append(RadarItem(label: "Win Rate", value: wr))
        }

        // Cardio (from fighting style data)
        if let style = p.fightingStyleData, let ci = style.tempo.cardioIndex {
            items.append(RadarItem(label: "Cardio", value: min(ci / 1.0, 1.0)))
        } else {
            // Fallback: finish rate inverted (fighters that go to decision have better cardio)
            if let fr = p.finishRate {
                items.append(RadarItem(label: "Cardio", value: 1.0 - fr))
            }
        }

        return items
    }

    private func buildPerformanceStats(_ p: BSFighterProfile) -> [PerformanceStat] {
        var stats: [PerformanceStat] = []

        if let slpm = p.performance.sigStrikesLandedPm {
            stats.append(PerformanceStat(title: "Str/Min", value: String(format: "%.1f", slpm), style: .valueFirst))
        }
        if let strDef = p.performance.sigStrikeDefensePct {
            stats.append(PerformanceStat(title: "Str. Def", value: "\(Int(strDef * 100))%", style: .valueFirst))
        }
        if let tdDef = p.performance.takedownDefensePct {
            stats.append(PerformanceStat(title: "TD Def", value: "\(Int(tdDef * 100))%", style: .valueFirst))
        }
        if let kdAvg = p.performance.knockdownAvg {
            stats.append(PerformanceStat(title: "KD Avg", value: String(format: "%.2f", kdAvg), style: .valueFirst))
        }
        if let subAvg = p.performance.submissionAvg {
            stats.append(PerformanceStat(title: "Sub Avg", value: String(format: "%.1f", subAvg), style: .valueFirst))
        }

        // From fighting style data
        if let style = p.fightingStyleData {
            if let td = style.grappling.tdAccuracy {
                stats.append(PerformanceStat(title: "TD Acc", value: "\(Int(td * 100))%", style: .valueFirst))
            }
            if let ctrl = style.grappling.avgCtrlTimeSecs {
                stats.append(PerformanceStat(title: "Avg Ctrl", value: formatCtrlTime(Int(ctrl)), style: .valueFirst))
            }
            if let r1 = style.tempo.r1KdAvg, r1 > 0 {
                stats.append(PerformanceStat(title: "R1 KD", value: String(format: "%.1f", r1), style: .valueFirst))
            }
            if let ci = style.tempo.cardioIndex {
                stats.append(PerformanceStat(title: "Cardio", value: cardioLabel(ci), style: .titleFirst))
            }
        }

        return stats
    }

    @ViewBuilder
    private func infoGrid(_ p: BSFighterProfile) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                infoCell(label: "Record", value: "\(p.recordWin)-\(p.recordLoss)-\(p.recordDraw)",
                         detail: "W\(p.recordWin) L\(p.recordLoss) D\(p.recordDraw)", useRecord: true)
                Divider().background(BSColors.border)
                infoCell(label: "City", value: p.hometown ?? "—")
            }
            Divider().background(BSColors.border)
            HStack(spacing: 0) {
                infoCell(label: "Gym", value: p.trainsAt ?? "—")
                Divider().background(BSColors.border)
                infoCell(label: "Debut", value: formatDebut(p.octagonDebut))
            }
            Divider().background(BSColors.border)
            HStack(spacing: 0) {
                infoCell(label: "Win rate", value: p.winRate.map { "\(Int($0 * 100))%" } ?? "—",
                         valueColor: BSColors.winGreen)
                Divider().background(BSColors.border)
                infoCell(label: "Finish rate", value: p.finishRate.map { "\(Int($0 * 100))%" } ?? "—",
                         valueColor: BSColors.accent)
            }
            Divider().background(BSColors.border)
            HStack(spacing: 0) {
                infoCell(label: "Current streak",
                         value: p.currentStreak > 0 ? "W\(p.currentStreak) 🔥" : p.currentStreak < 0 ? "L\(abs(p.currentStreak))" : "—",
                         valueColor: p.currentStreak > 0 ? BSColors.winGreen : BSColors.accent)
                Divider().background(BSColors.border)
                infoCell(label: "Elo rating",
                         value: p.currentElo.map { "⚡ \(Int($0))" } ?? "—",
                         valueColor: BSColors.titleGold)
            }
        }
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func infoCell(label: String, value: String, detail: String? = nil, valueColor: Color = BSColors.textPrimary, useRecord: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(BSColors.textTertiary)
                .kerning(0.5)

            if useRecord {
                HStack(spacing: 0) {
                    Text("\(viewModel.profile?.recordWin ?? 0)")
                        .foregroundColor(BSColors.winGreen)
                    Text("-").foregroundColor(BSColors.textHint)
                    Text("\(viewModel.profile?.recordLoss ?? 0)")
                        .foregroundColor(BSColors.accent)
                    Text("-").foregroundColor(BSColors.textHint)
                    Text("\(viewModel.profile?.recordDraw ?? 0)")
                        .foregroundColor(BSColors.textTertiary)
                }
                .font(.system(size: 16, weight: .bold))
            } else {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }

    @ViewBuilder
    private func winMethodsCard(_ p: BSFighterProfile) -> some View {
        let m = p.winMethods
        VStack(alignment: .leading, spacing: 10) {
            Text("Win methods")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(BSColors.textPrimary)

            methodBar(label: "KO / TKO", count: m.koTko, pct: m.koPct, color: BSColors.accent)
            methodBar(label: "Submission", count: m.submission, pct: m.subPct, color: BSColors.accentBlue)
            methodBar(label: "Decision", count: m.decision, pct: m.decPct, color: BSColors.textTertiary)
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func methodBar(label: String, count: Int, pct: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(BSColors.textPrimary)
                Spacer()
                Text("\(Int(pct * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(BSColors.surfaceSecondary)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: max(geo.size.width * pct, 4))
                }
            }
            .frame(height: 6)
        }
    }

    @ViewBuilder
    private func fightStyleCard(_ p: BSFighterProfile, style: BSFightingStyleData) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Fight style")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(BSColors.textPrimary)

            // Strike target bars
            let t = style.strikeTarget
            if t.headPct != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strike targets")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                    HStack(spacing: 3) {
                        SmartSegmentedBar(segments:[
                            ("Head", t.headPct ?? 0, BSColors.accent),
                            ("Body", t.bodyPct ?? 0, BSColors.accentBlue),
                            ("Legs", t.legPct ?? 0, BSColors.winGreen),
                        ])
                    }
                    .frame(height: 24)
                }
            }

            // Strike position bars
            let pos = style.strikePosition
            if pos.distancePct != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strike position")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                    HStack(spacing: 3) {
                        SmartSegmentedBar(segments: [
                            ("Distance", pos.distancePct ?? 0, BSColors.accent),
                            ("Clinch", pos.clinchPct ?? 0, BSColors.accentBlue),
                            ("Ground", pos.groundPct ?? 0, BSColors.titleGold),
                        ])
                    }
                    .frame(height: 24)
                }
            }

            // Mini stat cards row
            HStack(spacing: 6) {
                if let td = style.grappling.tdAccuracy {
                    miniStat(value: "\(Int(td * 100))%", label: "TD accuracy")
                }
                if let ctrl = style.grappling.avgCtrlTimeSecs {
                    miniStat(value: formatCtrlTime(Int(ctrl)), label: "Avg control")
                }
                if let r1 = style.tempo.r1KdAvg, r1 > 0 {
                    miniStat(value: String(format: "%.1f", r1), label: "R1 KD avg")
                }
                if let ci = style.tempo.cardioIndex {
                    miniStat(value: cardioLabel(ci), label: "Cardio")
                }
            }

            // Divider
            Divider().background(BSColors.border)

            // Style pills — derived from data
            FlowLayout(spacing: 8) {
                if let fs = p.fightingStyle, !fs.isEmpty {
                    stylePill(fs, primary: true)
                }
                if let dp = style.strikePosition.distancePct, dp > 0.6 {
                    stylePill("Distance fighter")
                } else if let gp = style.strikePosition.groundPct, gp > 0.3 {
                    stylePill("Ground game")
                }
                if let td = style.grappling.tdAccuracy, td > 0.5 {
                    stylePill("Wrestler")
                }
                if let hp = style.strikeTarget.headPct, hp > 0.5 {
                    stylePill("Head hunter")
                }
                if let lp = style.strikeTarget.legPct, lp > 0.3 {
                    stylePill("Leg kicks")
                }
                if let r1 = style.tempo.r1KdAvg, r1 > 0.3 {
                    stylePill("Fast starter")
                }
                if let ci = style.tempo.cardioIndex, ci > 0.7 {
                    stylePill("Cardio machine")
                }
                if let sub = p.performance.submissionAvg, sub > 1.0 {
                    stylePill("Submission threat")
                }
            }
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    // ═══════════════════════════════════════════════
    // MARK: - TAB 2: Stats
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func statsTab(_ p: BSFighterProfile) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                // Performance
                CollapsibleSection(title: "Performance stats") {
                    VStack(spacing: 0) {
                        if let v = p.performance.sigStrikesLandedPm {
                            statRow(label: "Sig. strikes / min", value: String(format: "%.2f", v))
                        }
                        if let v = p.performance.sigStrikeDefensePct {
                            statRowBar(label: "Strike defense", value: v, suffix: "%")
                        }
                        if let v = p.performance.takedownDefensePct {
                            statRowBar(label: "Takedown defense", value: v, suffix: "%")
                        }
                        if let v = p.performance.knockdownAvg {
                            statRow(label: "Knockdown avg", value: String(format: "%.1f", v))
                        }
                        if let v = p.performance.submissionAvg {
                            statRow(label: "Submission avg", value: String(format: "%.1f", v))
                        }
                        if let v = p.performance.takedownAvg {
                            statRow(label: "Takedown avg", value: String(format: "%.1f", v))
                        }
                    }
                }

                // Physical
                CollapsibleSection(title: "Physical stats") {
                    VStack(spacing: 0) {
                        if let h = p.physical.heightInches {
                            statRow(label: "Height", value: formatHeight(h))
                        }
                        if let r = p.physical.reachInches {
                            statRow(label: "Reach", value: "\(Int(r)) in")
                        }
                        if let lr = p.physical.legReachInches {
                            statRow(label: "Leg reach", value: "\(Int(lr)) in")
                        }
                        if let w = p.physical.weightLbs {
                            statRow(label: "Weight", value: "\(Int(w)) lbs")
                        }
                        if let a = p.physical.age {
                            statRow(label: "Age", value: "\(a)")
                        }
                    }
                }

                // Finish rounds
                CollapsibleSection(title: "Finish rounds") {
                    finishRoundsChart(p.winRounds)
                }

                // Strike DNA
                if let style = p.fightingStyleData {
                    CollapsibleSection(title: "Strike breakdown") {
                        strikeDNAContent(style)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private func strikeDNAContent(_ style: BSFightingStyleData) -> some View {
        VStack(spacing: 10) {
            // Target
            let t = style.strikeTarget
            if t.headPct != nil {
                Text("Target")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(BSColors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 3) {
                    SmartSegmentedBar(segments: [
                        ("Head", t.headPct ?? 0, BSColors.accent),
                        ("Body", t.bodyPct ?? 0, BSColors.accentBlue),
                        ("Legs", t.legPct ?? 0, BSColors.winGreen),
                    ])
                }
                .frame(height: 22)
            }

            // Position
            let pos = style.strikePosition
            if pos.distancePct != nil {
                Text("Position")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(BSColors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 3) {
                    SmartSegmentedBar(segments: [
                        ("Distance", pos.distancePct ?? 0, BSColors.accent),
                        ("Clinch", pos.clinchPct ?? 0, BSColors.accentBlue),
                        ("Ground", pos.groundPct ?? 0, BSColors.titleGold),
                    ])
                }
                .frame(height: 22)
            }

            // Grappling stats
            HStack(spacing: 8) {
                if let td = style.grappling.tdAccuracy {
                    miniStat(value: "\(Int(td * 100))%", label: "TD acc.")
                }
                if let ctrl = style.grappling.avgCtrlTimeSecs {
                    miniStat(value: formatCtrlTime(Int(ctrl)), label: "Avg ctrl")
                }
                if let r1 = style.tempo.r1KdAvg {
                    miniStat(value: String(format: "%.1f", r1), label: "R1 KD")
                }
                if let ci = style.tempo.cardioIndex {
                    miniStat(value: cardioLabel(ci), label: "Cardio")
                }
            }
            
            // Style pills
            Divider().background(BSColors.border)
            styleTagsSection(style)
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - TAB 3: Fights
    // ═══════════════════════════════════════════════
    
    @ViewBuilder
    private func styleTagsSection(_ style: BSFightingStyleData) -> some View {
        let tags = deriveStyleTags(style)
        if !tags.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Fighting style")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(BSColors.textTertiary)

                FlowLayout(spacing: 8) {
                    // Official style first
                    if let profile = viewModel.profile, let fs = profile.fightingStyle, !fs.isEmpty {
                        stylePill(fs, primary: true)
                    }
                    ForEach(tags, id: \.self) { tag in
                        stylePill(tag)
                    }
                }
            }
        }
    }

    private func deriveStyleTags(_ style: BSFightingStyleData) -> [String] {
        var tags: [String] = []

        if let dp = style.strikePosition.distancePct, dp > 0.6 {
            tags.append("Distance fighter")
        }
        if let gp = style.strikePosition.groundPct, gp > 0.3 {
            tags.append("Ground game")
        }
        if let td = style.grappling.tdAccuracy, td > 0.5 {
            tags.append("Wrestler")
        }
        if let hp = style.strikeTarget.headPct, hp > 0.55 {
            tags.append("Head hunter")
        }
        if let lp = style.strikeTarget.legPct, lp > 0.3 {
            tags.append("Leg kicks")
        }
        if let r1 = style.tempo.r1KdAvg, r1 > 0.3 {
            tags.append("Fast starter")
        }
        if let ci = style.tempo.cardioIndex, ci > 0.7 {
            tags.append("Cardio machine")
        }
        if let sub = viewModel.profile?.performance.submissionAvg, sub > 1.0 {
            tags.append("Submission threat")
        }

        return tags
    }

    @ViewBuilder
    private func fightsTab(_ p: BSFighterProfile) -> some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(p.recentFights) { fight in
                    NavigationLink(value: EventNavigation(eventId: fight.eventId)) {
                        fightHistoryCard(fight)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private func fightHistoryCard(_ fight: BSRecentFight) -> some View {
        let isWin = fight.result == "WIN"
        let borderColor = isWin ? BSColors.winGreen : fight.result == "LOSS" ? BSColors.accent : BSColors.textTertiary

        HStack(alignment: .top, spacing: 10) {
            // Fight info
            VStack(alignment: .leading, spacing: 6) {
                Text(fight.opponentName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(BSColors.textPrimary)

                Text(methodDisplay(fight))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isWin ? BSColors.winGreen : BSColors.accent)

                HStack(spacing: 4) {
                    Text(fight.eventName)
                        .font(.system(size: 11))
                        .foregroundColor(BSColors.accentBlue)
                    Text("·")
                        .foregroundColor(BSColors.textHint)
                    Text(fight.eventDate)
                        .font(.system(size: 11))
                        .foregroundColor(BSColors.textTertiary)
                }

                if fight.knockdowns > 0 || fight.significantStrikes > 0 || fight.takedownsLanded > 0 {
                    HStack(spacing: 8) {
                        if fight.knockdowns > 0 {
                            fightStat(label: "KD", value: "\(fight.knockdowns)")
                        }
                        if fight.significantStrikes > 0 {
                            fightStat(label: "SS", value: "\(fight.significantStrikes)/\(fight.sigStrAttempted)")
                        }
                        if fight.takedownsLanded > 0 || fight.takedownsAttempted > 0 {
                            fightStat(label: "TD", value: "\(fight.takedownsLanded)/\(fight.takedownsAttempted)")
                        }
                        if fight.ctrlTimeSecs > 0 {
                            fightStat(label: "Ctrl", value: formatCtrlTime(fight.ctrlTimeSecs))
                        }
                    }
                    .padding(.top, 2)
                }

                if let round = fight.round, let time = fight.timeSecs {
                    Text("R\(round) · \(formatTime(time))")
                        .font(.system(size: 10))
                        .foregroundColor(BSColors.textHint)
                }
            }

            Spacer()

            // Opponent photo
            FighterAvatar(
                imageUrl: fight.opponentImg,
                initials: opponentInitials(fight.opponentName),
                size: 44,
                accentColor: BSColors.textTertiary
            )
            
            VStack {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(BSColors.textHint)
                    .frame(alignment: .center)
                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BSColors.surface)
        .cornerRadius(10)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(borderColor)
                .frame(width: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func opponentInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.last?.prefix(1) ?? ""
        return "\(f)\(l)"
    }
    // ═══════════════════════════════════════════════
    // MARK: - TAB 4: Predict
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func predictTab(_ p: BSFighterProfile) -> some View {
        VStack(spacing: 20) {
            Spacer()
            FighterAvatar(
                imageUrl: p.imgThumb,
                initials: p.initials,
                size: 80,
                accentColor: BSColors.accent
            )
            Text(p.fullName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
            Text("\(p.recordWin)-\(p.recordLoss)-\(p.recordDraw)")
                .font(.system(size: 16))
                .foregroundColor(BSColors.textTertiary)

            Button {
                coordinator.predictWithFighter(id: p.id)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                    Text("Predict fight")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BSColors.accent)
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    // ═══════════════════════════════════════════════
    // MARK: - Reusable Components
    // ═══════════════════════════════════════════════

    @ViewBuilder
    private func badgePill(_ text: String, dotColor: Color? = nil, bg: Color = BSColors.surfaceSecondary, textColor: Color = .white) -> some View {
        HStack(spacing: 4) {
            if let dot = dotColor {
                Circle()
                    .fill(dot)
                    .frame(width: 5, height: 5)
            }
            Text(text)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(bg.opacity(dotColor != nil ? 0.15 : 1))
        .cornerRadius(4)
    }

    @ViewBuilder
    private func stylePill(_ text: String, primary: Bool = false) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(primary ? .white : BSColors.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(primary ? BSColors.accent : BSColors.accent.opacity(0.12))
            .cornerRadius(6)
    }

    @ViewBuilder
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(BSColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .overlay(alignment: .bottom) {
            Divider().background(BSColors.border)
        }
    }

    @ViewBuilder
    private func statRowBar(label: String, value: Double, suffix: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(BSColors.textSecondary)
            Spacer()
            RoundedRectangle(cornerRadius: 3)
                .fill(BSColors.accent)
                .frame(width: 60 * CGFloat(value), height: 5)
            Text("\(Int(value * 100))\(suffix)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .overlay(alignment: .bottom) {
            Divider().background(BSColors.border)
        }
    }

    @ViewBuilder
    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(BSColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(BSColors.surfaceSecondary)
        .cornerRadius(6)
    }

    @ViewBuilder
    private func finishRoundsChart(_ r: BSWinRoundBreakdown) -> some View {
        let values = [r.r1, r.r2, r.r3, r.r4, r.r5]
        let maxVal = Double(max(values.max() ?? 1, 1))

        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                VStack(spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(value > 0 ? BSColors.accent : BSColors.textHint)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(value > 0 ? BSColors.accent : BSColors.surfaceSecondary)
                        .frame(height: max(CGFloat(Double(value) / maxVal) * 60, 4))
                    Text("R\(index + 1)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(BSColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 100)
    }

    @ViewBuilder
    private func fightStat(label: String, value: String) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(BSColors.textHint)
            Text(value)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(BSColors.textSecondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(BSColors.surfaceSecondary)
        .cornerRadius(4)
    }

    // ═══════════════════════════════════════════════
    // MARK: - Helpers
    // ═══════════════════════════════════════════════

    private func formatHeight(_ inches: Double) -> String {
        let feet = Int(inches) / 12
        let rem = Int(inches) % 12
        return "\(feet) ft \(rem) in"
    }

    private func formatDebut(_ dateStr: String?) -> String {
        guard let d = dateStr else { return "—" }
        return d
    }

    private func formatCtrlTime(_ secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return "\(m):\(String(format: "%02d", s))"
    }

    private func formatTime(_ secs: Int) -> String {
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

    private func methodDisplay(_ fight: BSRecentFight) -> String {
        var text = fight.method ?? ""
        if let detail = fight.methodDetail, !detail.isEmpty {
            text += " (\(detail))"
        }
        return text
    }
}

// ═══════════════════════════════════════════════
// MARK: - Collapsible Section
// ═══════════════════════════════════════════════

struct CollapsibleSection<Content: View>: View {
    let title: String
    @State private var isExpanded: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(BSColors.textPrimary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textHint)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    content()
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .background(BSColors.surface)
        .cornerRadius(12)
    }
}

// ═══════════════════════════════════════════════
// MARK: - Flow Layout (for style pills)
// ═══════════════════════════════════════════════

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
