//
//  GameAPIClient.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import Foundation
import FirebaseAuth

final class GameAPIClient {

    static let shared = GameAPIClient()
    private init() {}

    private let baseURL = Config.baseURL

    enum APIError: LocalizedError {
        case unauthorized
        case forbidden(String)
        case notFound
        case validationError(String)
        case networkError
        case serverError(Int)

        var errorDescription: String? {
            switch self {
            case .unauthorized:          return "Session expired. Please sign in again."
            case .forbidden(let msg):    return msg
            case .notFound:              return "Not found"
            case .validationError(let m): return m
            case .networkError:          return "Network error. Check your connection."
            case .serverError(let code): return "Server error (\(code))"
            }
        }
    }

    // MARK: - Token

    private func getToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw APIError.unauthorized
        }
        return try await user.getIDToken()
    }

    // MARK: - Request Builder

    private func request(_ endpoint: String, method: String = "GET", body: Encodable? = nil) async throws -> Data {
        let token = try await getToken()
        let url = URL(string: "\(baseURL)\(endpoint)")!

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(Config.apiKey, forHTTPHeaderField: "X-API-Key")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            req.httpBody = try encoder.encode(body)
        }
        // LOG api request
        GameLogger.apiRequest(method, endpoint)
        // Send api request
        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        GameLogger.apiResponse(endpoint, status: http.statusCode)
        switch http.statusCode {
        case 200..<300:
            return data
        case 401:
            throw APIError.unauthorized
        case 403:
            let detail = parseDetail(data)
            throw APIError.forbidden(detail)
        case 404:
            throw APIError.notFound
        case 409:
            let detail = parseDetail(data)
            throw APIError.validationError(detail)
        case 422:
            let detail = parseDetail(data)
            throw APIError.validationError(detail)
        default:
            throw APIError.serverError(http.statusCode)
        }
    }

    private func parseDetail(_ data: Data) -> String {
        if let json = try? JSONDecoder().decode([String: String].self, from: data),
           let detail = json["detail"] {
            return detail
        }
        return "Unknown error"
    }

    // MARK: - Game Events

    func getGameEvents() async throws -> [GameEventDTO] {
        let data = try await request("/game/events")
        return try JSONDecoder.apiDecoder.decode([GameEventDTO].self, from: data)
    }

    func getGameEventDetail(eventId: Int) async throws -> GameEventDetailDTO {
        let data = try await request("/game/events/\(eventId)")
        return try JSONDecoder.apiDecoder.decode(GameEventDetailDTO.self, from: data)
    }

    // MARK: - Picks

    func getMyPicks(eventId: Int) async throws -> [FightPickDTO] {
        let data = try await request("/game/events/\(eventId)/picks/me")
        return try JSONDecoder.apiDecoder.decode([FightPickDTO].self, from: data)
    }

    func submitPick(fightId: Int, pick: UpsertFightPickRequest) async throws -> FightPickDTO {
        let data = try await request("/game/fights/\(fightId)/pick", method: "PUT", body: pick)
        return try JSONDecoder.apiDecoder.decode(FightPickDTO.self, from: data)
    }
    
    // MARK: - Leaderboards

        func getEventLeaderboard(eventId: Int) async throws -> [EventLeaderboardRowDTO] {
            let data = try await request("/game/events/\(eventId)/leaderboard")
            return try JSONDecoder.apiDecoder.decode([EventLeaderboardRowDTO].self, from: data)
        }

        func getMonthlyLeaderboard(periodKey: String? = nil) async throws -> [MonthlyLeaderboardRowDTO] {
            var endpoint = "/game/leaderboards/monthly"
            if let key = periodKey {
                endpoint += "?period_key=\(key)"
            }
            let data = try await request(endpoint)
            return try JSONDecoder.apiDecoder.decode([MonthlyLeaderboardRowDTO].self, from: data)
        }

        func getMyEventResults(eventId: Int) async throws -> UserEventResultDTO {
            let data = try await request("/game/events/\(eventId)/results/me")
            return try JSONDecoder.apiDecoder.decode(UserEventResultDTO.self, from: data)
        }
}

// MARK: - JSON Decoder

extension JSONDecoder {
    static let apiDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            // Try ISO8601 with fractional seconds
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd",
            ]
            for fmt in formats {
                let f = DateFormatter()
                f.dateFormat = fmt
                f.locale = Locale(identifier: "en_US_POSIX")
                if let date = f.date(from: str) { return date }
            }
            // ISO8601
            if let date = ISO8601DateFormatter().date(from: str) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(str)")
        }
        return d
    }()
}
