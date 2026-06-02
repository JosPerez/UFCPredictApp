//
//  Config.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 01/06/26.
//

import Foundation

// Config.swift
enum Config {
    #if DEBUG
    static let baseURL = "http://127.0.0.1:8000"  // tu IP local
    #else
    static let baseURL = "https://ufc-predictor-production-a513.up.railway.app"
    #endif
}
