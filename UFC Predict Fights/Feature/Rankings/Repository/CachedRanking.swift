//
//  CachedRanking.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 05/06/26.
//

import Foundation
import SwiftData
import BlackSpartan

@Model
final class CachedRanking {
    @Attribute(.unique) var compositeKey: String  // weightClass::rank

    var weightClass: String
    var rank: Int
    var fighterId: Int
    var firstName: String
    var lastName: String
    var nickname: String?
    var imgThumb: String?
    var recordWin: Int
    var recordLoss: Int
    var recordDraw: Int
    var cachedAt: Date

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }
    var isChampion: Bool { rank == 0 }

    init(
        weightClass: String,
        rank: Int,
        fighterId: Int,
        firstName: String,
        lastName: String,
        nickname: String? = nil,
        imgThumb: String? = nil,
        recordWin: Int = 0,
        recordLoss: Int = 0,
        recordDraw: Int = 0,
        cachedAt: Date = .now
    ) {
        self.compositeKey = "\(weightClass)::\(rank)"
        self.weightClass = weightClass
        self.rank = rank
        self.fighterId = fighterId
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.imgThumb = imgThumb
        self.recordWin = recordWin
        self.recordLoss = recordLoss
        self.recordDraw = recordDraw
        self.cachedAt = cachedAt
    }

    static func fromRemote(division: BSRankingDivision) -> [CachedRanking] {
        division.fighters.map { fighter in
            CachedRanking(
                weightClass: division.weightClass,
                rank:        fighter.rank,
                fighterId:   fighter.fighterId,
                firstName:   fighter.firstName,
                lastName:    fighter.lastName,
                nickname:    fighter.nickname,
                imgThumb:    fighter.imgThumb,
                recordWin:   fighter.recordWin,
                recordLoss:  fighter.recordLoss,
                recordDraw:  fighter.recordDraw
            )
        }
    }
}
