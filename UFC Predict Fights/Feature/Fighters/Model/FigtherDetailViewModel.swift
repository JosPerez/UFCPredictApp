//
//  FighterDetailViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import Foundation
import Observation
import BlackSpartan

@Observable
final class FighterDetailViewModel {

    var profile: BSFighterProfile? = nil
    var isLoading: Bool = true
    var errorMessage: String? = nil

    private let service = BSFighterService(url: Config.baseURL)

    init(fighterId: Int) {
        setupService()
        service.getFighterProfile(id: fighterId)
    }

    private func setupService() {
        service.delegate = self
    }

    func retry(fighterId: Int) {
        isLoading = true
        errorMessage = nil
        service.getFighterProfile(id: fighterId)
    }
}

extension FighterDetailViewModel: BSResponseDelegate {
    enum RequestName: String {
        case profile = "getFighterProfile"
    }

    func recievedEntity<T>(entity: T, requestName: String) {
        switch RequestName(rawValue: requestName) {
        case .profile:
            if let response = entity as? BSFighterProfile {
                self.profile = response
                self.isLoading = false
            } else if let error = entity as? BSErrorBase {
                self.errorMessage = error.message
                self.isLoading = false
            }
        default: break
        }
    }
}
