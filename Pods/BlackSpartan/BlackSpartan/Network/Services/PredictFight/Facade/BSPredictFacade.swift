//
//  BSPredictFacade.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation

final public class BSPredictService: BSBaseFacade {
    
    enum RequestName {
        static let predictFight   = "predcit"
    }
    
    public func predictFight(request: PredictionRequest) {
        let uri = "/predict/"
        do {
            let body = try JSONEncoder().encode(request)
            let request = try postRequest(uri: uri, body: body)
            connection.delegate = self
            connection.sendRequest(request: request, requestName: RequestName.predictFight)
        } catch let encodingError as EncodingError {
            switch encodingError {
            case .invalidValue(let value, let context):
                print("Invalid value: \(value)")
                print("Coding path: \(context.codingPath)")
                print("Description: \(context.debugDescription)")

            @unknown default:
                print("Unknown encoding error: \(encodingError)")
            }
        } catch {
            recievedError(error: error, code: nil, requestName: RequestName.predictFight)
        }
    }
}
extension BSPredictService: BSConnectionDelegate {
    public func recievedData(data: Data, requestName: String) {
        switch requestName {
        case RequestName.predictFight:
            decodeEntity(responseType: Prediction.self, data: data, requestName: requestName)
        default: break
        }
    }
}
