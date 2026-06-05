//
//  CachedFighter.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import SwiftData
import BlackSpartan

@Model
final class CachedFighter {
    // Identificador
    @Attribute(.unique) var fighterId: Int

    // Bio
    var firstName: String
    var lastName: String
    var nickname: String?
    var weightClass: String?
    var gender: String?
    var imgThumb: String?
    var isActive: Bool

    // Récord
    var recordWin: Int
    var recordLoss: Int
    var recordDraw: Int
    
    // Rankings
    var currentRank: Int?

    // Cache metadata
    var cachedAt: Date

    // Computed
    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }
    var winRate: Double {
        let total = recordWin + recordLoss
        guard total > 0 else { return 0 }
        return Double(recordWin) / Double(total)
    }

    init(
        fighterId: Int,
        firstName: String,
        lastName: String,
        nickname: String? = nil,
        weightClass: String? = nil,
        gender: String? = nil,
        imgThumb: String? = nil,
        isActive: Bool = true,
        recordWin: Int = 0,
        recordLoss: Int = 0,
        recordDraw: Int = 0,
        currentRank: Int? = nil,
        cachedAt: Date = .now
    ) {
        self.fighterId = fighterId
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.weightClass = weightClass
        self.gender = gender
        self.imgThumb = imgThumb
        self.isActive = isActive
        self.recordWin = recordWin
        self.recordLoss = recordLoss
        self.recordDraw = recordDraw
        self.currentRank = currentRank
        self.cachedAt = cachedAt
    }

    /// Crea CachedFighter desde la respuesta de red BSFighter
    convenience init(from remote: BSFighter) {
        self.init(
            fighterId:   remote.id,
            firstName:   remote.firstName,
            lastName:    remote.lastName,
            nickname:    remote.nickname,
            weightClass: remote.weightClass,
            gender:      remote.gender,
            imgThumb:    remote.imgThumb,
            isActive:    remote.isActive,
            recordWin:   remote.recordWin,
            recordLoss:  remote.recordLoss,
            recordDraw:  remote.recordDraw,
            currentRank: remote.currentRank
        )
    }

    /// Actualiza campos desde la respuesta remota sin recrear el objeto
    func update(from remote: BSFighter) {
        self.firstName   = remote.firstName
        self.lastName    = remote.lastName
        self.nickname    = remote.nickname
        self.weightClass = remote.weightClass
        self.gender      = remote.gender
        self.imgThumb    = remote.imgThumb
        self.isActive    = remote.isActive
        self.recordWin   = remote.recordWin
        self.recordLoss  = remote.recordLoss
        self.recordDraw  = remote.recordDraw
        self.currentRank = remote.currentRank
        self.cachedAt    = .now
    }
}
