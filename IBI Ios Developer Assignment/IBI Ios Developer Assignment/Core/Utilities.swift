//
//  Utilities.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import SwiftUI

enum L10n {
    static func tr(_ key: String, _ arguments: CVarArg...) -> String {
        let format = localizedString(for: key)
        guard !arguments.isEmpty else { return format }

        return String(
            format: format,
            locale: Locale(identifier: currentLanguage.localeIdentifier),
            arguments: arguments
        )
    }

    static var currentLanguage: AppLanguage {
        let rawValue = UserDefaults.standard.string(forKey: "app_language")
        return rawValue.flatMap(AppLanguage.init(rawValue:)) ?? .english
    }

    static var layoutDirection: LayoutDirection {
        currentLanguage == .hebrew ? .rightToLeft : .leftToRight
    }

    private static func localizedString(for key: String) -> String {
        localizedBundle(for: currentLanguage).localizedString(
            forKey: key,
            value: fallbackBundle.localizedString(forKey: key, value: key, table: nil),
            table: nil
        )
    }

    private static func localizedBundle(for language: AppLanguage) -> Bundle {
        guard let path = Bundle.main.path(forResource: language.localizationCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return fallbackBundle
        }

        return bundle
    }

    private static var fallbackBundle: Bundle {
        guard let path = Bundle.main.path(forResource: AppLanguage.english.localizationCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }

        return bundle
    }
}
