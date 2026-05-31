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

                        if biometricAuthService.canAuthenticate() {
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
