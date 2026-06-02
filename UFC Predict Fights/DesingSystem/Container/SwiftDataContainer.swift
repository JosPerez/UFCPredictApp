//
//  SwiftDataContainer.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation
import SwiftData

struct SwiftDataContainer {

    /// Modelos registrados en el schema
    private static let models: [any PersistentModel.Type] = [
        CachedFighter.self,
        CachedEvent.self,
        // CachedFight.self,
    ]
    
    

    /// Crea el ModelContainer con configuración de producción
    static func create() throws -> ModelContainer {
        let schema = Schema(models)
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Container para previews y testing
    static func preview() throws -> ModelContainer {
        let schema = Schema(models)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
