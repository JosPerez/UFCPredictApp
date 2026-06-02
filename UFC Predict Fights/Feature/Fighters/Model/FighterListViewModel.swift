//
//  FighterListViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class FighterListViewModel {

    // MARK: - State

    var fighters: [CachedFighter] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var fighterCount: Int = 0
    var searchText: String = "" {
        didSet { debounceSearch() }
    }
    var selectedWeightClass: String? = nil {
        didSet { reload() }
    }

    // Sync state (expuesto del SyncManager)
    var isSyncing: Bool { repository.syncManager.isSyncing }
    var syncProgress: String? { repository.syncManager.syncProgress }

    // MARK: - Pagination

    private var currentOffset: Int = 0
    private let pageSize: Int = 20
    var canLoadMore: Bool = true

    // MARK: - Dependencies

    private let repository: FighterRepository
    private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init(repository: FighterRepository) {
        self.repository = repository
        Task { await initialLoad() }
    }

    // MARK: - Initial load

    private func initialLoad() async {
        isLoading = true
        
        if repository.hasCachedData {
            loadFromCache()
            isLoading = false
            // Sync en background, recargar al terminar
            await repository.syncIfNeeded()
            loadFromCache()
        } else {
            // Lanzar sync sin awaitar el total
            Task { await repository.syncIfNeeded() }
            
            // Esperar a que el primer bloque llegue
            for _ in 0..<30 {  // máximo 15 segundos
                try? await Task.sleep(nanoseconds: 500_000_000)
                if repository.hasCachedData { break }
                if repository.syncManager.syncError != nil { break }
            }
            
            loadFromCache()
            isLoading = false
            
            // Seguir recargando mientras sync continúa
            while repository.syncManager.isSyncingFighters {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                loadFromCache()
            }
        }
    }

    // MARK: - Local queries

    func loadFromCache() {
        let results = repository.getFighters(
            weightClass: selectedWeightClass,
            query: searchText.isEmpty ? nil : searchText,
            limit: pageSize,
            offset: currentOffset
        )

        if currentOffset == 0 {
            fighters = results
        } else {
            fighters.append(contentsOf: results)
        }

        canLoadMore = results.count == pageSize
        fighterCount = repository.fighterCount(weightClass: selectedWeightClass)
    }

    // MARK: - Pagination

    func loadMore(currentItem: CachedFighter) {
        guard canLoadMore, !isLoading else { return }
        guard let index = fighters.firstIndex(where: { $0.fighterId == currentItem.fighterId }),
              index >= fighters.count - 3 else { return }
        currentOffset += pageSize
        loadFromCache()
    }

    // MARK: - Reload

    func reload() {
        currentOffset = 0
        canLoadMore = true
        fighters = []
        loadFromCache()
    }

    // MARK: - Pull to refresh

    func refresh() async {
        currentOffset = 0
        await repository.forceSync()
        loadFromCache()
    }

    // MARK: - Search

    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { reload() }
        }
    }

    // MARK: - Filter

    func selectWeightClass(_ wc: String?) {
        selectedWeightClass = wc
    }
}

