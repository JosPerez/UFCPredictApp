//
//  GameViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class GameViewModel {

    var events: [GameEventDTO] = []
    var isLoading = false
    var errorMessage: String? = nil

    private let api = GameAPIClient.shared

    // MARK: - Fetch Events

    func fetchEvents() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let listEvents = try await api.getGameEvents()
                events = listEvents.reversed()
            } catch let error as GameAPIClient.APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Failed to load events"
            }
            isLoading = false
        }
    }

    // MARK: - Computed

    var nextOpenEvent: GameEventDTO? {
        events.first(where: { $0.isOpen })
    }

    var recentScoredEvent: GameEventDTO? {
        events.first(where: { $0.isScored })
    }

    var openEvents: [GameEventDTO] {
        events.filter { $0.isOpen }
    }

    var pastEvents: [GameEventDTO] {
        events.filter { !$0.isOpen }
    }
}
