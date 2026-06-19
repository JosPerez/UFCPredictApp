//
//  EloRankingsViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 14/06/26.
//
import Foundation
import Observation
import BlackSpartan
import SwiftData

@Observable
final class EloRankingsViewModel {

    var rankings: [CachedEloRanking] = []   // ← CachedEloRanking, no BSEloRanking
    var selectedDivision: String = "All"
    var isLoading = false
    
    private let service = BSRankingService(url: Config.baseURL)
    private var modelContext: ModelContext?
    private let cacheTTL: TimeInterval = 8 * 24 * 60 * 60
    
    let divisions: [String] = [
        "All",
        "Flyweight", "Bantamweight", "Featherweight", "Lightweight",
        "Welterweight", "Middleweight", "Light Heavyweight", "Heavyweight",
        "Women's Strawweight", "Women's Flyweight", "Women's Bantamweight"
    ]
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        service.delegate = self
    }

    func fetch() {
        if let cached = loadFromCache(division: selectedDivision), !cached.isEmpty {
            rankings = cached
            if let oldest = cached.map(\.lastUpdated).min(),
               Date().timeIntervalSince(oldest) > cacheTTL {
                fetchFromAPI()
            }
            return
        }
        fetchFromAPI()
    }

    func selectDivision(_ division: String) {
        selectedDivision = division
        fetch()
    }

    private func fetchFromAPI() {
        isLoading = true
        let wc = selectedDivision == "All" ? nil : selectedDivision
        service.getEloRankings(weightClass: wc, limit: 15)
    }

    // MARK: - Cache

    private func loadFromCache(division: String) -> [CachedEloRanking]? {
        guard let context = modelContext else { return nil }
        let predicate = #Predicate<CachedEloRanking> { $0.division == division }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.rank)]
        guard let results = try? context.fetch(descriptor), !results.isEmpty else {
            return nil
        }
        return results
    }

    private func saveToCache(_ rankings: [BSEloRanking]) {
        guard let context = modelContext else { return }
        let division = selectedDivision

        let predicate = #Predicate<CachedEloRanking> { $0.division == division }
        let descriptor = FetchDescriptor(predicate: predicate)
        if let existing = try? context.fetch(descriptor) {
            for item in existing { context.delete(item) }
        }

        var cached: [CachedEloRanking] = []
        for entry in rankings {
            let item = CachedEloRanking(
                fighterId: entry.fighterId,
                fighterName: entry.fighterName,
                weightClass: entry.weightClass,
                elo: entry.elo,
                rank: entry.rank,
                imgThumb: entry.imgThumb,
                record: entry.record,
                division: division
            )
            context.insert(item)
            cached.append(item)
        }

        try? context.save()
        self.rankings = cached  // ← actualiza con CachedEloRanking
    }
}

extension EloRankingsViewModel: BSResponseDelegate {
    func recievedEntity<T>(entity: T, requestName: String) {
        if let results = entity as? [BSEloRanking] {
            saveToCache(results)
            self.isLoading = false
        } else if entity is BSErrorBase {
            self.isLoading = false
        }
    }
}
