//
//  Repositories.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

struct MockAuthRepository: AuthRepository {
    private let keychainService: KeychainService
    private let sessionKey: String
    private let validUsername: String
    private let validPassword: String

    init(
        keychainService: KeychainService,
        sessionKey: String = "user_session",
        validUsername: String = "admin",
        validPassword: String = "1234"
    ) {
        self.keychainService = keychainService
        self.sessionKey = sessionKey
        self.validUsername = validUsername
        self.validPassword = validPassword
    }

    func login(username: String, password: String) async throws -> UserSession {
        guard username == validUsername, password == validPassword else {
            throw AuthenticationError.invalidCredentials
        }

        let session = UserSession(username: username)

        do {
            try keychainService.save(session, forKey: sessionKey)
            return session
        } catch {
            throw AuthenticationError.sessionStorageFailed
        }
    }

    func logout() async {
        try? keychainService.delete(forKey: sessionKey)
    }

    func restoreSession() async -> UserSession? {
        try? keychainService.read(UserSession.self, forKey: sessionKey)
    }
}

struct UserDefaultsFavoritesRepository: FavoritesRepository {
    private let userDefaults: UserDefaults
    private let storageKey: String

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "favorite_product_ids"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    func favoriteProductIDs() async -> Set<Int> {
        Set(userDefaults.array(forKey: storageKey) as? [Int] ?? [])
    }

    func addFavorite(productID: Int) async {
        var favoriteIDs = await favoriteProductIDs()
        favoriteIDs.insert(productID)
        save(favoriteIDs)
    }

    func removeFavorite(productID: Int) async {
        var favoriteIDs = await favoriteProductIDs()
        favoriteIDs.remove(productID)
        save(favoriteIDs)
    }

    private func save(_ favoriteIDs: Set<Int>) {
        userDefaults.set(Array(favoriteIDs), forKey: storageKey)
    }
}
