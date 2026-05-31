//
//  BiometricAuthService.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import LocalAuthentication

/// Handles biometric authentication using Face ID or Touch ID.
struct BiometricAuthService {
    private let contextFactory: () -> LAContext
    private let reason: String

    /// Creates an injectable biometric authentication service.
    init(
        contextFactory: @escaping () -> LAContext = { LAContext() },
        reason: String = L10n.tr("biometric.reason")
    ) {
        self.contextFactory = contextFactory
        self.reason = reason
    }

    /// Returns true when Face ID or Touch ID is available and enrolled.
    func canAuthenticate() -> Bool {
        let context = contextFactory()
        var error: NSError?

        return context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
    }

    /// Prompts the user for Face ID or Touch ID authentication.
    func authenticate() async throws {
        let context = contextFactory()

        _ = try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}
