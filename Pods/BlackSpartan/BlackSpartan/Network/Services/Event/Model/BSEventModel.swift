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
    public let location: String?
    public let fightCount: Int
    public let titleFights: Int
    public let isUpcoming: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case eventDate   = "event_date"
        case fightCount  = "fight_count"
        case titleFights = "title_fights"
        case isUpcoming  = "is_upcoming"
        case location
    }
}

public struct BSEventDetail: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let eventDate: String
    public let location: String?
    public let fightCount: Int
    public let titleFights: Int
    public let finishes: Int
    public let isUpcoming: Bool
    public let fights: [BSEventFight]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case eventDate   = "event_date"
        case fightCount  = "fight_count"
        case titleFights = "title_fights"
        case finishes
        case isUpcoming  = "is_upcoming"
        case fights
        case location
    }
}

public struct BSAIPredictionMethod: Codable {
    public let decisionProb: Double
    public let koTkoProb: Double
    public let submissionProb: Double

    enum CodingKeys: String, CodingKey {
        case decisionProb   = "decision_prob"
        case koTkoProb      = "ko_tko_prob"
        case submissionProb = "submission_prob"
    }
}

public struct BSAIPrediction: Codable {
    /// Prob de que gane el peleador del corner rojo (fighter_a en el backend).
    public let fighterRWinProb: Double
    /// Prob del corner azul.
    public let fighterBWinProb: Double
    public let confidence: String
    public let modelUsed: String
    public let method: BSAIPredictionMethod?

    enum CodingKeys: String, CodingKey {
        case fighterRWinProb = "fighter_a_win_prob"
        case fighterBWinProb = "fighter_b_win_prob"
        case confidence
        case modelUsed       = "model_used"
        case method
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
    public let fighterRSigStrAttempted: Int
    public let fighterRSigStrPct: Double?
    public let fighterRTdLanded: Int
    public let fighterRTdAttempted: Int
    public let fighterRSubAtt: Int
    public let fighterRCtrlSecs: Int
    // Blue corner
    public let fighterBId: Int
    public let fighterBName: String
    public let fighterBImg: String?
    public let fighterBWinner: Bool?
    public let fighterBKd: Int
    public let fighterBSigStr: Int
    public let fighterBSigStrAttempted: Int
    public let fighterBSigStrPct: Double?
    public let fighterBTdLanded: Int
    public let fighterBTdAttempted: Int
    public let fighterBSubAtt: Int
    public let fighterBCtrlSecs: Int
    // Odds
    public let oddsFighterRProb: Double?
    public let oddsFighterBProb: Double?
    public let oddsNumSources: Int?
    // Career stats (upcoming)
    public let fighterRSlpm: Double?
    public let fighterRStrDef: Double?
    public let fighterRSubAvg: Double?
    public let fighterBSlpm: Double?
    public let fighterBStrDef: Double?
    public let fighterBSubAvg: Double?
    // Records
    public let fighterRRecord: String?
    public let fighterBRecord: String?
    // Career stats (extra)
    public let fighterRSapm: Double?
    public let fighterRKdAvg: Double?
    public let fighterRTdDef: Double?
    public let fighterBSapm: Double?
    public let fighterBKdAvg: Double?
    public let fighterBTdDef: Double?
    public let fighterRTdAvg: Double?
    public let fighterRAvgFightTime: Int?
    public let fighterBTdAvg: Double?
    public let fighterBAvgFightTime: Int?
    // Tale of the tape (red)
    public let fighterRHeight: Double?
    public let fighterRReach: Double?
    public let fighterRLegReach: Double?
    public let fighterRAge: Int?
    public let fighterRWeight: Double?
    public let fighterRRank: Int?
    public let fighterRElo: Double?
    // Tale of the tape (blue)
    public let fighterBHeight: Double?
    public let fighterBReach: Double?
    public let fighterBLegReach: Double?
    public let fighterBAge: Int?
    public let fighterBWeight: Double?
    public let fighterBRank: Int?
    public let fighterBElo: Double?
    // AI cached prediction
    public let aiPrediction: BSAIPrediction?

    public var id: Int { fightId }

    public var isUpcoming: Bool { outcome == "UPCOMING" }

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
        case fightId        = "fight_id"
        case method
        case methodDetail   = "method_detail"
        case round
        case timeSecs       = "time_secs"
        case isTitleFight   = "is_title_fight"
        case outcome
        case weightClass    = "weight_class"
        case fighterRId     = "fighter_r_id"
        case fighterRName   = "fighter_r_name"
        case fighterRImg    = "fighter_r_img"
        case fighterRWinner = "fighter_r_winner"
        case fighterRKd     = "fighter_r_kd"
        case fighterRSigStr = "fighter_r_sig_str"
        case fighterBId     = "fighter_b_id"
        case fighterBName   = "fighter_b_name"
        case fighterBImg    = "fighter_b_img"
        case fighterBWinner = "fighter_b_winner"
        case fighterBKd     = "fighter_b_kd"
        case fighterBSigStr = "fighter_b_sig_str"
        case oddsFighterRProb = "odds_fighter_r_prob"
        case oddsFighterBProb = "odds_fighter_b_prob"
        case oddsNumSources   = "odds_num_sources"
        case fighterRSigStrAttempted = "fighter_r_sig_str_attempted"
        case fighterRSigStrPct       = "fighter_r_sig_str_pct"
        case fighterRTdLanded        = "fighter_r_td_landed"
        case fighterRTdAttempted     = "fighter_r_td_attempted"
        case fighterRSubAtt          = "fighter_r_sub_att"
        case fighterRCtrlSecs        = "fighter_r_ctrl_secs"
        case fighterBSigStrAttempted = "fighter_b_sig_str_attempted"
        case fighterBSigStrPct       = "fighter_b_sig_str_pct"
        case fighterBTdLanded        = "fighter_b_td_landed"
        case fighterBTdAttempted     = "fighter_b_td_attempted"
        case fighterBSubAtt          = "fighter_b_sub_att"
        case fighterBCtrlSecs        = "fighter_b_ctrl_secs"
        case fighterRSlpm            = "fighter_r_slpm"
        case fighterRStrDef          = "fighter_r_str_def"
        case fighterRSubAvg          = "fighter_r_sub_avg"
        case fighterBSlpm            = "fighter_b_slpm"
        case fighterBStrDef          = "fighter_b_str_def"
        case fighterBSubAvg          = "fighter_b_sub_avg"
        case fighterRRecord  = "fighter_r_record"
        case fighterBRecord  = "fighter_b_record"
        case fighterRSapm    = "fighter_r_sapm"
        case fighterRKdAvg   = "fighter_r_kd_avg"
        case fighterRTdDef   = "fighter_r_td_def"
        case fighterBSapm    = "fighter_b_sapm"
        case fighterBKdAvg   = "fighter_b_kd_avg"
        case fighterBTdDef   = "fighter_b_td_def"
        case fighterRTdAvg   = "fighter_r_td_avg"
        case fighterRAvgFightTime = "fighter_r_avg_fight_time"
        case fighterBTdAvg   = "fighter_b_td_avg"
        case fighterBAvgFightTime = "fighter_b_avg_fight_time"
        case fighterRHeight    = "fighter_r_height"
        case fighterRReach     = "fighter_r_reach"
        case fighterRLegReach  = "fighter_r_leg_reach"
        case fighterRAge       = "fighter_r_age"
        case fighterRWeight    = "fighter_r_weight"
        case fighterRRank      = "fighter_r_rank"
        case fighterRElo       = "fighter_r_elo"
        case fighterBHeight    = "fighter_b_height"
        case fighterBReach     = "fighter_b_reach"
        case fighterBLegReach  = "fighter_b_leg_reach"
        case fighterBAge       = "fighter_b_age"
        case fighterBWeight    = "fighter_b_weight"
        case fighterBRank      = "fighter_b_rank"
        case fighterBElo       = "fighter_b_elo"
        case aiPrediction      = "ai_prediction"
    }
}
