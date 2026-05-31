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

    private var language: AppLanguage {
        AppLanguage(rawValue: languageRawValue) ?? .english
    }

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
            Section(localized(.appearance)) {
                Picker(localized(.appearance), selection: appearance) {
                    ForEach(AppAppearance.allCases) { option in
                        Text(option.localizedTitle(language: language))
                            .tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(localized(.language)) {
                Picker(localized(.language), selection: selectedLanguage) {
                    ForEach(AppLanguage.allCases) { option in
                        Text(option.localizedTitle(language: language))
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
                        Text(localized(.logout))
                    }
                }
                .disabled(viewModel.isLoggingOut)
            }
        }
        .navigationTitle(localized(.settings))
    }

    private func localized(_ key: SettingsTextKey) -> String {
        key.title(language: language)
    }
}

private enum SettingsTextKey {
    case settings
    case appearance
    case language
    case logout

    func title(language: AppLanguage) -> String {
        switch (self, language) {
        case (.settings, .english):
            return "Settings"
        case (.settings, .hebrew):
            return "הגדרות"
        case (.appearance, .english):
            return "Appearance"
        case (.appearance, .hebrew):
            return "מראה"
        case (.language, .english):
            return "Language"
        case (.language, .hebrew):
            return "שפה"
        case (.logout, .english):
            return "Logout"
        case (.logout, .hebrew):
            return "התנתקות"
        }
    }
}

private extension AppAppearance {
    func localizedTitle(language: AppLanguage) -> String {
        switch (self, language) {
        case (.system, .english):
            return "System"
        case (.system, .hebrew):
            return "מערכת"
        case (.light, .english):
            return "Light"
        case (.light, .hebrew):
            return "בהיר"
        case (.dark, .english):
            return "Dark"
        case (.dark, .hebrew):
            return "כהה"
        }
    }
}

private extension AppLanguage {
    func localizedTitle(language: AppLanguage) -> String {
        switch (self, language) {
        case (.english, .english):
            return "English"
        case (.english, .hebrew):
            return "אנגלית"
        case (.hebrew, .english):
            return "Hebrew"
        case (.hebrew, .hebrew):
            return "עברית"
        }
    }
}
