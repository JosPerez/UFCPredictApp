//
//  RankingRepository.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 05/06/26.
//

import Foundation
import SwiftData
import BlackSpartan

@MainActor
@Observable
final class RankingRepository {

    private let modelContext: ModelContext
    let syncManager: SyncManager

    init(modelContext: ModelContext, syncManager: SyncManager) {
        self.modelContext = modelContext
        self.syncManager = syncManager
    }

    func syncIfNeeded() async {
        await syncManager.syncRankingsIfNeeded()
    }

    func forceSync() async {
        await syncManager.forceSyncRankings()
    }

    func getDivisions() -> [String] {
        let descriptor = FetchDescriptor<CachedRanking>(
            sortBy: [SortDescriptor(\.weightClass)]
        )
        guard let all = try? modelContext.fetch(descriptor) else { return [] }

        var seen = Set<String>()
        var result: [String] = []
        for r in all {
            if !seen.contains(r.weightClass) {
                seen.insert(r.weightClass)
                result.append(r.weightClass)
            }
        }
        return result
    }

    func getRankings(weightClass: String? = nil) -> [CachedRanking] {
        var descriptor = FetchDescriptor<CachedRanking>(
            sortBy: [SortDescriptor(\.weightClass), SortDescriptor(\.rank)]
        )

        if let wc = weightClass {
            descriptor.predicate = #Predicate { $0.weightClass == wc }
        }

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var hasCachedData: Bool {
        let descriptor = FetchDescriptor<CachedRanking>()
        return ((try? modelContext.fetchCount(descriptor)) ?? 0) > 0
    }
}
