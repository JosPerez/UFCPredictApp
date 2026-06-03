//
//  EventListViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import Observation
import BlackSpartan

@MainActor
@Observable
final class EventListViewModel {

    var events: [CachedEvent] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var eventCount: Int = 0
    var selectedYear: Int? = nil {
        didSet { reload() }
    }

    var isSyncing: Bool { repository.syncManager.isSyncing }
    var syncProgress: String? { repository.syncManager.syncProgress }

    private var currentOffset: Int = 0
    private let pageSize: Int = 20
    var canLoadMore: Bool = true

    private let repository: EventRepository

    let years: [Int] = {
        let current = Calendar.current.component(.year, from: .now)
        return Array((current - 8)...current).reversed()
    }()
    
    var searchText: String = "" {
        didSet { debounceSearch() }
    }

    private var searchTask: Task<Void, Never>?

    init(repository: EventRepository) {
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

            while repository.syncManager.isSyncingEvents {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                loadFromCache()
            }
        }
    }

    func loadFromCache() {
        let results = repository.getEvents(
            year: selectedYear,
            query: searchText.isEmpty ? nil : searchText,
            limit: pageSize,
            offset: currentOffset
        )

        if currentOffset == 0 {
            events = results
        } else {
            events.append(contentsOf: results)
        }

        canLoadMore = results.count == pageSize
        eventCount = repository.eventCount(year: selectedYear)
    }

    func loadMore(currentItem: CachedEvent) {
        guard canLoadMore, !isLoading else { return }
        guard let index = events.firstIndex(where: { $0.eventId == currentItem.eventId }),
              index >= events.count - 3 else { return }
        currentOffset += pageSize
        loadFromCache()
    }

    func reload() {
        currentOffset = 0
        canLoadMore = true
        events = []
        loadFromCache()
    }

    func refresh() async {
        currentOffset = 0
        await repository.forceSync()
        loadFromCache()
    }

    func selectYear(_ year: Int?) {
        selectedYear = year
    }
    
    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { reload() }
        }
    }
}
