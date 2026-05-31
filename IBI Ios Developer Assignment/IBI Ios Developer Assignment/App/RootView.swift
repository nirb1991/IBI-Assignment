//
//  RootView.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var appState: AppState
    @AppStorage("app_appearance") private var appearanceRawValue = AppAppearance.system.rawValue
    @AppStorage("app_language") private var languageRawValue = AppLanguage.english.rawValue

    private let dependencies: AppDependencies

    @State private var didRequestSessionRestore = false
    @State private var didFinishSessionRestore = false
    @State private var hasSavedSession = false

    private var selectedColorScheme: ColorScheme? {
        let appearance = AppAppearance(rawValue: appearanceRawValue) ?? .system
        return appearance.colorScheme
    }

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        appState = dependencies.appState
    }

    var body: some View {
        Group {
            if !didFinishSessionRestore {
                ProgressView(L10n.tr("app.restoringSession"))
            } else if appState.isAuthenticated {
                ProductsListView(
                    viewModel: dependencies.productsViewModel,
                    favoritesRepository: dependencies.favoritesRepository,
                    appState: appState
                )
            } else if hasSavedSession {
                BiometricUnlockView(
                    appState: appState,
                    biometricAuthService: dependencies.biometricAuthService
                ) {
                    hasSavedSession = false
                }
            } else {
                LoginView(
                    appState: appState,
                    biometricAuthService: dependencies.biometricAuthService,
                    showsBiometricLogin: false
                )
            }
        }
        .task {
            guard !didRequestSessionRestore else { return }

            didRequestSessionRestore = true
            hasSavedSession = await appState.hasSavedSession()
            didFinishSessionRestore = true
        }
        .onChange(of: appState.isAuthenticated) { _, isAuthenticated in
            if !isAuthenticated {
                hasSavedSession = false
            }
        }
        .preferredColorScheme(selectedColorScheme)
        .environment(\.layoutDirection, L10n.layoutDirection)
        .id(languageRawValue)
    }
}
#Preview {
    RootView(dependencies: AppDependencies())
}
