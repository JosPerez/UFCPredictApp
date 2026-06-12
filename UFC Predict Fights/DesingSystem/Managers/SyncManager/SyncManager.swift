//
//  SyncManager.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

//  Orquesta la sincronización de fighters con TTL de 8 días
//  y descarga en bloques de 200 con jitter.

import Foundation
import SwiftData
import BlackSpartan

@MainActor
@Observable
final class SyncManager {

    // MARK: - State

    var isSyncingFighters: Bool = false
    var isSyncingEvents: Bool = false
    var isSyncingRankings: Bool = false
    var isSyncing: Bool { isSyncingFighters || isSyncingEvents }
    var syncProgress: String? = nil
    var syncError: String? = nil

    // MARK: - Config

    private let ttlDays: Int = 8
    private let blockSize: Int = 100
    private let baseDelay: Double = 1.5
    private let maxJitter: Double = 1.0

    // MARK: - Dependencies

    private let fighterService: BSFighterService
    private let eventService: BSEventService
    private let rankingService: BSRankingService
    private let modelContext: ModelContext

    // MARK: - Internal state

    private var fighterContinuation: CheckedContinuation<[BSFighter], Error>?
    private var eventContinuation: CheckedContinuation<[BSEvent], Error>?
    private var rankingContinuation: CheckedContinuation<[BSRankingDivision], Error>?
    private var activeRequestType: String? = nil

    // MARK: - UserDefaults keys

    private enum Keys {
        static let lastFighterSyncAt = "sync_fighters_last_at"
        static let lastEventSyncAt   = "sync_events_last_at"
        static let lastRankingSyncAt  = "sync_rankings_last_at"
    }

    // MARK: - Init

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.fighterService = BSFighterService(url: Config.baseURL)
        self.eventService = BSEventService(url: Config.baseURL)
        self.rankingService = BSRankingService(url: Config.baseURL)
    }

    // MARK: - Public API: Fighters

    func syncFightersIfNeeded() async {
        guard !isSyncingFighters else { return }
        guard isSyncRequired(key: Keys.lastFighterSyncAt) else { return }
        await syncAllFighters()
    }

    func forceSyncFighters() async {
        guard !isSyncingFighters else { return }
        await syncAllFighters()
    }

    // MARK: - Public API: Events

    func syncEventsIfNeeded() async {
        guard !isSyncingEvents else { return }
        guard isSyncRequired(key: Keys.lastEventSyncAt) else { return }
        await syncAllEvents()
    }

    func forceSyncEvents() async {
        guard !isSyncingEvents else { return }
        await syncAllEvents()
    }

    // MARK: - TTL Check

    private func isSyncRequired(key: String) -> Bool {
        guard let lastSync = UserDefaults.standard.object(forKey: key) as? Date else {
            return true
        }
        let daysSinceSync = Calendar.current.dateComponents(
            [.day], from: lastSync, to: .now
        ).day ?? 0
        return daysSinceSync >= ttlDays
    }

    // MARK: - Fighters Sync

    private func syncAllFighters() async {
        isSyncingFighters = true
        syncError = nil
        var currentOffset = 0
        var totalLoaded = 0

        do {
            var hasMore = true
            while hasMore {
                syncProgress = totalLoaded == 0
                    ? "Loading fighters..."
                    : "Updating \(totalLoaded) fighters..."

                let fighters = try await fetchFighterBlock(offset: currentOffset)
                saveFightersToCache(fighters)

                totalLoaded += fighters.count
                currentOffset += blockSize
                hasMore = fighters.count == blockSize

                if hasMore {
                    let delay = baseDelay + Double.random(in: 0...maxJitter)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }

            UserDefaults.standard.set(Date.now, forKey: Keys.lastFighterSyncAt)
            syncProgress = nil
            isSyncingFighters = false
        } catch {
            syncError = error.localizedDescription
            syncProgress = nil
            isSyncingFighters = false
        }
    }

    private func fetchFighterBlock(offset: Int) async throws -> [BSFighter] {
        return try await withCheckedThrowingContinuation { continuation in
            self.fighterContinuation = continuation
            self.activeRequestType = "fighters"
            self.fighterService.delegate = self
            self.fighterService.getFighters(limit: blockSize, offset: offset)
        }
    }

    private func saveFightersToCache(_ fighters: [BSFighter]) {
        for remote in fighters {
            let fid = remote.id
            let descriptor = FetchDescriptor<CachedFighter>(
                predicate: #Predicate { $0.fighterId == fid }
            )
            if let existing = try? modelContext.fetch(descriptor).first {
                existing.update(from: remote)
            } else {
                modelContext.insert(CachedFighter(from: remote))
            }
        }
        try? modelContext.save()
    }

    // MARK: - Events Sync

    private func syncAllEvents() async {
        isSyncingEvents = true
        syncError = nil
        var currentOffset = 0
        var totalLoaded = 0

        do {
            var hasMore = true
            while hasMore {
                syncProgress = totalLoaded == 0
                    ? "Loading events..."
                    : "Updating \(totalLoaded) events..."

                let events = try await fetchEventBlock(offset: currentOffset)
                saveEventsToCache(events)

                totalLoaded += events.count
                currentOffset += blockSize
                hasMore = events.count == blockSize

                if hasMore {
                    let delay = baseDelay + Double.random(in: 0...maxJitter)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }

            UserDefaults.standard.set(Date.now, forKey: Keys.lastEventSyncAt)
            syncProgress = nil
            isSyncingEvents = false
        } catch {
            syncError = error.localizedDescription
            syncProgress = nil
            isSyncingEvents = false
        }
    }

    private func fetchEventBlock(offset: Int) async throws -> [BSEvent] {
        return try await withCheckedThrowingContinuation { continuation in
            self.eventContinuation = continuation
            self.activeRequestType = "events"
            self.eventService.delegate = self
            self.eventService.getEvents(limit: blockSize, offset: offset)
        }
    }

    private func saveEventsToCache(_ events: [BSEvent]) {
        for remote in events {
            let eid = remote.id
            let descriptor = FetchDescriptor<CachedEvent>(
                predicate: #Predicate { $0.eventId == eid }
            )
            if let existing = try? modelContext.fetch(descriptor).first {
                existing.update(from: remote)
            } else {
                modelContext.insert(CachedEvent(from: remote))
            }
        }
        try? modelContext.save()
    }
    
    // MARK: - Rankings Sync

    private func syncAllRankings() async {
        isSyncingRankings = true
        syncError = nil
        syncProgress = "Loading rankings..."

        do {
            let divisions = try await fetchRankings()
            saveRankingsToCache(divisions)
            UserDefaults.standard.set(Date.now, forKey: Keys.lastRankingSyncAt)
            syncProgress = nil
            isSyncingRankings = false
        } catch {
            syncError = error.localizedDescription
            syncProgress = nil
            isSyncingRankings = false
        }
    }

    private func fetchRankings() async throws -> [BSRankingDivision] {
        return try await withCheckedThrowingContinuation { continuation in
            self.rankingContinuation = continuation
            self.activeRequestType = "rankings"
            self.rankingService.delegate = self
            self.rankingService.getRankings()
        }
    }

    private func saveRankingsToCache(_ divisions: [BSRankingDivision]) {
        // Borrar rankings anteriores
        let oldDescriptor = FetchDescriptor<CachedRanking>()
        if let old = try? modelContext.fetch(oldDescriptor) {
            for item in old {
                modelContext.delete(item)
            }
        }

        // Insertar nuevos
        for division in divisions {
            let entries = CachedRanking.fromRemote(division: division)
            for entry in entries {
                modelContext.insert(entry)
            }
        }
        try? modelContext.save()
    }
    
    // MARK: - Public API: Rankings

    func syncRankingsIfNeeded() async {
        guard !isSyncingRankings else { return }
        guard isSyncRequired(key: Keys.lastRankingSyncAt) else { return }
        await syncAllRankings()
    }

    func forceSyncRankings() async {
        guard !isSyncingRankings else { return }
        await syncAllRankings()
    }
}

// MARK: - BSResponseDelegate

extension SyncManager: @MainActor BSResponseDelegate {
    func recievedEntity<T>(entity: T, requestName: String) {
        switch activeRequestType {
        case "fighters":
            if let fighters = entity as? [BSFighter] {
                fighterContinuation?.resume(returning: fighters)
                fighterContinuation = nil
            } else if let error = entity as? BSErrorBase {
                fighterContinuation?.resume(throwing: error)
                fighterContinuation = nil
            }
        case "events":
            if let events = entity as? [BSEvent] {
                eventContinuation?.resume(returning: events)
                eventContinuation = nil
            } else if let error = entity as? BSErrorBase {
                eventContinuation?.resume(throwing: error)
                eventContinuation = nil
            }
        case "rankings":
            if let divisions = entity as? [BSRankingDivision] {
                rankingContinuation?.resume(returning: divisions)
                rankingContinuation = nil
            } else if let error = entity as? BSErrorBase {
                rankingContinuation?.resume(throwing: error)
                rankingContinuation = nil
            }
        default:
            break
        }
        activeRequestType = nil
    }
}
