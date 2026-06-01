//
//  BSPredictModel.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation

struct PredictionRequest: Codable {
    let fighterAId: Int
    let fighterBId: Int

    enum CodingKeys: String, CodingKey {
        case fighterAId = "fighter_a_id"
        case fighterBId = "fighter_b_id"
    }
}

struct Prediction: Codable {
    let fighterAId: Int
    let fighterBId: Int
    let fighterAName: String
    let fighterBName: String
    let fighterAWinProb: Double
    let fighterBWinProb: Double
    let confidence: String
    let topFactors: [PredictionFactor]
    let warning: String?

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

struct PredictionFactor: Codable, Identifiable {
    var id: String { feature }
    let feature: String
    let impact: Double
}
