//
//  BSFighterProfileModel.swift
//  BlackSpartan
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation

public struct BSFighterProfile: Codable, Identifiable {
    // Bio
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let nickname: String?
    public let weightClass: String?
    public let gender: String?
    public let isActive: Bool
    public let imgThumb: String?
    public let fightingStyle: String?
    public let trainsAt: String?
    public let hometown: String?
    public let octagonDebut: String?   // date como string
    // Récord
    public let recordWin: Int
    public let recordLoss: Int
    public let recordDraw: Int
    public let winRate: Double?
    public let finishRate: Double?
    public let currentStreak: Int
    // Desglose
    public let winMethods: BSWinMethodBreakdown
    public let winRounds: BSWinRoundBreakdown
    // Stats
    public let performance: BSPerformanceStats
    // Físico
    public let physical: BSPhysicalStats
    // Últimas peleas
    public let recentFights: [BSRecentFight]
    public let fightingStyleData: BSFightingStyleData?
    // Elo
    public let currentElo: Double?
    public let currentRank: Int?

    public var fullName: String { "\(firstName) \(lastName)" }
    public var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName     = "first_name"
        case lastName      = "last_name"
        case nickname
        case weightClass   = "weight_class"
        case gender
        case isActive      = "is_active"
        case imgThumb      = "img_thumb"
        case fightingStyle = "fighting_style"
        case trainsAt      = "trains_at"
        case hometown
        case octagonDebut  = "octagon_debut"
        case recordWin     = "record_win"
        case recordLoss    = "record_loss"
        case recordDraw    = "record_draw"
        case winRate       = "win_rate"
        case finishRate    = "finish_rate"
        case currentStreak = "current_streak"
        case winMethods    = "win_methods"
        case winRounds     = "win_rounds"
        case performance
        case physical
        case recentFights  = "recent_fights"
        case fightingStyleData = "fighting_style_data"
        case currentElo     = "current_elo"
        case currentRank     = "current_rank"

    }
}

public struct BSWinMethodBreakdown: Codable {
    public let koTko: Int
    public let submission: Int
    public let decision: Int
    public let koPct: Double
    public let subPct: Double
    public let decPct: Double

    enum CodingKeys: String, CodingKey {
        case koTko     = "ko_tko"
        case submission
        case decision
        case koPct     = "ko_pct"
        case subPct    = "sub_pct"
        case decPct    = "dec_pct"
    }
}

public struct BSWinRoundBreakdown: Codable {
    public let r1: Int
    public let r2: Int
    public let r3: Int
    public let r4: Int
    public let r5: Int
}

public struct BSPerformanceStats: Codable {
    public let sigStrikesLandedPm: Double?
    public let sigStrikesAbsorbedPm: Double?
    public let sigStrikeDefensePct: Double?
    public let knockdownAvg: Double?
    public let takedownAvg: Double?
    public let submissionAvg: Double?
    public let takedownDefensePct: Double?
    public let avgFightTimeSecs: Int?

    enum CodingKeys: String, CodingKey {
        case sigStrikesLandedPm   = "sig_strikes_landed_pm"
        case sigStrikesAbsorbedPm = "sig_strikes_absorbed_pm"
        case sigStrikeDefensePct  = "sig_strike_defense_pct"
        case knockdownAvg         = "knockdown_avg"
        case takedownAvg          = "takedown_avg"
        case submissionAvg        = "submission_avg"
        case takedownDefensePct   = "takedown_defense_pct"
        case avgFightTimeSecs     = "avg_fight_time_secs"
    }
}

public struct BSPhysicalStats: Codable {
    public let heightInches: Double?
    public let reachInches: Double?
    public let legReachInches: Double?
    public let weightLbs: Double?
    public let age: Int?

    enum CodingKeys: String, CodingKey {
        case heightInches    = "height_inches"
        case reachInches     = "reach_inches"
        case legReachInches  = "leg_reach_inches"
        case weightLbs       = "weight_lbs"
        case age
    }
}

public struct BSRecentFight: Codable, Identifiable {
    public let fightId: Int
    public let eventId: Int
    public let eventName: String
    public let eventDate: String
    public let opponentId: Int
    public let opponentName: String
    public let result: String
    public let method: String?
    public let methodDetail: String?
    public let round: Int?
    public let timeSecs: Int?
    public let isTitleFight: Bool
    public let knockdowns: Int
    public let significantStrikes: Int
    public let sigStrAttempted: Int
    public let sigStrPct: Double?
    public let takedownsLanded: Int
    public let takedownsAttempted: Int
    public let subAttempts: Int
    public let ctrlTimeSecs: Int
    public let opponentImg: String?

    public var id: Int { fightId }

    enum CodingKeys: String, CodingKey {
        case fightId           = "fight_id"
        case eventId           = "event_id"
        case eventName         = "event_name"
        case eventDate         = "event_date"
        case opponentId        = "opponent_id"
        case opponentName      = "opponent_name"
        case result
        case method
        case methodDetail      = "method_detail"
        case round
        case timeSecs          = "time_secs"
        case isTitleFight      = "is_title_fight"
        case knockdowns
        case significantStrikes = "significant_strikes"
        case sigStrAttempted    = "sig_str_attempted"
        case sigStrPct          = "sig_str_pct"
        case takedownsLanded    = "takedowns_landed"
        case takedownsAttempted = "takedowns_attempted"
        case subAttempts        = "sub_attempts"
        case ctrlTimeSecs       = "ctrl_time_secs"
        case opponentImg = "opponent_img"
    }
}

// ── Fighting Style Data ──

public struct BSFightingStyleData: Codable {
    public let strikeTarget: BSStrikeTargetBreakdown
    public let strikePosition: BSStrikePositionBreakdown
    public let grappling: BSGrapplingStyle
    public let tempo: BSTempoStyle

    enum CodingKeys: String, CodingKey {
        case strikeTarget   = "strike_target"
        case strikePosition = "strike_position"
        case grappling
        case tempo
    }
}

public struct BSStrikeTargetBreakdown: Codable {
    public let headPct: Double?
    public let bodyPct: Double?
    public let legPct: Double?

    enum CodingKeys: String, CodingKey {
        case headPct = "head_pct"
        case bodyPct = "body_pct"
        case legPct  = "leg_pct"
    }
}

public struct BSStrikePositionBreakdown: Codable {
    public let distancePct: Double?
    public let clinchPct: Double?
    public let groundPct: Double?

    enum CodingKeys: String, CodingKey {
        case distancePct = "distance_pct"
        case clinchPct   = "clinch_pct"
        case groundPct   = "ground_pct"
    }
}

public struct BSGrapplingStyle: Codable {
    public let tdAccuracy: Double?
    public let avgCtrlTimeSecs: Double?

    enum CodingKeys: String, CodingKey {
        case tdAccuracy       = "td_accuracy"
        case avgCtrlTimeSecs  = "avg_ctrl_time_secs"
    }
}

public struct BSTempoStyle: Codable {
    public let r1KdAvg: Double?
    public let cardioIndex: Double?

    enum CodingKeys: String, CodingKey {
        case r1KdAvg     = "r1_kd_avg"
        case cardioIndex = "cardio_index"
    }
}
