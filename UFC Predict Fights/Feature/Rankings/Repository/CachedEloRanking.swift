//
//  CachedEloRanking.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 14/06/26.
//

import Foundation
import SwiftData

@Model
final class CachedEloRanking {
    var fighterId: Int
    var fighterName: String
    var weightClass: String?
    var elo: Double
    var rank: Int
    var imgThumb: String?
    var record: String?
    var division: String  // "All" or weight class used in query
    var lastUpdated: Date

    // Composite key for upsert
    var compositeKey: String {
        "\(division)::\(rank)"
    }

    init(
        fighterId: Int,
        fighterName: String,
        weightClass: String? = nil,
        elo: Double,
        rank: Int,
        imgThumb: String? = nil,
        record: String? = nil,
        division: String,
        lastUpdated: Date = .now
    ) {
        self.fighterId = fighterId
        self.fighterName = fighterName
        self.weightClass = weightClass
        self.elo = elo
        self.rank = rank
        self.imgThumb = imgThumb
        self.record = record
        self.division = division
        self.lastUpdated = lastUpdated
    }
}
