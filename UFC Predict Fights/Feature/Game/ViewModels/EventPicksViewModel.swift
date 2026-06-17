//
//  EventPicksViewModel.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EventPicksViewModel {

    var eventDetail: GameEventDetailDTO? = nil
    var picks: [Int: FightPickDTO] = [:]  // fight_id → pick
    var scores: [Int: FightScoreDTO] = [:] // fight_id → score
    var saveStates: [Int: SaveState] = [:] // fight_id → save state
    var isLoading = false
    var errorMessage: String? = nil

    private let api = GameAPIClient.shared
    private var saveTasks: [Int: Task<Void, Never>] = [:]

    enum SaveState: Equatable {
        case idle
        case saving
        case saved
        case failed(String)
    }

    // MARK: - Load

    func loadEvent(eventId: Int) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let detail = try await api.getGameEventDetail(eventId: eventId)
                eventDetail = detail

                // Index picks by fight_id
                picks = Dictionary(uniqueKeysWithValues: detail.picks.map { ($0.fightId, $0) })

                // Index scores by fight_id
                scores = Dictionary(uniqueKeysWithValues: detail.scores.map { ($0.fightId, $0) })

            } catch let error as GameAPIClient.APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Failed to load event"
            }
            isLoading = false
        }
    }

    // MARK: - Submit Pick

    func submitPick(fightId: Int, winnerFighterId: Int, methodPick: String?, roundPick: Int?) {
        // Cancel previous save for this fight
        saveTasks[fightId]?.cancel()

        saveStates[fightId] = .saving

        saveTasks[fightId] = Task {
            // Debounce 300ms
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            do {
                let request = UpsertFightPickRequest(
                    winnerFighterId: winnerFighterId,
                    methodPick: methodPick,
                    roundPick: roundPick
                )
                let result = try await api.submitPick(fightId: fightId, pick: request)

                guard !Task.isCancelled else { return }

                picks[fightId] = result
                saveStates[fightId] = .saved

                // Clear saved state after 2s
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard !Task.isCancelled else { return }
                if saveStates[fightId] == .saved {
                    saveStates[fightId] = .idle
                }

            } catch let error as GameAPIClient.APIError {
                guard !Task.isCancelled else { return }
                saveStates[fightId] = .failed(error.errorDescription ?? "Save failed")
            } catch {
                guard !Task.isCancelled else { return }
                saveStates[fightId] = .failed("Save failed")
            }
        }
    }

    // MARK: - Computed

    var isLocked: Bool {
        guard let detail = eventDetail else { return true }
        return detail.status != "open"
    }

    var isScored: Bool {
        eventDetail?.status == "scored"
    }

    var completedPicks: Int {
        picks.values.filter { $0.isComplete }.count
    }

    var totalFights: Int {
        eventDetail?.fightCount ?? 0
    }

    var allComplete: Bool {
        completedPicks == totalFights && totalFights > 0
    }

    var totalPoints: Int {
        scores.values.reduce(0) { $0 + $1.totalPoints }
    }

    func pickFor(fightId: Int) -> FightPickDTO? {
        picks[fightId]
    }

    func scoreFor(fightId: Int) -> FightScoreDTO? {
        scores[fightId]
    }

    func saveStateFor(fightId: Int) -> SaveState {
        saveStates[fightId] ?? .idle
    }
}
