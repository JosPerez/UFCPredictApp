//
//  BSFighterService.swift
//  BlackSpartan
//
//  Created by Jose Perez on 31/05/26.
//

import Foundation

final class BSFighterService: BSBaseFacade {

    enum RequestName {
        static let list   = "getFighters"
        static let detail = "getFighterDetail"
    }

    func getFighters(weightClass: String? = nil, limit: Int = 20, offset: Int = 0) {
        var uri = "/fighters/?limit=\(limit)&offset=\(offset)"
        if let wc = weightClass { uri += "&weight_class=\(wc)" }
        do {
            let request = try getRequest(uri: uri)
            connection.delegate = self
            connection.sendRequest(request: request, requestName: RequestName.list)
        } catch {
            recievedError(error: error, code: nil, requestName: RequestName.list)
        }
    }

    func getFighterDetail(id: Int) {
        do {
            let request = try getRequest(uri: "/fighters/\(id)")
            connection.delegate = self
            connection.sendRequest(request: request, requestName: RequestName.detail)
        } catch {
            recievedError(error: error, code: nil, requestName: RequestName.detail)
        }
    }
}

extension BSFighterService: BSConnectionDelegate {
    func recievedData(data: Data, requestName: String) {
        switch requestName {
        case RequestName.list:
            decodeEntity(responseType: [Fighter].self, data: data, requestName: requestName)
        case RequestName.detail:
            decodeEntity(responseType: FighterDetail.self, data: data, requestName: requestName)
        default: break
        }
    }
}
