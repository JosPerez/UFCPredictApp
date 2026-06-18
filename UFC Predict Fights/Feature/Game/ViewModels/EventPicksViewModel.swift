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
    var savedPicks: [Int: FightPickDTO] = [:]
    var drafts: [Int: DraftPick] = [:]
    var scores: [Int: FightScoreDTO] = [:]
    var saveState: BatchSaveState = .idle
    var isLoading = false
    var errorMessage: String? = nil

    private let api = GameAPIClient.shared
    private var saveTasks: [Int: Task<Void, Never>] = [:]

    // MARK: - Draft Pick

    struct DraftPick: Equatable {
        var winnerFighterId: Int?
        var methodPick: String?
        var roundPick: Int?

        var isComplete: Bool {
            guard winnerFighterId != nil, let method = methodPick else { return false }
            if method == "DECISION" { return true }
            return roundPick != nil
        }
    }

    enum BatchSaveState: Equatable {
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

                // Index saved picks
                savedPicks = Dictionary(uniqueKeysWithValues: detail.picks.map { ($0.fightId, $0) })

                // Initialize drafts from saved picks
                drafts = [:]
                for pick in detail.picks {
                    drafts[pick.fightId] = DraftPick(
                        winnerFighterId: pick.winnerFighterId,
                        methodPick: pick.methodPick,
                        roundPick: pick.roundPick
                    )
                }

                // Index scores
                scores = Dictionary(uniqueKeysWithValues: detail.scores.map { ($0.fightId, $0) })
                // LOG Score from response
                GameLogger.eventLoaded(eventId: eventId, fights: detail.fightCount, picks: detail.picks.count)

            } catch let error as GameAPIClient.APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Failed to load event"
            }
            isLoading = false
        }
    }

    // MARK: - Draft Management

    func updateDraft(fightId: Int, winnerFighterId: Int?, methodPick: String?, roundPick: Int?) {
        var draft = drafts[fightId] ?? DraftPick()
        draft.winnerFighterId = winnerFighterId
        draft.methodPick = methodPick
        draft.roundPick = roundPick
        drafts[fightId] = draft
        // LOG drafts
        GameLogger.pickUpdated(fightId: fightId, winnerId: winnerFighterId, method: methodPick, round: roundPick)
    }

    func resetDraft(fightId: Int) {
        if let saved = savedPicks[fightId] {
            drafts[fightId] = DraftPick(
                winnerFighterId: saved.winnerFighterId,
                methodPick: saved.methodPick,
                roundPick: saved.roundPick
            )
        } else {
            drafts.removeValue(forKey: fightId)
        }
    }

    func resetAllDrafts() {
        drafts = [:]
        for pick in savedPicks.values {
            drafts[pick.fightId] = DraftPick(
                winnerFighterId: pick.winnerFighterId,
                methodPick: pick.methodPick,
                roundPick: pick.roundPick
            )
        }
    }

    // MARK: - Save

    func saveAllDirtyPicks() {
        // Start
        let dirty = dirtyPicks
        
        // LOG save all dirty picks
        GameLogger.batchSaveStarted(count: dirty.count)
        
        guard !dirty.isEmpty else {
            saveState = .saved
            clearSavedStateAfterDelay()
            return
        }

        saveState = .saving

        Task {
            var failedCount = 0
            var lastError = ""

            for (fightId, draft) in dirty {
                guard let winnerId = draft.winnerFighterId else { continue }

                do {
                    let request = UpsertFightPickRequest(
                        winnerFighterId: winnerId,
                        methodPick: draft.methodPick,
                        roundPick: draft.roundPick
                    )
                    let result = try await api.submitPick(fightId: fightId, pick: request)

                    // Update saved state
                    savedPicks[fightId] = result

                } catch let error as GameAPIClient.APIError {
                    failedCount += 1
                    lastError = error.errorDescription ?? "Save failed"
                } catch {
                    failedCount += 1
                    lastError = "Save failed"
                }
            }

            if failedCount > 0 {
                saveState = .failed("\(failedCount) pick\(failedCount > 1 ? "s" : "") failed: \(lastError)")
            } else {
                saveState = .saved
                clearSavedStateAfterDelay()
            }
            GameLogger.batchSaveCompleted(saved: dirty.count - failedCount, failed: failedCount)
        }
    }

    private func clearSavedStateAfterDelay() {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if saveState == .saved {
                saveState = .idle
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

    var totalFights: Int {
        eventDetail?.fightCount ?? 0
    }

    var completedPicks: Int {
        drafts.values.filter { $0.isComplete }.count
    }

    var allComplete: Bool {
        completedPicks == totalFights && totalFights > 0
    }

    var totalPoints: Int {
        scores.values.reduce(0) { $0 + $1.totalPoints }
    }

    var hasDirtyPicks: Bool {
        !dirtyPicks.isEmpty
    }

    var dirtyPicks: [Int: DraftPick] {
        var dirty: [Int: DraftPick] = [:]
        for (fightId, draft) in drafts {
            guard draft.winnerFighterId != nil else { continue }

            if let saved = savedPicks[fightId] {
                let savedDraft = DraftPick(
                    winnerFighterId: saved.winnerFighterId,
                    methodPick: saved.methodPick,
                    roundPick: saved.roundPick
                )
                if draft != savedDraft {
                    dirty[fightId] = draft
                }
            } else {
                dirty[fightId] = draft
            }
        }
        return dirty
    }

    var dirtyCount: Int {
        dirtyPicks.count
    }

    func draftFor(fightId: Int) -> DraftPick {
        drafts[fightId] ?? DraftPick()
    }

    func scoreFor(fightId: Int) -> FightScoreDTO? {
        scores[fightId]
    }
}
