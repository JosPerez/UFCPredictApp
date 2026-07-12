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
    static let baseURL = "http://192.168.2.98:8000"  // tu IP local
    #else
    static let baseURL = "https://ufc-predictor-production-a513.up.railway.app"
    #endif
    
    /// Lee del Info.plist (que a su vez viene del xcconfig no versionado `Secrets.xcconfig`).
    /// Si falta la key es un fallo de configuración, no de runtime — crashea explícito.
    static let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String,
              !key.isEmpty else {
            fatalError("API_KEY missing — check Secrets.xcconfig and Info.plist")
        }
        return key
    }()

    static let privacyPolicyURL = "\(baseURL)/legal/privacy"
    static let termsOfServiceURL = "\(baseURL)/legal/terms"
}
