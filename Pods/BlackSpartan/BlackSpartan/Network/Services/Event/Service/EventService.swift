//
//  EventService.swift
//  BlackSpartan
//
//  Created by Jose Perez on 02/06/26.
//

import Foundation

final public class BSEventService: BSBaseFacade {

    enum RequestName {
        static let list   = "getEvents"
        static let detail = "getEventDetail"
    }

    public func getEvents(year: Int? = nil, limit: Int = 20, offset: Int = 0) {
        var uri = "/events/?limit=\(limit)&offset=\(offset)"
        if let y = year { uri += "&year=\(y)" }
        do {
            let request = try getRequest(uri: uri)
            connection.delegate = self
            connection.sendRequest(request: request, requestName: RequestName.list)
        } catch {
            recievedError(error: error, code: nil, requestName: RequestName.list)
        }
    }

    public func getEventDetail(id: Int) {
        do {
            let request = try getRequest(uri: "/events/\(id)")
            connection.delegate = self
            connection.sendRequest(request: request, requestName: RequestName.detail)
        } catch {
            recievedError(error: error, code: nil, requestName: RequestName.detail)
        }
    }
}

extension BSEventService: BSConnectionDelegate {
    public func recievedData(data: Data, requestName: String) {
        switch requestName {
        case RequestName.list:
            decodeEntity(responseType: [BSEvent].self, data: data, requestName: requestName)
        case RequestName.detail:
            decodeEntity(responseType: BSEventDetail.self, data: data, requestName: requestName)
        default: break
        }
    }
}
