//
//  Authentication.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var appState: AppState
    let biometricAuthService: BiometricAuthService
    let showsBiometricLogin: Bool

    @State private var username = ""
    @State private var password = ""
    @State private var biometricErrorMessage: String?
    @State private var didAnimateHeader = false

    private var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !appState.isLoading
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                loginHeader

                Form {
                    Section {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        SecureField("Password", text: $password)
                    }

                    if let message = appState.authenticationError?.localizedDescription ?? biometricErrorMessage {
                        Section {
                            Text(message)
                                .foregroundStyle(.red)
                        }
                    }

                    Section {
                        Button {
                            Task {
                                await appState.login(username: username, password: password)
                            }
                        } label: {
                            if appState.isLoading {
                                ProgressView()
                            } else {
                                Text("Login")
                            }
                        }
                        .disabled(!canSubmit)

                        if showsBiometricLogin, biometricAuthService.canAuthenticate() {
                            Button("Login with Face ID / Touch ID") {
                                Task {
                                    await authenticateWithBiometrics()
                                }
                            }
                            .disabled(appState.isLoading)
                        }
                    }
                }
            }
            .navigationTitle("Login")
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                    didAnimateHeader = true
                }
            }
        }
    }

    private var loginHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
                .scaleEffect(didAnimateHeader ? 1 : 0.82)
                .opacity(didAnimateHeader ? 1 : 0)

            Text("Welcome Back")
                .font(.title2.weight(.semibold))
                .opacity(didAnimateHeader ? 1 : 0)

            Text("Sign in to manage products")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .opacity(didAnimateHeader ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 12)
        .offset(y: didAnimateHeader ? 0 : 8)
    }

    private func authenticateWithBiometrics() async {
        biometricErrorMessage = nil

        do {
            try await biometricAuthService.authenticate()
            await appState.restoreSession()

            if !appState.isAuthenticated {
                biometricErrorMessage = "No saved session found. Please login with username and password."
            }
        } catch {
            biometricErrorMessage = error.localizedDescription
        }
    }
}

struct BiometricUnlockView: View {
    @ObservedObject var appState: AppState
    let biometricAuthService: BiometricAuthService

    @State private var errorMessage: String?
    @State private var isUnlocking = false
    @State private var didAnimate = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "faceid")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                    .scaleEffect(didAnimate ? 1 : 0.86)
                    .opacity(didAnimate ? 1 : 0)

                Text("Unlock Session")
                    .font(.title2.weight(.semibold))

                Text("Use Face ID or Touch ID to unlock your saved login.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .offset(y: didAnimate ? 0 : 8)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await unlock()
                }
            } label: {
                if isUnlocking || appState.isLoading {
                    ProgressView()
                } else {
                    Text("Unlock with Face ID / Touch ID")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isUnlocking || appState.isLoading || !biometricAuthService.canAuthenticate())

            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                didAnimate = true
            }
        }
    }

    private func unlock() async {
        errorMessage = nil
        isUnlocking = true

        do {
            try await biometricAuthService.authenticate()
            await appState.restoreSession()

            if !appState.isAuthenticated {
                errorMessage = "No saved session found. Please login with username and password."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isUnlocking = false
    }
}
