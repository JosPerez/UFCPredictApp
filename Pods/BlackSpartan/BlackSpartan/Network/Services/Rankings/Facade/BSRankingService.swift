//
//  BSRankingService.swift
//  BlackSpartan
//
//  Created by Jose Perez on 05/06/26.
//


import Foundation

final public class BSRankingService: BSBaseFacade {

    enum RequestName {
        static let list = "getRankings"
    }

    public func getRankings(weightClass: String? = nil) {
        var uri = "/rankings/"
        if let wc = weightClass {
            uri += "?weight_class=\(wc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? wc)"
        }
        do {
            let request = try getRequest(uri: uri)
            connection.delegate = self
            connection.sendRequest(request: request, requestName: RequestName.list)
        } catch {
            recievedError(error: error, code: nil, requestName: RequestName.list)
        }
    }
}

extension BSRankingService: BSConnectionDelegate {
    public func recievedData(data: Data, requestName: String) {
        switch requestName {
        case RequestName.list:
            decodeEntity(responseType: [BSRankingDivision].self, data: data, requestName: requestName)
        default: break
        }
    }
}
