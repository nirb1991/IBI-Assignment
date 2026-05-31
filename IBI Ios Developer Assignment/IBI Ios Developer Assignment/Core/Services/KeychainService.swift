//
//  KeychainService.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import Security

/// Lightweight wrapper for storing Codable values in the iOS Keychain.
struct KeychainService {
    private let service: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Creates an injectable Keychain service scoped by a service name.
    init(
        service: String = Bundle.main.bundleIdentifier ?? "IBI.Ios.Developer.Assignment",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.service = service
        self.encoder = encoder
        self.decoder = decoder
    }

    /// Stores or replaces a Codable value for the provided key.
    func save<Value: Codable>(_ value: Value, forKey key: String) throws {
        let data = try encoder.encode(value)
        let query = baseQuery(forKey: key)
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var addQuery = query
            addQuery[kSecValueData as String] = data

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unhandledStatus(addStatus)
            }
        default:
            throw KeychainError.unhandledStatus(updateStatus)
        }
    }

    /// Retrieves and decodes a Codable value for the provided key.
    func read<Value: Codable>(_ type: Value.Type, forKey key: String) throws -> Value? {
        var query = baseQuery(forKey: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                throw KeychainError.invalidData
            }

            return try decoder.decode(type, from: data)
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unhandledStatus(status)
        }
    }

    /// Deletes a stored value for the provided key.
    func delete(forKey key: String) throws {
        let status = SecItemDelete(baseQuery(forKey: key) as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    private func baseQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
    }
}

private enum KeychainError: LocalizedError, Error, Equatable {
    case invalidData
    case unhandledStatus(OSStatus)
}
