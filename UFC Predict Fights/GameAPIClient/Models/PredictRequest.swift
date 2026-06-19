//
//  PredictRequest.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 18/06/26.
//
import Foundation

struct PredictRequest: Codable {
    let fighterAId: Int
    let fighterBId: Int
    
    enum CodingKeys: String, CodingKey {
            case fighterAId = "fighter_a_id"
            case fighterBId = "fighter_b_id"
        }
}
