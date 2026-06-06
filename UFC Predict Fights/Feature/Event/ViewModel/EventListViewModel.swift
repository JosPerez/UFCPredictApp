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
    
    enum EventFilter: Equatable {
        case upcoming
        case completed
        case year(Int)
    }
    
    var events: [CachedEvent] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var eventCount: Int = 0
    var selectedFilter: EventFilter = .upcoming {
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
    
    var sortAscending: Bool = false {
        didSet { reload() }
    }

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
    
    func toggleSortOrder() {
        sortAscending.toggle()
    }

    func loadFromCache() {
        let query = searchText.isEmpty ? nil : searchText
        var results: [CachedEvent] = []

        switch selectedFilter {
        case .upcoming:
            if let q = query {
                let all = repository.getUpcomingEvents(ascending: true, limit: 100, offset: 0)
                results = Array(all.filter {
                    $0.name.localizedStandardContains(q)
                }.prefix(pageSize))
            } else {
                results = repository.getUpcomingEvents(
                    ascending: true,
                    limit: pageSize,
                    offset: currentOffset
                )
            }
        case .completed:
            results = repository.getCompletedEvents(
                query: query,
                ascending: sortAscending,
                limit: pageSize,
                offset: currentOffset
            )
        case .year(let year):
            results = repository.getCompletedEvents(
                year: year,
                query: query,
                ascending: sortAscending,
                limit: pageSize,
                offset: currentOffset
            )
        }

        if currentOffset == 0 {
            events = results
        } else {
            events.append(contentsOf: results)
        }

        canLoadMore = results.count == pageSize

        switch selectedFilter {
        case .upcoming: eventCount = repository.upcomingCount()
        case .completed: eventCount = repository.completedCount()
        case .year(let y): eventCount = repository.completedCount(year: y)
        }
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

    func selectFilter(_ filter: EventFilter) {
        selectedFilter = filter
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
