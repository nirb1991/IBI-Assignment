//
//  UserDefaultsFavoritesRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 01/06/2026.
//

import Foundation

struct UserDefaultsFavoritesRepository: FavoritesRepository {
    private let userDefaults: UserDefaults
    private let storageKey: String

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = "favorite_product_ids"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    func favoriteProductIDs() async -> Set<Int> {
        Set(userDefaults.array(forKey: storageKey) as? [Int] ?? [])
    }

    func addFavorite(productID: Int) async {
        var favoriteIDs = await favoriteProductIDs()
        favoriteIDs.insert(productID)
        save(favoriteIDs)
    }

    func removeFavorite(productID: Int) async {
        var favoriteIDs = await favoriteProductIDs()
        favoriteIDs.remove(productID)
        save(favoriteIDs)
    }

    private func save(_ favoriteIDs: Set<Int>) {
        userDefaults.set(Array(favoriteIDs), forKey: storageKey)
    }
}
