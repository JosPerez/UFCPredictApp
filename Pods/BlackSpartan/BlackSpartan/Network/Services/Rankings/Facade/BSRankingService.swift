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
        static let eloList = "getEloRankings"
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
    // Agregar este método
    public func getEloRankings(weightClass: String? = nil, limit: Int = 15) {
        var params: [String: String] = ["limit": "\(limit)"]
        if let wc = weightClass {
            params["weight_class"] = wc
        }
        let query = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = "/rankings/elo?\(query)"
        do {
            let request = try getRequest(uri: endpoint)
            connection.delegate = self
            connection.sendRequest(request: request, requestName: RequestName.eloList)
        } catch {
            recievedError(error: error, code: nil, requestName: RequestName.eloList)
        }
    }
}

extension BSRankingService: BSConnectionDelegate {
    public func recievedData(data: Data, requestName: String) {
        switch requestName {
        case RequestName.list:
            decodeEntity(responseType: [BSRankingDivision].self, data: data, requestName: requestName)
        case RequestName.eloList:
            decodeEntity(responseType: [BSEloRanking].self, data: data, requestName: requestName)
        default: break
        }
    }
}
