//
//  AuthRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

protocol AuthRepository {
    func login(username: String, password: String) async throws
    func logout() async
    func restoreSession() async -> UserSession?
}
