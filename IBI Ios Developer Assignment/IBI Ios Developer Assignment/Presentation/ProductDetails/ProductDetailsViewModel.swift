//
//  ProductDetailsViewModel.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

@MainActor
final class ProductDetailsViewModel {
    let product: Product

    private(set) var isFavorite = false {
        didSet {
            onFavoriteStateChanged?(isFavorite)
        }
    }

    var onFavoriteStateChanged: ((Bool) -> Void)?

    private let favoritesRepository: FavoritesRepository

    init(product: Product, favoritesRepository: FavoritesRepository) {
        self.product = product
        self.favoritesRepository = favoritesRepository
    }

    func loadFavoriteState() async {
        let favoriteIDs = await favoritesRepository.favoriteProductIDs()
        isFavorite = favoriteIDs.contains(product.id)
    }

    func toggleFavorite() async {
        if isFavorite {
            await favoritesRepository.removeFavorite(productID: product.id)
            isFavorite = false
        } else {
            await favoritesRepository.addFavorite(productID: product.id)
            isFavorite = true
        }
    }
}
