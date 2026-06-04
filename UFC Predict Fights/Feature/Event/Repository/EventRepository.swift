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

    func getEvents(year: Int? = nil, query: String? = nil, limit: Int = 20, offset: Int = 0) -> [CachedEvent] {
        var descriptor = FetchDescriptor<CachedEvent>(
            sortBy: [SortDescriptor(\.eventDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        if let y = year, let q = query, !q.isEmpty {
            let prefix = "\(y)-"
            descriptor.predicate = #Predicate {
                $0.eventDate.starts(with: prefix) &&
                $0.name.localizedStandardContains(q)
            }
        } else if let y = year {
            let prefix = "\(y)-"
            descriptor.predicate = #Predicate {
                $0.eventDate.starts(with: prefix)
            }
        } else if let q = query, !q.isEmpty {
            descriptor.predicate = #Predicate {
                $0.name.localizedStandardContains(q)
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
    
    // Agregar nuevo método
    func getUpcomingEvents(limit: Int = 20, offset: Int = 0) -> [CachedEvent] {
        var descriptor = FetchDescriptor<CachedEvent>(
            sortBy: [SortDescriptor(\.eventDate)]  // ascendente — próximo primero
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        descriptor.predicate = #Predicate {
            $0.isUpcoming == true
        }

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("[EventRepository] upcoming fetch error: \(error)")
            return []
        }
    }

    func upcomingCount() -> Int {
        var descriptor = FetchDescriptor<CachedEvent>(
            predicate: #Predicate { $0.isUpcoming == true }
        )
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
