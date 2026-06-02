//
//  CachedEvent.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import SwiftData
import BlackSpartan

@Model
final class CachedEvent {
    @Attribute(.unique) var eventId: Int

    var name: String
    var eventDate: String
    var fightCount: Int
    var titleFights: Int
    var cachedAt: Date

    // Computed: extraer año del date string para filtros
    var year: Int {
        let parts = eventDate.split(separator: "-")
        return Int(parts.first ?? "0") ?? 0
    }

    init(
        eventId: Int,
        name: String,
        eventDate: String,
        fightCount: Int,
        titleFights: Int,
        cachedAt: Date = .now
    ) {
        self.eventId = eventId
        self.name = name
        self.eventDate = eventDate
        self.fightCount = fightCount
        self.titleFights = titleFights
        self.cachedAt = cachedAt
    }

    convenience init(from remote: BSEvent) {
        self.init(
            eventId:    remote.id,
            name:       remote.name,
            eventDate:  remote.eventDate,
            fightCount: remote.fightCount,
            titleFights: remote.titleFights
        )
    }

    func update(from remote: BSEvent) {
        self.name       = remote.name
        self.eventDate  = remote.eventDate
        self.fightCount = remote.fightCount
        self.cachedAt   = .now
    }
}
