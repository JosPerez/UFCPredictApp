//
//  PredictionViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import Observation
import BlackSpartan
import SwiftData

@MainActor
@Observable
final class PredictionViewModel {

    // MARK: - State

    private var modelContext: ModelContext?
    var fighterA: CachedFighter? = nil
    var fighterB: CachedFighter? = nil
    var prediction: Prediction? = nil
    var profileA: BSFighterProfile? = nil
    var profileB: BSFighterProfile? = nil
    var isLoadingProfiles: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let api = GameAPIClient.shared

    var canPredict: Bool {
        fighterA != nil && fighterB != nil && !isLoading
    }

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    // MARK: - Selection

    func selectFighterA(_ fighter: CachedFighter) {
        fighterA = fighter
        prediction = nil
        errorMessage = nil
        profileA = nil
        fetchProfileA(fighter.fighterId)
    }

    func selectFighterB(_ fighter: CachedFighter) {
        fighterB = fighter
        prediction = nil
        errorMessage = nil
        profileB = nil
        fetchProfileB(fighter.fighterId)
    }

    func clearFighterA() {
        fighterA = nil
        profileA = nil
        prediction = nil
        errorMessage = nil
    }

    func clearFighterB() {
        fighterB = nil
        profileB = nil
        prediction = nil
        errorMessage = nil
    }

    func swapFighters() {
        let tempF = fighterA
        let tempP = profileA
        fighterA = fighterB
        profileA = profileB
        fighterB = tempF
        profileB = tempP
        prediction = nil
    }

    // MARK: - Predict

    func predict() {
        CrashReporter.log("Predict: \(fighterA?.fullName ?? "") vs \(fighterB?.fullName ?? "")")
        guard let a = fighterA, let b = fighterB else { return }
        isLoading = true
        errorMessage = nil
        prediction = nil

        Task {
            do {
                let result = try await api.predictFight(
                    fighterAId: a.fighterId,
                    fighterBId: b.fighterId
                )
                prediction = result
                savePrediction(result)
            } catch let error as GameAPIClient.APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Prediction failed"
            }
            isLoading = false
        }
    }

    // MARK: - Reset

    func reset() {
        fighterA = nil
        fighterB = nil
        profileA = nil
        profileB = nil
        prediction = nil
        errorMessage = nil
        isLoading = false
    }

    // MARK: - Weight class config

    private static let weightClassOrder: [String] = [
        "Strawweight", "Flyweight", "Bantamweight", "Featherweight",
        "Lightweight", "Welterweight", "Middleweight",
        "Light Heavyweight", "Heavyweight"
    ]

    private static let womensWeightClassOrder: [String] = [
        "Women's Strawweight", "Women's Flyweight",
        "Women's Bantamweight", "Women's Featherweight"
    ]

    var allowedWeightClasses: [String]? {
        guard let wc = fighterA?.weightClass else { return nil }

        let order: [String]
        if wc.starts(with: "Women") {
            order = Self.womensWeightClassOrder
        } else {
            order = Self.weightClassOrder
        }

        guard let index = order.firstIndex(of: wc) else { return nil }

        var allowed: [String] = [wc]
        if index > 0 { allowed.append(order[index - 1]) }
        if index < order.count - 1 { allowed.append(order[index + 1]) }
        return allowed
    }

    // MARK: - Profile fetching

    private func fetchProfileA(_ id: Int) {
        isLoadingProfiles = true

        Task {
            do {
                profileA = try await api.getFighterProfile(id: id)
            } catch {
                profileA = nil
            }
            isLoadingProfiles = profileB == nil && fighterB != nil
        }
    }

    private func fetchProfileB(_ id: Int) {
        isLoadingProfiles = true

        Task {
            do {
                profileB = try await api.getFighterProfile(id: id)
            } catch {
                profileB = nil
            }
            isLoadingProfiles = false
        }
    }

    // MARK: - Save Prediction

    private func savePrediction(_ prediction: Prediction) {
        guard let context = modelContext else { return }
        let cached = CachedPrediction(
            fighterAId:    prediction.fighterAId,
            fighterBId:    prediction.fighterBId,
            fighterAName:  prediction.fighterAName,
            fighterBName:  prediction.fighterBName,
            fighterAImg:   fighterA?.imgThumb,
            fighterBImg:   fighterB?.imgThumb,
            fighterAProb:  prediction.fighterAWinProb,
            fighterBProb:  prediction.fighterBWinProb,
            confidence:    prediction.confidence,
            modelUsed:     prediction.modelUsed,
            decisionProb:  prediction.outcome?.decisionProb,
            finishProb:    prediction.outcome?.finishProb,
            methodDecProb: prediction.method?.decisionProb,
            methodKoProb:  prediction.method?.koTkoProb,
            methodSubProb: prediction.method?.submissionProb,
            durationR1:    prediction.duration?.r1FinishProb,
            durationR2:    prediction.duration?.r2FinishProb,
            durationR3:    prediction.duration?.r3FinishProb,
            durationLate:  prediction.duration?.lateFinishProb,
            durationDec:   prediction.duration?.decisionProb
        )
        context.insert(cached)
        try? context.save()
    }
}
