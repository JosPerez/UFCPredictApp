//
//  UserProfileService.swift
//  UFC Predict Fights
//
//  Created by Jose Perez on 16/06/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct UserProfile {
    let uid: String
    let firstName: String
    let lastName: String
    let nickname: String
    let email: String
    let provider: String
    let createdAt: Date
}

final class UserProfileService {

    static let shared = UserProfileService()
    private init() {}

    private let db = Firestore.firestore()
    private let collection = "users"

    // MARK: - Check if profile exists

    func profileExists(uid: String) async throws -> Bool {
        let doc = try await db.collection(collection).document(uid).getDocument()
        return doc.exists
    }

    // MARK: - Get profile

    func getProfile(uid: String) async throws -> UserProfile? {
        let doc = try await db.collection(collection).document(uid).getDocument()
        guard doc.exists, let data = doc.data() else { return nil }

        return UserProfile(
            uid: uid,
            firstName: data["firstName"] as? String ?? "",
            lastName: data["lastName"] as? String ?? "",
            nickname: data["nickname"] as? String ?? "",
            email: data["email"] as? String ?? "",
            provider: data["provider"] as? String ?? "email",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    // MARK: - Check nickname uniqueness

    func isNicknameAvailable(_ nickname: String) async throws -> Bool {
        let normalized = nickname.lowercased().trimmingCharacters(in: .whitespaces)
        guard !normalized.isEmpty else { return false }

        let snapshot = try await db.collection(collection)
            .whereField("nicknameLower", isEqualTo: normalized)
            .limit(to: 1)
            .getDocuments()

        return snapshot.documents.isEmpty
    }

    // MARK: - Create profile

    func createProfile(
        uid: String,
        firstName: String,
        lastName: String,
        nickname: String,
        email: String,
        provider: String
    ) async throws {
        let data: [String: Any] = [
            "firstName": firstName.trimmingCharacters(in: .whitespaces),
            "lastName": lastName.trimmingCharacters(in: .whitespaces),
            "nickname": nickname.trimmingCharacters(in: .whitespaces),
            "nicknameLower": nickname.lowercased().trimmingCharacters(in: .whitespaces),
            "email": email,
            "provider": provider,
            "createdAt": FieldValue.serverTimestamp(),
        ]

        try await db.collection(collection).document(uid).setData(data)
    }

    // MARK: - Update profile

    func updateProfile(uid: String, firstName: String, lastName: String, nickname: String) async throws {
        let data: [String: Any] = [
            "firstName": firstName.trimmingCharacters(in: .whitespaces),
            "lastName": lastName.trimmingCharacters(in: .whitespaces),
            "nickname": nickname.trimmingCharacters(in: .whitespaces),
            "nicknameLower": nickname.lowercased().trimmingCharacters(in: .whitespaces),
        ]

        try await db.collection(collection).document(uid).updateData(data)
    }
}
