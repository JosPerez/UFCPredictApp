//
//  RankingsViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 05/06/26.
//

import Foundation
import Observation
import BlackSpartan

@MainActor
@Observable
final class RankingsViewModel {

    var rankings: [CachedRanking] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var selectedDivision: String? = nil

    var isSyncing: Bool { repository.syncManager.isSyncingRankings }

    private let divisionOrder: [String] = [
        "Flyweight", "Bantamweight", "Featherweight", "Lightweight",
        "Welterweight", "Middleweight", "Light Heavyweight", "Heavyweight",
        "Women's Strawweight", "Women's Flyweight", "Women's Bantamweight",
    ]

    var divisionNames: [String] {
        let available = repository.getDivisions()
        return divisionOrder.filter { available.contains($0) }
    }

    struct DivisionGroup: Identifiable {
        let weightClass: String
        let champion: CachedRanking?
        let ranked: [CachedRanking]
        var id: String { weightClass }
    }

    var groupedDivisions: [DivisionGroup] {
        let filtered: [CachedRanking]
        if let selected = selectedDivision {
            filtered = rankings.filter { $0.weightClass == selected }
        } else {
            filtered = rankings
        }

        let grouped = Dictionary(grouping: filtered) { $0.weightClass }

        return divisionOrder.compactMap { wc in
            guard let fighters = grouped[wc] else { return nil }
            let champion = fighters.first { $0.isChampion }
            let ranked = fighters.filter { !$0.isChampion }.sorted { $0.rank < $1.rank }
            return DivisionGroup(weightClass: wc, champion: champion, ranked: ranked)
        }
    }

    private let repository: RankingRepository

    init(repository: RankingRepository) {
        self.repository = repository
        Task { await initialLoad() }
    }

    private func initialLoad() async {
        isLoading = true

        if repository.hasCachedData {
            loadFromCache()
            isLoading = false
            await repository.syncIfNeeded()
            loadFromCache()
        } else {
            Task { await repository.syncIfNeeded() }
            for _ in 0..<30 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if repository.hasCachedData { break }
                if repository.syncManager.syncError != nil { break }
            }
            loadFromCache()
            isLoading = false
        }
    }

    func loadFromCache() {
        rankings = repository.getRankings()
    }

    func refresh() async {
        await repository.forceSync()
        loadFromCache()
    }

    func selectDivision(_ division: String?) {
        selectedDivision = division
    }
}
