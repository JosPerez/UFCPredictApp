//
//  EventDetailViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import Observation
import BlackSpartan

@MainActor
@Observable
final class EventDetailViewModel {

    var event: BSEventDetail? = nil
    var isLoading: Bool = true
    var errorMessage: String? = nil

    private let api = GameAPIClient.shared
    private let eventId: Int

    init(eventId: Int) {
        self.eventId = eventId
        loadEvent()
    }

    func loadEvent() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                event = try await api.getEventDetail(id: eventId)
            } catch let error as GameAPIClient.APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Failed to load event details"
            }
            isLoading = false
        }
    }

    func retry() {
        loadEvent()
    }
}
