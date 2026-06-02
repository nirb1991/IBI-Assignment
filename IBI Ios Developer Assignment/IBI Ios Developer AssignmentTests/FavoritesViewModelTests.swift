//
//  FavoritesViewModelTests.swift
//  IBI Ios Developer AssignmentTests
//
//  Created by Nir Barzilay on 02/06/2026.
//

import XCTest
@testable import IBI_Ios_Developer_Assignment

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    func test_RemoveFavoriteAndUndoRestoresFavoriteProduct() async {
        let product = Product.make(id: 10, title: "Favorite")
        let productRepository = MockProductRepository(products: [product])
        let favoritesRepository = MockFavoritesRepository(favoriteIDs: [10])
        let viewModel = FavoritesViewModel(
            productRepository: productRepository,
            favoritesRepository: favoritesRepository
        )

        await viewModel.loadFavorites()
        XCTAssertEqual(viewModel.favoriteProducts.map(\.id), [10])

        await viewModel.removeFavorite(product)
        XCTAssertTrue(viewModel.favoriteProducts.isEmpty)
        XCTAssertEqual(viewModel.recentlyRemovedProduct?.id, 10)
        let favoriteIDsAfterRemoval = await favoritesRepository.favoriteProductIDs()
        XCTAssertFalse(favoriteIDsAfterRemoval.contains(10))

        await viewModel.undoRemoveFavorite()
        XCTAssertEqual(viewModel.favoriteProducts.map(\.id), [10])
        let favoriteIDsAfterUndo = await favoritesRepository.favoriteProductIDs()
        XCTAssertTrue(favoriteIDsAfterUndo.contains(10))
    }

    func test_LoadFavoritesFiltersByFavoriteIDsAndSortsByTitle() async {
        let productRepository = MockProductRepository(products: [
            .make(id: 1, title: "Zebra"),
            .make(id: 2, title: "Apple"),
            .make(id: 3, title: "Camera")
        ])
        let favoritesRepository = MockFavoritesRepository(favoriteIDs: [1, 2])
        let viewModel = FavoritesViewModel(
            productRepository: productRepository,
            favoritesRepository: favoritesRepository
        )

        await viewModel.loadFavorites()

        XCTAssertEqual(viewModel.favoriteProducts.map(\.id), [2, 1])
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
}

private final class MockFavoritesRepository: FavoritesRepository {
    private var favoriteIDs: Set<Int>

    init(favoriteIDs: Set<Int>) {
        self.favoriteIDs = favoriteIDs
    }

    func favoriteProductIDs() async -> Set<Int> {
        favoriteIDs
    }

    func addFavorite(productID: Int) async {
        favoriteIDs.insert(productID)
    }

    func removeFavorite(productID: Int) async {
        favoriteIDs.remove(productID)
    }
}
