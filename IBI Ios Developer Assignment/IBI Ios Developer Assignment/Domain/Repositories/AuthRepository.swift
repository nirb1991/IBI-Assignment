//
//  AuthRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

enum AuthenticationError: LocalizedError, Equatable {
    case invalidCredentials
    case sessionStorageFailed
    case sessionRestoreFailed

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return L10n.tr("auth.error.invalidCredentials")
        case .sessionStorageFailed:
            return L10n.tr("auth.error.sessionStorageFailed")
        case .sessionRestoreFailed:
            return L10n.tr("auth.error.sessionRestoreFailed")
        }
    }
}

protocol AuthRepository {
    func login(username: String, password: String) async throws -> UserSession
    func logout() async
    func restoreSession() async -> UserSession?
}
