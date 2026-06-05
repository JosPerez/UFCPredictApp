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
    @State private var viewModel: EventDetailViewModel
    @Environment(AppCoordinator.self) private var coordinator
    
    init(eventId: Int) {
        self.eventId = eventId
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection(event)
                        statsSection(event)
                        Divider().background(BSColors.surface).padding(.vertical, 12)
                        fightsSection(event)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(BSColors.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - Header
    
    @ViewBuilder
    private func headerSection(_ event: BSEventDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(BSColors.textPrimary)
            Text(event.eventDate)
                .font(.system(size: 13))
                .foregroundColor(BSColors.textTertiary)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Stats
    
    @ViewBuilder
    private func statsSection(_ event: BSEventDetail) -> some View {
        HStack(spacing: 8) {
            StatCard(value: "\(event.fightCount)", label: "Fights", accent: false)
            StatCard(value: "\(event.finishes)", label: "Finishes", accent: true)
            StatCard(value: "\(event.titleFights)", label: "Title bouts", accent: event.titleFights > 0)
        }
    }
    
    // MARK: - Fights
    
    @ViewBuilder
    private func fightsSection(_ event: BSEventDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Fight card")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(BSColors.textHint)
                .textCase(.uppercase)
                .kerning(1)
            
            ForEach(event.fights.reversed()) { fight in
                EventFightCard(fight: fight, coordinator: coordinator)
            }
        }
    }
}

// MARK: - Fight Card

struct EventFightCard: View {
    let fight: BSEventFight
    let coordinator: AppCoordinator
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: tap to expand
            HStack(spacing: 8) {
                // Winner avatar
                ZStack {
                    Circle()
                        .fill(BSColors.accent.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Text(initials(fight.winnerName ?? fight.fighterRName))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(BSColors.accent)
                }
                
                // Names
                HStack(spacing: 4) {
                    Text(lastName(fight.isUpcoming ? fight.fighterRName : (fight.winnerName ?? fight.fighterRName)))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(fight.isUpcoming ? BSColors.textPrimary : BSColors.accent)
                    Text("vs")
                        .font(.system(size: 10))
                        .foregroundColor(BSColors.textHint)
                    Text(lastName(fight.isUpcoming ? fight.fighterBName : (fight.loserName ?? fight.fighterBName)))
                        .font(.system(size: 13, weight: fight.isUpcoming ? .bold : .regular))
                        .foregroundColor(fight.isUpcoming ? BSColors.textPrimary : Color(hex: "888888"))
                }
                
                Spacer()
                
                // Method badge
                if fight.isUpcoming {
                    if let wc = fight.weightClass {
                        Text(wc)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(BSColors.textTertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(BSColors.surfaceSecondary)
                            .cornerRadius(4)
                    }
                } else if let method = fight.method {
                    Text(methodAbbr(method, round: fight.round))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(
                            isFinish(method) ? BSColors.accent : Color(hex: "888888")
                        )
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            isFinish(method)
                                ? BSColors.accent.opacity(0.12)
                                : BSColors.surfaceSecondary
                        )
                        .cornerRadius(4)
                }
                
                if fight.isTitleFight {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundColor(BSColors.titleGold)
                }
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(BSColors.textHint)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }
            
            // Expanded content
            // Después de la sección expanded actual, reemplaza todo el bloque "if isExpanded"
            
            if isExpanded {
                Divider().background(BSColors.surfaceSecondary)
                
                if fight.isUpcoming {
                    // ── Upcoming: odds + predict ──
                    VStack(spacing: 10) {
                        // Weight class
                        if let wc = fight.weightClass {
                            HStack {
                                Text(wc)
                                    .font(.system(size: 11))
                                    .foregroundColor(BSColors.textSecondary)
                                Spacer()
                            }
                        }
                        
                        // Fighters side by side
                        HStack(spacing: 0) {
                            fighterColumn(
                                name: fight.fighterRName,
                                img: fight.fighterRImg,
                                isWinner: false,
                                kd: 0
                            )
                            Text("VS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(BSColors.textHint)
                                .frame(width: 30)
                            fighterColumn(
                                name: fight.fighterBName,
                                img: fight.fighterBImg,
                                isWinner: false,
                                kd: 0
                            )
                        }
                        
                        // Odds bar (si disponibles)
                        if let probR = fight.oddsFighterRProb,
                           let probB = fight.oddsFighterBProb {
                            VStack(spacing: 4) {
                                HStack {
                                    Text("\(Int(probR * 100))%")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(BSColors.accent)
                                    Spacer()
                                    Text("Market odds")
                                        .font(.system(size: 9))
                                        .foregroundColor(BSColors.textTertiary)
                                    Spacer()
                                    Text("\(Int(probB * 100))%")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(BSColors.accentBlue)
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
                                .frame(height: 6)
                            }
                        } else {
                            Text("No odds available")
                                .font(.system(size: 10))
                                .foregroundColor(BSColors.textTertiary)
                        }
                        
                        // ── Upcoming: career stats comparison ──
                        if fight.fighterRSlpm != nil || fight.fighterBSlpm != nil {
                            VStack(spacing: 6) {
                                Text("Career stats")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(BSColors.textHint)
                                    .textCase(.uppercase)
                                    .kerning(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if let a = fight.fighterRSlpm, let b = fight.fighterBSlpm {
                                    decimalComparisonRow(label: "Str. / min", valueA: a, valueB: b)
                                }
                                if let a = fight.fighterRStrDef, let b = fight.fighterBStrDef {
                                    decimalComparisonRow(label: "Str. defense",
                                        valueA: a * 100, valueB: b * 100, suffix: "%")
                                }
                                if let a = fight.fighterRSubAvg, let b = fight.fighterBSubAvg {
                                    decimalComparisonRow(label: "Sub. avg", valueA: a, valueB: b)
                                }
                            }
                            .padding(.top, 4)
                        }
                        
                        // Predict button
                        Button {
                            coordinator.predictRematch(
                                fighterAId: fight.fighterRId,
                                fighterBId: fight.fighterBId
                            )
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 10))
                                Text("Predict this fight")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(BSColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(BSColors.accent)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                } else {
                    // ── Completed: resultado actual (código existente) ──
                    VStack(spacing: 10) {
                        // Method + weight class
                        HStack {
                            if let method = fight.method {
                                Text(methodLabel(method, round: fight.round, time: fight.timeSecs))
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(
                                        isFinish(method) ? BSColors.accent : Color(hex: "888888")
                                    )
                            }
                            Spacer()
                            if let wc = fight.weightClass {
                                Text(wc)
                                    .font(.system(size: 10))
                                    .foregroundColor(BSColors.textTertiary)
                            }
                        }
                        
                        // Fighters side by side
                        HStack(spacing: 0) {
                            fighterColumn(
                                name: fight.fighterRName,
                                img: fight.fighterRImg,
                                isWinner: fight.fighterRWinner == true,
                                kd: fight.fighterRKd
                            )
                            Text("VS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(BSColors.textHint)
                                .frame(width: 30)
                            fighterColumn(
                                name: fight.fighterBName,
                                img: fight.fighterBImg,
                                isWinner: fight.fighterBWinner == true,
                                kd: fight.fighterBKd
                            )
                        }
                        // ── Completed: fight stats ──
                        VStack(spacing: 6) {
                            if fight.fighterRKd > 0 || fight.fighterBKd > 0 {
                                statComparisonRow(label: "Knockdowns",
                                    valueA: fight.fighterRKd, valueB: fight.fighterBKd)
                            }
                            if fight.fighterRSigStr > 0 || fight.fighterBSigStr > 0 {
                                statComparisonRow(label: "Sig. strikes",
                                    valueA: fight.fighterRSigStr, valueB: fight.fighterBSigStr)
                            }
                            if fight.fighterRTdLanded > 0 || fight.fighterBTdLanded > 0 {
                                statComparisonRow(label: "Takedowns",
                                    valueA: fight.fighterRTdLanded, valueB: fight.fighterBTdLanded)
                            }
                            if fight.fighterRSubAtt > 0 || fight.fighterBSubAtt > 0 {
                                statComparisonRow(label: "Sub. attempts",
                                    valueA: fight.fighterRSubAtt, valueB: fight.fighterBSubAtt)
                            }
                            if fight.fighterRCtrlSecs > 0 || fight.fighterBCtrlSecs > 0 {
                                ctrlTimeRow(
                                    label: "Control",
                                    secsA: fight.fighterRCtrlSecs,
                                    secsB: fight.fighterBCtrlSecs
                                )
                            }
                        }
                        .padding(.top, 4)
                        // Predict rematch button
                        Button {
                            coordinator.predictRematch(
                                fighterAId: fight.fighterRId,
                                fighterBId: fight.fighterBId
                            )
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 10))
                                Text("Predict rematch")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(BSColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(BSColors.accent)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(BSColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    fight.isTitleFight ? BSColors.titleGold.opacity(0.3) : Color.clear,
                    lineWidth: 0.5
                )
        )
    }

    // MARK: - Fighter column

    @ViewBuilder
    private func fighterColumn(name: String, img: String?, isWinner: Bool, kd: Int) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isWinner ? BSColors.accent.opacity(0.15) : BSColors.surfaceSecondary)
                    .frame(width: 36, height: 36)
                if let url = img, let imageUrl = URL(string: url) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Text(initials(name))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isWinner ? BSColors.accent : BSColors.textHint)
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                } else {
                    Text(initials(name))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isWinner ? BSColors.accent : BSColors.textHint)
                }
            }

            Text(lastName(name))
                .font(.system(size: 12, weight: isWinner ? .bold : .regular))
                .foregroundColor(isWinner ? BSColors.accent : Color(hex: "888888"))

            if isWinner {
                Text("Winner")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(BSColors.winGreen)
            }

            if kd > 0 {
                Text("\(kd) KD")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(BSColors.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(BSColors.accent.opacity(0.12))
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func ctrlTimeRow(label: String, secsA: Int, secsB: Int) -> some View {
        let maxVal = max(secsA, secsB, 1)

        HStack(spacing: 8) {
            Text(formatTime(secsA))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 40, alignment: .trailing)

            GeometryReader { geo in
                let half = (geo.size.width - 70) / 2
                HStack(spacing: 0) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(BSColors.accent)
                            .frame(width: max(half * CGFloat(secsA) / CGFloat(maxVal), 2), height: 4)
                    }
                    .frame(width: half)

                    Text(label)
                        .font(.system(size: 9))
                        .foregroundColor(BSColors.textTertiary)
                        .frame(width: 70)

                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(BSColors.accentBlue)
                            .frame(width: max(half * CGFloat(secsB) / CGFloat(maxVal), 2), height: 4)
                        Spacer()
                    }
                    .frame(width: half)
                }
            }
            .frame(height: 14)

            Text(formatTime(secsB))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 40, alignment: .leading)
        }
    }

    @ViewBuilder
    private func decimalComparisonRow(label: String, valueA: Double, valueB: Double, suffix: String = "") -> some View {
        let maxVal = max(valueA, valueB, 0.01)

        HStack(spacing: 8) {
            Text(String(format: "%.1f", valueA) + suffix)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 46, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            GeometryReader { geo in
                let half = (geo.size.width - 70) / 2
                HStack(spacing: 0) {
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(BSColors.accent)
                            .frame(width: max(half * CGFloat(valueA / maxVal), 2), height: 4)
                    }
                    .frame(width: half)

                    Text(label)
                        .font(.system(size: 9))
                        .foregroundColor(BSColors.textTertiary)
                        .frame(width: 70)

                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(BSColors.accentBlue)
                            .frame(width: max(half * CGFloat(valueB / maxVal), 2), height: 4)
                        Spacer()
                    }
                    .frame(width: half)
                }
            }
            .frame(height: 14)

            Text(String(format: "%.1f", valueB) + suffix)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 46, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
    
    @ViewBuilder
    private func statComparisonRow(label: String, valueA: Int, valueB: Int) -> some View {
        let maxVal = max(valueA, valueB, 1)

        HStack(spacing: 8) {
            // Value A
            Text("\(valueA)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accent)
                .frame(width: 28, alignment: .trailing)

            // Bar A
            GeometryReader { geo in
                let half = (geo.size.width - 60) / 2
                HStack(spacing: 0) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BSColors.accent)
                        .frame(width: max(half * CGFloat(valueA) / CGFloat(maxVal), 2), height: 4)
                }
                .frame(width: half)
            }
            .frame(height: 4)

            // Label
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(BSColors.textTertiary)
                .frame(width: 60)

            // Bar B
            GeometryReader { geo in
                let half = (geo.size.width - 60) / 2
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(BSColors.accentBlue)
                        .frame(width: max(half * CGFloat(valueB) / CGFloat(maxVal), 2), height: 4)
                    Spacer()
                }
                .frame(width: half)
            }
            .frame(height: 4)

            // Value B
            Text("\(valueB)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(BSColors.accentBlue)
                .frame(width: 28, alignment: .leading)
        }
    }

    // MARK: - Helpers
    
    private func formatTime(_ secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return "\(m):\(String(format: "%02d", s))"
    }

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

    private func methodAbbr(_ method: String, round: Int?) -> String {
        let r = round.map { "R\($0)" } ?? ""
        return "\(method) \(r)".trimmingCharacters(in: .whitespaces)
    }

    private func methodLabel(_ method: String, round: Int?, time: Int?) -> String {
        var label = method
        if let r = round { label += " · R\(r)" }
        if let t = time {
            let min = t / 60
            let sec = t % 60
            label += " · \(min):\(String(format: "%02d", sec))"
        }
        return label
    }

    private func isFinish(_ method: String) -> Bool {
        method == "KO/TKO" || method == "SUB"
    }
}
