//
//  SettingsViewModel.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 02/06/2026.
//

import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var isLoggingOut = false

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func logout() async {
        isLoggingOut = true
        await appState.logout()
        isLoggingOut = false
    }
}
