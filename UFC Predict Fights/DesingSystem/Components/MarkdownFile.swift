//
//  MarkdownFile.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 11/06/26.
//
import SwiftUI

//
//  FactorsGuideSheet.swift
//  UFC Predict Fights
//

import SwiftUI

struct FactorsGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Intro
                    Text("Each factor shows a name and an impact value. Positive impact favors the Red corner, negative favors the Blue corner.")
                        .font(.system(size: 13))
                        .foregroundColor(BSColors.textSecondary)

                    // Sections
                    guideSection("Elo & Rankings", items: [
                        ("Elo rating", "Skill rating from fight history. Wins vs strong opponents raise it more. Range: ~1400 (low) to ~1800 (elite)."),
                        ("Elo advantage", "Difference in Elo ratings. +100 is significant — means consistently beating better opponents."),
                        ("Ranking advantage", "Gap in UFC division rankings. Champion = 0, up to #15. Unranked defaults to 99."),
                    ])

                    guideSection("Market & Odds", items: [
                        ("Market odds edge", "Difference in betting market probability. Captures the collective wisdom of oddsmakers."),
                        ("No odds available", "Flag indicating no betting data exists. Fights without odds behave differently."),
                    ])

                    guideSection("Career", items: [
                        ("Experience gap", "Difference in total UFC fights. Experience correlates with octagon IQ."),
                        ("Win rate advantage", "Difference in career win percentage."),
                        ("Finish rate edge", "How often each fighter wins by KO/TKO or submission vs decision."),
                        ("KO rate edge", "How often each fighter wins specifically by knockout."),
                        ("Submission rate edge", "How often each fighter wins by submission."),
                        ("Vulnerability to finishes", "How often each fighter loses by KO or submission."),
                    ])

                    guideSection("Recent Form", items: [
                        ("Recent form (last 3/5)", "Win rate in recent fights. Captures current momentum."),
                        ("Win streak advantage", "Current consecutive wins or losses."),
                        ("Activity gap", "Days since last fight. Ring rust is real."),
                    ])

                    guideSection("Physical", items: [
                        ("Height advantage", "Height difference in inches. Affects range management."),
                        ("Reach advantage", "Arm reach difference. Longer reach = ability to hit without being hit. One of the most predictive physical features."),
                        ("Age difference", "Younger fighters have better cardio; older fighters bring experience."),
                    ])

                    guideSection("Striking", items: [
                        ("Striking volume edge", "Significant strikes landed per minute. Higher = more active and aggressive."),
                        ("Strike defense edge", "Percentage of strikes evaded or blocked. Elite: >60%."),
                        ("KO power advantage", "Career knockdown average. Measures raw stopping power."),
                        ("Damage absorbed gap", "Strikes absorbed per minute. High = more vulnerable to finishes."),
                    ])

                    guideSection("Grappling", items: [
                        ("Takedown defense edge", "Percentage of takedowns defended. Elite: >80%."),
                        ("Takedown accuracy edge", "Percentage of takedowns completed. Wrestlers with 60%+ control where the fight goes."),
                        ("Control time advantage", "Average seconds of ground control per fight. Dominant grapplers accumulate 5+ minutes."),
                        ("Submission threat edge", "Submission attempts per 15 min. High values indicate active ground hunters."),
                    ])

                    guideSection("Fighting Style", items: [
                        ("Head targeting edge", "Percentage of strikes aimed at the head. >55% = more KO potential but predictable."),
                        ("Distance fighting edge", "Strikes at distance vs clinch/ground. >70% = prefers standing."),
                        ("Round 1 aggression", "KDs in Round 1. Fast starters often win early but may fade."),
                        ("Cardio advantage", "Striking output in late rounds vs early rounds. >0.8 = cardio machine."),
                    ])

                    // Tips
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tips")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(BSColors.accent)

                        tipRow("Multiple factors matter more than one alone.")
                        tipRow("Context matters — takedown defense is more important vs a wrestler.")
                        tipRow("LOW confidence means factors are close — the fight is a toss-up.")
                        tipRow("The model doesn't know about injuries, weight cuts, or camp changes.")
                    }
                    .padding(14)
                    .background(BSColors.surface)
                    .cornerRadius(12)
                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .background(BSColors.background)
            .navigationTitle("Prediction Factors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(BSColors.textHint)
                    }
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func guideSection(_ title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(BSColors.accent)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.0)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(BSColors.textPrimary)
                    Text(item.1)
                        .font(.system(size: 12))
                        .foregroundColor(BSColors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(14)
        .background(BSColors.surface)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 10))
                .foregroundColor(BSColors.titleGold)
                .padding(.top, 3)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(BSColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
