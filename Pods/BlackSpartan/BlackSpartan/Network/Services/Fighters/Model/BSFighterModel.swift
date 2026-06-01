//
//  BSFighterModel.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation

// Models/Fighter.swift
struct Fighter: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let nickname: String?
    let weightClass: String?
    let gender: String?
    let recordWin: Int
    let recordLoss: Int
    let recordDraw: Int
    let isActive: Bool

    var fullName: String { "\(firstName) \(lastName)" }

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
    }
}

// Models/FighterDetail.swift
struct FighterDetail: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let nickname: String?
    let weightClass: String?
    let gender: String?
    let recordWin: Int
    let recordLoss: Int
    let recordDraw: Int
    let isActive: Bool
    let heightInches: Double?
    let reachInches: Double?
    let age: Int?
    let sigStrikesLandedPm: Double?
    let sigStrikeDefensePct: Double?
    let fightingStyle: String?

    var fullName: String { "\(firstName) \(lastName)" }

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
    }
}
