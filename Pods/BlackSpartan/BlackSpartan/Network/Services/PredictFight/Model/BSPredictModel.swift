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
    public let modelUsed: String
    public let topFactors: [PredictionFactor]
    public let outcome: OutcomePrediction?
    public let method: MethodPrediction?
    public let duration: BSDurationPrediction?
    public let warning: String?

    enum CodingKeys: String, CodingKey {
        case fighterAId       = "fighter_a_id"
        case fighterBId       = "fighter_b_id"
        case fighterAName     = "fighter_a_name"
        case fighterBName     = "fighter_b_name"
        case fighterAWinProb  = "fighter_a_win_prob"
        case fighterBWinProb  = "fighter_b_win_prob"
        case confidence
        case modelUsed        = "model_used"
        case topFactors       = "top_factors"
        case outcome
        case method
        case duration
        case warning
    }
}

public struct PredictionFactor: Codable, Identifiable {
    public var id: String { feature }
    public let feature: String
    public let impact: Double
}

public struct OutcomePrediction: Codable {
    public let decisionProb: Double
    public let finishProb: Double

    enum CodingKeys: String, CodingKey {
        case decisionProb  = "decision_prob"
        case finishProb    = "finish_prob"
    }
}

public struct BSDurationPrediction: Codable {
    public let r1FinishProb: Double
    public let r2FinishProb: Double
    public let r3FinishProb: Double
    public let lateFinishProb: Double
    public let decisionProb: Double

    enum CodingKeys: String, CodingKey {
        case r1FinishProb   = "r1_finish_prob"
        case r2FinishProb   = "r2_finish_prob"
        case r3FinishProb   = "r3_finish_prob"
        case lateFinishProb = "late_finish_prob"
        case decisionProb   = "decision_prob"
    }
}

public struct MethodPrediction: Codable {
    public let decisionProb: Double
    public let koTkoProb: Double
    public let submissionProb: Double

    enum CodingKeys: String, CodingKey {
        case decisionProb   = "decision_prob"
        case koTkoProb      = "ko_tko_prob"
        case submissionProb = "submission_prob"
    }
}
