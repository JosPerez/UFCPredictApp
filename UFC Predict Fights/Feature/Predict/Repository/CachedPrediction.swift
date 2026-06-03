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
    var createdAt: Date

    var winnerName: String {
        fighterAProb > fighterBProb ? fighterAName : fighterBName
    }

    var winnerProb: Double {
        max(fighterAProb, fighterBProb)
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
        self.createdAt = createdAt
    }
}
