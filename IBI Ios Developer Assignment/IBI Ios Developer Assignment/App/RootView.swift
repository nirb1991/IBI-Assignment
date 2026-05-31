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

    private let dependencies: AppDependencies

    @State private var didRequestSessionRestore = false
    @State private var didFinishSessionRestore = false

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
                ProgressView("Restoring session")
            } else if appState.isAuthenticated {
                ProductsListView(
                    viewModel: dependencies.productsViewModel,
                    favoritesRepository: dependencies.favoritesRepository,
                    appState: appState
                )
            } else {
                LoginView(
                    appState: appState,
                    biometricAuthService: dependencies.biometricAuthService
                )
            }
        }
        .task {
            guard !didRequestSessionRestore else { return }

            didRequestSessionRestore = true
            await appState.restoreSession()
            didFinishSessionRestore = true
        }
        .preferredColorScheme(selectedColorScheme)
    }
}
