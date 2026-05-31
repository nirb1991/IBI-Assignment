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

    private var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !appState.isLoading
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Login")
        }
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
