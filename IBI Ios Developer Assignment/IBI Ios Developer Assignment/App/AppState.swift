//
//  AppState.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var userSession: UserSession?
    @Published private(set) var isLoading = false
    @Published private(set) var authenticationError: AuthenticationError?

    var isAuthenticated: Bool {
        userSession != nil
    }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func restoreSession() async {
        isLoading = true
        authenticationError = nil

        userSession = await authRepository.restoreSession()

        isLoading = false
    }

    func hasSavedSession() async -> Bool {
        await authRepository.restoreSession() != nil
    }

    func login(username: String, password: String) async {
        isLoading = true
        authenticationError = nil

        do {
            userSession = try await authRepository.login(
                username: username,
                password: password
            )
        } catch let error as AuthenticationError {
            authenticationError = error
            userSession = nil
        } catch {
            authenticationError = .sessionStorageFailed
            userSession = nil
        }

        isLoading = false
    }

    func logout() async {
        isLoading = true
        authenticationError = nil

        await authRepository.logout()
        userSession = nil

        isLoading = false
    }
}
