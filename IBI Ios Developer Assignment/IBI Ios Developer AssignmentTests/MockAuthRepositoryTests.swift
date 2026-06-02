//
//  MockAuthRepositoryTests.swift
//  IBI Ios Developer AssignmentTests
//
//  Created by Nir Barzilay on 02/06/2026.
//

import XCTest
@testable import IBI_Ios_Developer_Assignment

@MainActor
final class MockAuthRepositoryTests: XCTestCase {
    func test_LoginWithValidCredentialsReturnsAndStoresSession() async throws {
        let repository = makeRepository()

        let session = try await repository.login(username: "admin", password: "1234")

        XCTAssertEqual(session.username, "admin")
        let restoredSession = await repository.restoreSession()
        XCTAssertEqual(restoredSession, session)
    }

    func test_LoginWithInvalidCredentialsThrowsInvalidCredentials() async {
        let repository = makeRepository()

        do {
            _ = try await repository.login(username: "admin", password: "wrong")
            XCTFail("Expected invalid credentials error.")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_LogoutDeletesStoredSession() async throws {
        let repository = makeRepository()

        _ = try await repository.login(username: "admin", password: "1234")
        let storedSession = await repository.restoreSession()
        XCTAssertNotNil(storedSession)

        await repository.logout()

        let restoredSession = await repository.restoreSession()
        XCTAssertNil(restoredSession)
    }

    private func makeRepository() -> MockAuthRepository {
        let keychainService = KeychainService(service: "test.auth.\(UUID().uuidString)")
        return MockAuthRepository(keychainService: keychainService)
    }
}
