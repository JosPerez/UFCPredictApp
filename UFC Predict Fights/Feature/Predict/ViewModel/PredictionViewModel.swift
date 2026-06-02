//
//  PredictionViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import Observation
import BlackSpartan

@MainActor
@Observable
final class PredictionViewModel {

    // MARK: - State

    var fighterA: CachedFighter? = nil
    var fighterB: CachedFighter? = nil
    var prediction: Prediction? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var canPredict: Bool {
        fighterA != nil && fighterB != nil && !isLoading
    }

    // MARK: - Dependencies

    private let service = BSPredictService(url: Config.baseURL)

    init() {
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
    }

    func selectFighterB(_ fighter: CachedFighter) {
        fighterB = fighter
        prediction = nil
        errorMessage = nil
    }

    func clearFighterA() {
        fighterA = nil
        prediction = nil
        errorMessage = nil
    }

    func clearFighterB() {
        fighterB = nil
        prediction = nil
        errorMessage = nil
    }

    func swapFighters() {
        let temp = fighterA
        fighterA = fighterB
        fighterB = temp
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
}

// MARK: - BSResponseDelegate

extension PredictionViewModel: BSResponseDelegate {
    enum RequestName: String {
        case predict = "predcit"
    }

    func recievedEntity<T>(entity: T, requestName: String) {
        switch RequestName(rawValue: requestName) {
        case .predict:
            if let response = entity as? Prediction {
                self.prediction = response
                self.isLoading = false
            } else if let error = entity as? BSErrorBase {
                self.errorMessage = error.message
                self.isLoading = false
            }
        default: break
        }
    }
}
