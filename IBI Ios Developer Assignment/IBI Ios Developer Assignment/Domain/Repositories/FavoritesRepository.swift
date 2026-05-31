//
//  FavoritesRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

protocol FavoritesRepository {
    func favoriteProductIDs() async -> Set<Int>
    func addFavorite(productID: Int) async
    func removeFavorite(productID: Int) async
}
