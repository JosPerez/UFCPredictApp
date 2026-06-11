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
    private let profileService = BSFighterService(url: Config.baseURL)
    private var profileContinuationA: CheckedContinuation<BSFighterProfile, Error>?
    private var profileContinuationB: CheckedContinuation<BSFighterProfile, Error>?
    var isLoadingProfiles: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var canPredict: Bool {
        fighterA != nil && fighterB != nil && !isLoading
    }

    // MARK: - Dependencies

    private let service = BSPredictService(url: Config.baseURL)

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        setupService()
    }

    private func setupService() {
        service.delegate = self
    }

    // MARK: - Selection

    func selectFighterA(_ fighter: CachedFighter) {
        fighterA = fighter
        prediction = nil
        errorMessage = nil
        profileA = nil
        Task { await fetchProfileA(fighter.fighterId) }
    }

    func selectFighterB(_ fighter: CachedFighter) {
        fighterB = fighter
        prediction = nil
        errorMessage = nil
        profileB = nil
        Task { await fetchProfileB(fighter.fighterId) }
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
        guard let a = fighterA, let b = fighterB else { return }
        isLoading = true
        errorMessage = nil
        prediction = nil

        let request = PredictionRequest(
            fighterAId: a.fighterId,
            fighterBId: b.fighterId
        )
        service.predictFight(request: request)
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

    /// Categorías permitidas para Fighter B basadas en Fighter A
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

    private func fetchProfileA(_ id: Int) async {
        isLoadingProfiles = true
        do {
            profileA = try await withCheckedThrowingContinuation { continuation in
                self.profileContinuationA = continuation
                self.profileService.delegate = self
                self.profileService.getFighterProfile(id: id)
            }
        } catch {
            profileA = nil
        }
        isLoadingProfiles = profileB == nil && fighterB != nil
    }

    private func fetchProfileB(_ id: Int) async {
        isLoadingProfiles = true
        do {
            profileB = try await withCheckedThrowingContinuation { continuation in
                self.profileContinuationB = continuation
                self.profileService.delegate = self
                self.profileService.getFighterProfile(id: id)
            }
        } catch {
            profileB = nil
        }
        isLoadingProfiles = false
    }
}



extension PredictionViewModel {
    
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
            confidence:    prediction.confidence
        )
        context.insert(cached)
        try? context.save()
    }
}

// MARK: - BSResponseDelegate

extension PredictionViewModel: BSResponseDelegate {
    enum RequestName: String {
        case predict = "predcit"
        case profile = "getFighterProfile"
    }

    func recievedEntity<T>(entity: T, requestName: String) {
        switch RequestName(rawValue: requestName) {
        case .predict:
            if let response = entity as? Prediction {
                self.prediction = response
                self.isLoading = false
                savePrediction(response)
            } else if let error = entity as? BSErrorBase {
                self.errorMessage = error.message
                self.isLoading = false
            }
        case .profile:
            if let profile = entity as? BSFighterProfile {
                if profile.id == fighterA?.fighterId {
                    profileContinuationA?.resume(returning: profile)
                    profileContinuationA = nil
                } else if profile.id == fighterB?.fighterId {
                    profileContinuationB?.resume(returning: profile)
                    profileContinuationB = nil
                }
            } else if let error = entity as? BSErrorBase {
                profileContinuationA?.resume(throwing: error)
                profileContinuationA = nil
                profileContinuationB?.resume(throwing: error)
                profileContinuationB = nil
            }
        default: break
        }
    }
}
