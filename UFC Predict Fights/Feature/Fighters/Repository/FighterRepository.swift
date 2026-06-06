//
//  FighterRepository.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

//  Capa de acceso a datos de fighters.
//  Los ViewModels solo hablan con el Repository, nunca con servicios directamente.

import Foundation
import SwiftData
import BlackSpartan

@MainActor
@Observable
final class FighterRepository {

    // MARK: - Dependencies

    private let modelContext: ModelContext
    let syncManager: SyncManager

    // MARK: - Init

    init(modelContext: ModelContext, syncManager: SyncManager) {
        self.modelContext = modelContext
        self.syncManager = syncManager
    }

    // MARK: - Sync

    /// Sincroniza fighters si el TTL expiró
    func syncIfNeeded() async {
        await syncManager.syncFightersIfNeeded()
    }

    /// Fuerza sincronización (pull-to-refresh)
    func forceSync() async {
        await syncManager.forceSyncFighters()
    }

    // MARK: - Fighters list (local)

    /// Retorna fighters filtrados desde cache local
    func getFighters(
        weightClass: String? = nil,
        query: String? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) -> [CachedFighter] {
        var descriptor = FetchDescriptor<CachedFighter>(
            sortBy: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        // Construir predicate dinámicamente
        if let wc = weightClass, let q = query, !q.isEmpty {
            descriptor.predicate = #Predicate {
                $0.isActive == true &&
                $0.weightClass == wc &&
                ($0.firstName.localizedStandardContains(q) ||
                 $0.lastName.localizedStandardContains(q))
            }
        } else if let wc = weightClass {
            descriptor.predicate = #Predicate {
                $0.isActive == true &&
                $0.weightClass == wc
            }
        } else if let q = query, !q.isEmpty {
            descriptor.predicate = #Predicate {
                $0.isActive == true &&
                ($0.firstName.localizedStandardContains(q) ||
                 $0.lastName.localizedStandardContains(q))
            }
        } else {
            descriptor.predicate = #Predicate {
                $0.isActive == true
            }
        }

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("[FighterRepository] fetch error: \(error)")
            return []
        }
    }

    /// Total de fighters en cache (para mostrar conteo)
    func fighterCount(weightClass: String? = nil) -> Int {
        var descriptor = FetchDescriptor<CachedFighter>()

        if let wc = weightClass {
            descriptor.predicate = #Predicate {
                $0.isActive == true && $0.weightClass == wc
            }
        } else {
            descriptor.predicate = #Predicate {
                $0.isActive == true
            }
        }

        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            return 0
        }
    }

    /// Busca un fighter por ID en cache local
    func getCachedFighter(id: Int) -> CachedFighter? {
        let descriptor = FetchDescriptor<CachedFighter>(
            predicate: #Predicate { $0.fighterId == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    // MARK: - Division averages (local)

    /// Calcula promedios de la división desde el cache local
    func divisionAverages(weightClass: String) -> DivisionAverages {
        let descriptor = FetchDescriptor<CachedFighter>(
            predicate: #Predicate {
                $0.isActive == true && $0.weightClass == weightClass
            }
        )

        guard let fighters = try? modelContext.fetch(descriptor),
              !fighters.isEmpty else {
            return DivisionAverages.empty
        }

        let totalWins   = fighters.reduce(0) { $0 + $1.recordWin }
        let totalLosses = fighters.reduce(0) { $0 + $1.recordLoss }
        let totalFights = totalWins + totalLosses

        return DivisionAverages(
            fighterCount: fighters.count,
            avgWinRate: totalFights > 0
                ? Double(totalWins) / Double(totalFights)
                : 0
        )
    }

    // MARK: - Cache status

    /// Indica si hay datos en cache
    var hasCachedData: Bool {
        fighterCount() > 0
    }
}

// MARK: - Division averages model

struct DivisionAverages {
    let fighterCount: Int
    let avgWinRate: Double

    static let empty = DivisionAverages(fighterCount: 0, avgWinRate: 0)
}
