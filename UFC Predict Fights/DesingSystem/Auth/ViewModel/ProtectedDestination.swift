//
//  ProtectedDestination.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 15/06/26.
//

import Foundation

enum ProtectedDestination: Hashable {
    case fighterDetail(Int)
    case eventDetail(Int)
    case predict
}
