//
//  Settings.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import Combine
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case hebrew

    var id: String {
        rawValue
    }

    var localizationCode: String {
        switch self {
        case .english:
            return "en"
        case .hebrew:
            return "he"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .english:
            return "en_US"
        case .hebrew:
            return "he_IL"
        }
    }
}

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

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @AppStorage("app_appearance") private var appearanceRawValue = AppAppearance.system.rawValue
    @AppStorage("app_language") private var languageRawValue = AppLanguage.english.rawValue

    private var appearance: Binding<AppAppearance> {
        Binding {
            AppAppearance(rawValue: appearanceRawValue) ?? .system
        } set: {
            appearanceRawValue = $0.rawValue
        }
    }

    private var selectedLanguage: Binding<AppLanguage> {
        Binding {
            AppLanguage(rawValue: languageRawValue) ?? .english
        } set: {
            languageRawValue = $0.rawValue
        }
    }

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section(L10n.tr("settings.appearance")) {
                Picker(L10n.tr("settings.appearance"), selection: appearance) {
                    ForEach(AppAppearance.allCases) { option in
                        Text(option.localizedTitle)
                            .tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(L10n.tr("settings.language")) {
                Picker(L10n.tr("settings.language"), selection: selectedLanguage) {
                    ForEach(AppLanguage.allCases) { option in
                        Text(option.localizedTitle)
                            .tag(option)
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                } label: {
                    if viewModel.isLoggingOut {
                        ProgressView()
                    } else {
                        Text(L10n.tr("settings.logout"))
                    }
                }
                .disabled(viewModel.isLoggingOut)
            }
        }
        .navigationTitle(L10n.tr("settings.title"))
    }
}

private extension AppAppearance {
    var localizedTitle: String {
        switch self {
        case .system:
            return L10n.tr("settings.appearance.system")
        case .light:
            return L10n.tr("settings.appearance.light")
        case .dark:
            return L10n.tr("settings.appearance.dark")
        }
    }
}

private extension AppLanguage {
    var localizedTitle: String {
        switch self {
        case .english:
            return L10n.tr("settings.language.english")
        case .hebrew:
            return L10n.tr("settings.language.hebrew")
        }
    }
}
