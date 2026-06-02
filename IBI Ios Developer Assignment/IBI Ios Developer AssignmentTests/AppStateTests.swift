//
//  AppStateTests.swift
//  IBI Ios Developer AssignmentTests
//
//  Created by Nir Barzilay on 02/06/2026.
//

import XCTest
@testable import IBI_Ios_Developer_Assignment

@MainActor
final class AppStateTests: XCTestCase {
    func test_RestoreLoginLogoutFlow() async {
        let repository = StubAuthRepository()
        repository.restoredSession = UserSession(username: "restored")
        let appState = AppState(authRepository: repository)

        let hasSavedSession = await appState.hasSavedSession()
        XCTAssertTrue(hasSavedSession)
        XCTAssertFalse(appState.isAuthenticated)

        await appState.restoreSession()
        XCTAssertEqual(appState.userSession?.username, "restored")
        XCTAssertTrue(appState.isAuthenticated)

        repository.loginSession = UserSession(username: "admin")
        await appState.login(username: "admin", password: "1234")
        XCTAssertEqual(appState.userSession?.username, "admin")

        await appState.logout()
        XCTAssertNil(appState.userSession)
        XCTAssertTrue(repository.didLogout)
    }

    func test_LoginFailureClearsSessionAndStoresAuthenticationError() async {
        let repository = StubAuthRepository()
        repository.restoredSession = UserSession(username: "restored")
        let appState = AppState(authRepository: repository)

        await appState.restoreSession()
        XCTAssertTrue(appState.isAuthenticated)

        repository.loginError = AuthenticationError.invalidCredentials
        await appState.login(username: "admin", password: "wrong")

        XCTAssertNil(appState.userSession)
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertEqual(appState.authenticationError, .invalidCredentials)
        XCTAssertFalse(appState.isLoading)
    }
}

private final class StubAuthRepository: AuthRepository {
    var restoredSession: UserSession?
    var loginSession = UserSession(username: "admin")
    var loginError: Error?
    var didLogout = false

    func login(username: String, password: String) async throws -> UserSession {
        if let loginError {
            throw loginError
        }

        return loginSession
    }

    func logout() async {
        didLogout = true
    }

    func restoreSession() async -> UserSession? {
        restoredSession
    }
}
