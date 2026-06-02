//
//  BSEventModel.swift
//  BlackSpartan
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation

public struct BSEvent: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let eventDate: String
    public let fightCount: Int
    public let titleFights: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case eventDate  = "event_date"
        case fightCount = "fight_count"
        case titleFights = "title_fights"
    }
}

public struct BSEventDetail: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let eventDate: String
    public let fightCount: Int
    public let titleFights: Int
    public let finishes: Int
    public let fights: [BSEventFight]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case eventDate   = "event_date"
        case fightCount  = "fight_count"
        case titleFights = "title_fights"
        case finishes
        case fights
    }
}

public struct BSEventFight: Codable, Identifiable {
    public let fightId: Int
    public let method: String?
    public let methodDetail: String?
    public let round: Int?
    public let timeSecs: Int?
    public let isTitleFight: Bool
    public let outcome: String
    public let weightClass: String?
    // Red corner
    public let fighterRId: Int
    public let fighterRName: String
    public let fighterRImg: String?
    public let fighterRWinner: Bool?
    public let fighterRKd: Int
    public let fighterRSigStr: Int
    // Blue corner
    public let fighterBId: Int
    public let fighterBName: String
    public let fighterBImg: String?
    public let fighterBWinner: Bool?
    public let fighterBKd: Int
    public let fighterBSigStr: Int

    public var id: Int { fightId }

    public var winnerName: String? {
        if fighterRWinner == true { return fighterRName }
        if fighterBWinner == true { return fighterBName }
        return nil
    }

    public var loserName: String? {
        if fighterRWinner == true { return fighterBName }
        if fighterBWinner == true { return fighterRName }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case fightId       = "fight_id"
        case method
        case methodDetail  = "method_detail"
        case round
        case timeSecs      = "time_secs"
        case isTitleFight  = "is_title_fight"
        case outcome
        case weightClass   = "weight_class"
        case fighterRId    = "fighter_r_id"
        case fighterRName  = "fighter_r_name"
        case fighterRImg   = "fighter_r_img"
        case fighterRWinner = "fighter_r_winner"
        case fighterRKd    = "fighter_r_kd"
        case fighterRSigStr = "fighter_r_sig_str"
        case fighterBId    = "fighter_b_id"
        case fighterBName  = "fighter_b_name"
        case fighterBImg   = "fighter_b_img"
        case fighterBWinner = "fighter_b_winner"
        case fighterBKd    = "fighter_b_kd"
        case fighterBSigStr = "fighter_b_sig_str"
    }
}
