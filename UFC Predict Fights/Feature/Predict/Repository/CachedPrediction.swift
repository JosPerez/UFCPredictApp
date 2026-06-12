//
//  CachedPrediction.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 03/06/26.
//

import Foundation
import SwiftData
import BlackSpartan

@Model
final class CachedPrediction {
    var fighterAId: Int
    var fighterBId: Int
    var fighterAName: String
    var fighterBName: String
    var fighterAImg: String?
    var fighterBImg: String?
    var fighterAProb: Double
    var fighterBProb: Double
    var confidence: String
    var modelUsed: String
    // Outcome
    var decisionProb: Double?
    var finishProb: Double?
    // Method
    var methodDecProb: Double?
    var methodKoProb: Double?
    var methodSubProb: Double?
    // Duration
    var durationR1: Double?
    var durationR2: Double?
    var durationR3: Double?
    var durationLate: Double?
    var durationDec: Double?

    var createdAt: Date

    var winnerName: String {
        fighterAProb > fighterBProb ? fighterAName : fighterBName
    }

    var winnerProb: Double {
        max(fighterAProb, fighterBProb)
    }

    var predictedMethod: String? {
        guard let dec = methodDecProb, let ko = methodKoProb, let sub = methodSubProb else { return nil }
        let maxProb = max(dec, ko, sub)
        if maxProb == ko { return "KO/TKO" }
        if maxProb == sub { return "SUB" }
        return "DEC"
    }

    var predictedMethodProb: Double? {
        guard let dec = methodDecProb, let ko = methodKoProb, let sub = methodSubProb else { return nil }
        return max(dec, ko, sub)
    }

    var isFinishLikely: Bool {
        guard let finish = finishProb else { return false }
        return finish > 0.5
    }

    init(
        fighterAId: Int,
        fighterBId: Int,
        fighterAName: String,
        fighterBName: String,
        fighterAImg: String? = nil,
        fighterBImg: String? = nil,
        fighterAProb: Double,
        fighterBProb: Double,
        confidence: String,
        modelUsed: String = "winner_pure",
        decisionProb: Double? = nil,
        finishProb: Double? = nil,
        methodDecProb: Double? = nil,
        methodKoProb: Double? = nil,
        methodSubProb: Double? = nil,
        durationR1: Double? = nil,
        durationR2: Double? = nil,
        durationR3: Double? = nil,
        durationLate: Double? = nil,
        durationDec: Double? = nil,
        createdAt: Date = .now
    ) {
        self.fighterAId = fighterAId
        self.fighterBId = fighterBId
        self.fighterAName = fighterAName
        self.fighterBName = fighterBName
        self.fighterAImg = fighterAImg
        self.fighterBImg = fighterBImg
        self.fighterAProb = fighterAProb
        self.fighterBProb = fighterBProb
        self.confidence = confidence
        self.modelUsed = modelUsed
        self.decisionProb = decisionProb
        self.finishProb = finishProb
        self.methodDecProb = methodDecProb
        self.methodKoProb = methodKoProb
        self.methodSubProb = methodSubProb
        self.durationR1 = durationR1
        self.durationR2 = durationR2
        self.durationR3 = durationR3
        self.durationLate = durationLate
        self.durationDec = durationDec
        self.createdAt = createdAt
    }
}
