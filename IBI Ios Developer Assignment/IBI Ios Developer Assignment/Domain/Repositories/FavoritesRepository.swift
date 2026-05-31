//
//  FavoritesRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

protocol FavoritesRepository {
    func getFavoriteProductIDs() async -> Set<Int>
    func addToFavorites(productID: Int) async
    func removeFromFavorites(productID: Int) async
}
