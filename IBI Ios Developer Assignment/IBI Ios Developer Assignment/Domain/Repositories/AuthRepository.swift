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
            return "Invalid username or password."
        case .sessionStorageFailed:
            return "Unable to save the user session."
        case .sessionRestoreFailed:
            return "Unable to restore the user session."
        }
    }
}

protocol AuthRepository {
    func login(username: String, password: String) async throws -> UserSession
    func logout() async
    func restoreSession() async -> UserSession?
}
