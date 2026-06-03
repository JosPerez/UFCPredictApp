//
//  AppCoordinator.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AppCoordinator {

    var selectedTab: Int = 0

    // Referencia al PredictionViewModel compartido
    var predictionViewModel: PredictionViewModel?

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext, predictionViewModel: PredictionViewModel) {
        self.modelContext = modelContext
        self.predictionViewModel = predictionViewModel
    }

    /// Desde FighterDetailView → Predict tab con Fighter A pre-cargado
    func predictWithFighter(id: Int) {
        guard let fighter = lookupFighter(id: id) else { return }
        predictionViewModel?.reset()
        predictionViewModel?.selectFighterA(fighter)
        selectedTab = 2
    }

    /// Desde EventDetailView → Predict tab con ambos fighters
    func predictRematch(fighterAId: Int, fighterBId: Int) {
        guard let a = lookupFighter(id: fighterAId),
              let b = lookupFighter(id: fighterBId) else { return }
        predictionViewModel?.reset()
        predictionViewModel?.selectFighterA(a)
        predictionViewModel?.selectFighterB(b)
        selectedTab = 2
    }

    private func lookupFighter(id: Int) -> CachedFighter? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<CachedFighter>(
            predicate: #Predicate { $0.fighterId == id }
        )
        return try? context.fetch(descriptor).first
    }
}
