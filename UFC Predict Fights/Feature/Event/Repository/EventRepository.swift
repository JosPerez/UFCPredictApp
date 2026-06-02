//
//  EventRepository.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import SwiftData
import BlackSpartan

@MainActor
@Observable
final class EventRepository {

    private let modelContext: ModelContext
    let syncManager: SyncManager

    init(modelContext: ModelContext, syncManager: SyncManager) {
        self.modelContext = modelContext
        self.syncManager = syncManager
    }

    // MARK: - Sync

    func syncIfNeeded() async {
        await syncManager.syncEventsIfNeeded()
    }

    func forceSync() async {
        await syncManager.forceSyncEvents()
    }

    // MARK: - Local queries

    func getEvents(year: Int? = nil, limit: Int = 20, offset: Int = 0) -> [CachedEvent] {
        var descriptor = FetchDescriptor<CachedEvent>(
            sortBy: [SortDescriptor(\.eventDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        if let y = year {
            let prefix = "\(y)-"
            descriptor.predicate = #Predicate {
                $0.eventDate.starts(with: prefix)
            }
        }

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("[EventRepository] fetch error: \(error)")
            return []
        }
    }

    func eventCount(year: Int? = nil) -> Int {
        var descriptor = FetchDescriptor<CachedEvent>()
        if let y = year {
            let prefix = "\(y)-"
            descriptor.predicate = #Predicate {
                $0.eventDate.starts(with: prefix)
            }
        }
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            return 0
        }
    }

    var hasCachedData: Bool {
        eventCount() > 0
    }
}
