//
//  BSRankingModel.swift
//  BlackSpartan
//
//  Created by Jose Perez on 05/06/26.
//


import Foundation

public struct BSRankingDivision: Codable, Identifiable {
    public let weightClass: String
    public let fighters: [BSRankedFighter]

    public var id: String { weightClass }

    enum CodingKeys: String, CodingKey {
        case weightClass = "weight_class"
        case fighters
    }
}

public struct BSRankedFighter: Codable, Identifiable {
    public let rank: Int
    public let fighterId: Int
    public let firstName: String
    public let lastName: String
    public let nickname: String?
    public let imgThumb: String?
    public let recordWin: Int
    public let recordLoss: Int
    public let recordDraw: Int

    public var id: Int { fighterId }
    public var fullName: String { "\(firstName) \(lastName)" }
    public var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }

    public var isChampion: Bool { rank == 0 }

    enum CodingKeys: String, CodingKey {
        case rank
        case fighterId  = "fighter_id"
        case firstName  = "first_name"
        case lastName   = "last_name"
        case nickname
        case imgThumb   = "img_thumb"
        case recordWin  = "record_win"
        case recordLoss = "record_loss"
        case recordDraw = "record_draw"
    }
}
