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

    private let service = BSEventService(url: Config.baseURL)

    init(eventId: Int) {
        setupService()
        service.getEventDetail(id: eventId)
    }

    private func setupService() {
        service.delegate = self
    }

    func retry(eventId: Int) {
        isLoading = true
        errorMessage = nil
        service.getEventDetail(id: eventId)
    }
}

extension EventDetailViewModel: BSResponseDelegate {
    enum RequestName: String {
        case detail = "getEventDetail"
    }

    func recievedEntity<T>(entity: T, requestName: String) {
        switch RequestName(rawValue: requestName) {
        case .detail:
            if let response = entity as? BSEventDetail {
                self.event = response
                self.isLoading = false
            } else if let error = entity as? BSErrorBase {
                self.errorMessage = error.message
                self.isLoading = false
            }
        default: break
        }
    }
}
