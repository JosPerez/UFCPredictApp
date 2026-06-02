//
//  BSPredictModel.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation

public struct PredictionRequest: Codable {
    let fighterAId: Int
    let fighterBId: Int

    enum CodingKeys: String, CodingKey {
        case fighterAId = "fighter_a_id"
        case fighterBId = "fighter_b_id"
    }
    
    public init(fighterAId: Int, fighterBId: Int) {
        self.fighterAId = fighterAId
        self.fighterBId = fighterBId
    }
}

public struct Prediction: Codable {
    public let fighterAId: Int
    public let fighterBId: Int
    public let fighterAName: String
    public let fighterBName: String
    public let fighterAWinProb: Double
    public let fighterBWinProb: Double
    public let confidence: String
    public let topFactors: [PredictionFactor]
    public let warning: String?

    enum CodingKeys: String, CodingKey {
        case fighterAId    = "fighter_a_id"
        case fighterBId    = "fighter_b_id"
        case fighterAName  = "fighter_a_name"
        case fighterBName  = "fighter_b_name"
        case fighterAWinProb = "fighter_a_win_prob"
        case fighterBWinProb = "fighter_b_win_prob"
        case confidence
        case topFactors    = "top_factors"
        case warning
    }
}

public struct PredictionFactor: Codable, Identifiable {
    public var id: String { feature }
    public let feature: String
    public let impact: Double
}
