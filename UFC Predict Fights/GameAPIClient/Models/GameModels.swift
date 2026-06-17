//
//  GameModels.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import Foundation

// MARK: - Game Event

struct GameEventDTO: Codable, Identifiable {
    let eventId: Int
    let name: String
    let eventDate: String
    let location: String?
    let lockAt: Date
    let status: String
    let fightCount: Int
    let userCompletedPicks: Int
    let userTotalPicks: Int
    let userEventPoints: Int?
    let cta: String

    var id: Int { eventId }

    var isOpen: Bool { status == "open" }
    var isLocked: Bool { status == "locked" || status == "completed" || status == "scored" }
    var isScored: Bool { status == "scored" }

    var picksProgress: String {
        "\(userCompletedPicks)/\(fightCount)"
    }
}

// MARK: - Game Event Detail

struct GameEventDetailDTO: Codable {
    let eventId: Int
    let name: String
    let eventDate: String
    let location: String?
    let lockAt: Date
    let status: String
    let fightCount: Int
    let fights: [GameFightDTO]
    let picks: [FightPickDTO]
    let scores: [FightScoreDTO]
}

// MARK: - Game Fight

struct GameFightDTO: Codable, Identifiable {
    let fightId: Int
    let weightClass: String?
    let isTitleFight: Bool
    let scheduledRounds: Int
    let fighterRId: Int
    let fighterRName: String
    let fighterRImg: String?
    let fighterRRecord: String?
    let fighterBId: Int
    let fighterBName: String
    let fighterBImg: String?
    let fighterBRecord: String?
    let winnerFighterId: Int?
    let method: String?
    let round: Int?

    var id: Int { fightId }
}

// MARK: - Fight Pick

struct FightPickDTO: Codable, Identifiable {
    let fightId: Int
    let winnerFighterId: Int
    let methodPick: String?
    let roundPick: Int?
    let isComplete: Bool
    let updatedAt: Date
    var locked: Bool?

    var id: Int { fightId }
}

// MARK: - Upsert Pick Request

struct UpsertFightPickRequest: Codable {
    let winnerFighterId: Int
    let methodPick: String?
    let roundPick: Int?
}

// MARK: - Fight Score

struct FightScoreDTO: Codable, Identifiable {
    let fightId: Int
    let winnerPoints: Int
    let methodPoints: Int
    let roundPoints: Int
    let bonusPoints: Int
    let totalPoints: Int
    let resultStatus: String

    var id: Int { fightId }

    var isVoid: Bool { resultStatus == "void" }
    var isScored: Bool { resultStatus == "scored" }
}
