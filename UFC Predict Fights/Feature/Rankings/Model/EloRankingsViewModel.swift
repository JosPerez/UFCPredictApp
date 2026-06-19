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
            // Refresh if expired
            if isCacheExpired() {
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
    
    private func isCacheExpired() -> Bool {
        guard let context = modelContext else { return true }
        let division = selectedDivision
        let predicate = #Predicate<CachedEloRanking> { $0.division == division }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.lastUpdated, order: .reverse)]
        descriptor.fetchLimit = 1
        
        guard let latest = try? context.fetch(descriptor).first else { return true }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: latest.lastUpdated)
        components.weekday = 1
        components.hour = 6
        components.minute = 0
        guard let nextSunday = calendar.date(from: components) else { return true }
        
        let expiry = nextSunday <= latest.lastUpdated
        ? calendar.date(byAdding: .weekOfYear, value: 1, to: nextSunday) ?? latest.lastUpdated
        : nextSunday
        
        return Date() >= expiry
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
