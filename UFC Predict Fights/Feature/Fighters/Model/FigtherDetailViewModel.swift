//
//  FighterDetailViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import Foundation
import Observation
import BlackSpartan

@MainActor
@Observable
final class FighterDetailViewModel {

    var profile: BSFighterProfile? = nil
    var isLoading: Bool = true
    var errorMessage: String? = nil

    private let api = GameAPIClient.shared
    private let fighterId: Int

    init(fighterId: Int) {
        self.fighterId = fighterId
        loadProfile()
    }

    func loadProfile() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                profile = try await api.getFighterProfile(id: fighterId)
            } catch let error as GameAPIClient.APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Failed to load fighter profile"
            }
            isLoading = false
        }
    }

    func retry() {
        loadProfile()
    }
}
