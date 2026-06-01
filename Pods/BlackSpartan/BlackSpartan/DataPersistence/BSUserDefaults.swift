//
//  BSUserDefaults.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation
final public class BSUserDefaultManager: NSObject {
    /// Instancia de User Default
    var userDefault: UserDefaults
    /// Inicializador del manager
    override public init() {
        if let user =  UserDefaults(suiteName: "UFCPredictAPP") {
            self.userDefault = user
        } else {
            self.userDefault = UserDefaults.standard
        }
    }
    /// Función que guarda la información
    /// - Parameters :
    ///   - key: LLave  con la que se guarda la información
    ///   - data: Información a guardar
    func storeData(key: BSUserDefaultKeys, data: Data) {
        userDefault.set(data, forKey: key.rawValue)
    }
    /// Función que obtiene la información
    /// - Parameters :
    ///   - key: LLave  con la que se guarda la información
    ///  - Returns:
    ///   - data: Información a guardar
    func getData(key: BSUserDefaultKeys) -> Data? {
        guard let data = userDefault.data(forKey: key.rawValue) else { return nil }
        return data
    }
    
}
public enum BSUserDefaultKeys: String {
    case unknown
}
