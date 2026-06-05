//
//  BSFighterModel.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation

// Models/Fighter.swift
public struct BSFighter: Codable, Identifiable, Hashable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let nickname: String?
    public let weightClass: String?
    public let gender: String?
    public let recordWin: Int
    public let recordLoss: Int
    public let recordDraw: Int
    public let isActive: Bool
    public let imgThumb: String?
    public let currentRank: Int?

    public var fullName: String { "\(firstName) \(lastName)" }
    public var record: String { "\(recordWin)W · \(recordLoss)L - \(recordDraw)D" }
    
    public var winRate: String {
        let total = recordWin + recordLoss
        guard total > 0 else { return "—" }
        let rate = Double(recordWin) / Double(total) * 100
        return "\(Int(rate))%"
    }

    public var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName   = "first_name"
        case lastName    = "last_name"
        case nickname
        case weightClass = "weight_class"
        case gender
        case recordWin   = "record_win"
        case recordLoss  = "record_loss"
        case recordDraw  = "record_draw"
        case isActive    = "is_active"
        case imgThumb = "img_thumb"
        case currentRank = "current_rank"
    }
}

// Models/FighterDetail.swift
public struct BSFighterDetail: Codable, Identifiable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let nickname: String?
    public let weightClass: String?
    public let gender: String?
    public let recordWin: Int
    public let recordLoss: Int
    public let recordDraw: Int
    public let isActive: Bool
    public let heightInches: Double?
    public let reachInches: Double?
    public let age: Int?
    public let sigStrikesLandedPm: Double?
    public let sigStrikeDefensePct: Double?
    public let fightingStyle: String?
    public let imgThumb: String?

    public var fullName: String { "\(firstName) \(lastName)" }
    public var record: String { "\(recordWin)W · \(recordLoss)L - \(recordDraw)D" }
    
    public var winRate: String {
        let total = recordWin + recordLoss
        guard total > 0 else { return "—" }
        let rate = Double(recordWin) / Double(total) * 100
        return "\(Int(rate))%"
    }
    public var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName          = "first_name"
        case lastName           = "last_name"
        case nickname
        case weightClass        = "weight_class"
        case gender
        case recordWin          = "record_win"
        case recordLoss         = "record_loss"
        case recordDraw         = "record_draw"
        case isActive           = "is_active"
        case heightInches       = "height_inches"
        case reachInches        = "reach_inches"
        case age
        case sigStrikesLandedPm = "sig_strikes_landed_pm"
        case sigStrikeDefensePct = "sig_strike_defense_pct"
        case fightingStyle      = "fighting_style"
        case imgThumb = "img_thumb"
    }
}

