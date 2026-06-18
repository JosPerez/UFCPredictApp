//
//  GameLogger.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 17/06/26.
//

import Foundation
import os.log

enum GameLogger {

    private static let logger = Logger(subsystem: "com.jose.perez.UFC-Predict-Fights", category: "Game")

    #if DEBUG
    private static let isDebug = true
    #else
    private static let isDebug = true
    #endif

    // MARK: - Picks

    static func pickUpdated(fightId: Int, winnerId: Int?, method: String?, round: Int?) {
        logger.info("📝 PICK DRAFT | fight=\(fightId) winner=\(winnerId ?? 0) method=\(method ?? "nil") round=\(round ?? 0)")
    }

    static func pickSaving(fightId: Int) {
        logger.info("💾 PICK SAVING | fight=\(fightId)")
    }

    static func pickSaved(fightId: Int) {
        logger.info("✅ PICK SAVED | fight=\(fightId)")
    }

    static func pickFailed(fightId: Int, error: String) {
        logger.error("❌ PICK FAILED | fight=\(fightId) error=\(error)")
    }

    static func batchSaveStarted(count: Int) {
        logger.info("💾 BATCH SAVE | saving \(count) picks")
    }

    static func batchSaveCompleted(saved: Int, failed: Int) {
        if failed > 0 {
            logger.error("⚠️ BATCH DONE | saved=\(saved) failed=\(failed)")
        } else {
            logger.info("✅ BATCH DONE | saved=\(saved)")
        }
    }

    // MARK: - Events

    static func eventLoaded(eventId: Int, fights: Int, picks: Int) {
        logger.info("📋 EVENT LOADED | id=\(eventId) fights=\(fights) picks=\(picks)")
    }

    static func eventLocked(eventId: Int) {
        logger.info("🔒 EVENT LOCKED | id=\(eventId)")
    }

    // MARK: - API

    static func apiRequest(_ method: String, _ endpoint: String) {
        guard isDebug else { return }
        logger.debug("🌐 API \(method) \(endpoint)")
    }

    static func apiResponse(_ endpoint: String, status: Int) {
        guard isDebug else { return }
        if status >= 400 {
            logger.error("🌐 API RESPONSE \(endpoint) → \(status)")
        } else {
            logger.debug("🌐 API RESPONSE \(endpoint) → \(status)")
        }
    }

    static func apiError(_ endpoint: String, error: String) {
        logger.error("🌐 API ERROR \(endpoint) → \(error)")
    }

    // MARK: - Auth

    static func authTokenRefreshed() {
        guard isDebug else { return }
        logger.debug("🔑 TOKEN REFRESHED")
    }

    static func authFailed(_ reason: String) {
        logger.error("🔑 AUTH FAILED | \(reason)")
    }

    // MARK: - Navigation

    static func screenOpened(_ screen: String) {
        guard isDebug else { return }
        logger.debug("📱 SCREEN | \(screen)")
    }
}
