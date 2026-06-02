//
//  ProductsViewModelTests.swift
//  IBI Ios Developer AssignmentTests
//
//  Created by Nir Barzilay on 02/06/2026.
//

import XCTest
@testable import IBI_Ios_Developer_Assignment

@MainActor
final class ProductsViewModelTests: XCTestCase {
    func test_LoadProductsSearchSortAndFilter() async {
        let repository = MockProductRepository(products: [
            .make(id: 1, title: "Banana", price: 4, category: "groceries", rating: 3),
            .make(id: 2, title: "AirPods", price: 99, category: "electronics", rating: 4.8),
            .make(id: 3, title: "Camera", price: 250, category: "electronics", rating: 4.2)
        ])
        let viewModel = ProductsViewModel(productRepository: repository, pageSize: 20)

        await viewModel.loadProducts()

        XCTAssertEqual(viewModel.products.count, 3)
        XCTAssertEqual(viewModel.filteredProducts.map(\.title), ["AirPods", "Banana", "Camera"])

        viewModel.searchText = "ca"
        XCTAssertEqual(viewModel.filteredProducts.map(\.title), ["Camera"])

        viewModel.searchText = ""
        viewModel.setFilterOption(.category("electronics"))
        XCTAssertEqual(viewModel.filteredProducts.map(\.title), ["AirPods", "Camera"])

        viewModel.setSortOption(.price)
        XCTAssertEqual(viewModel.filteredProducts.map(\.title), ["AirPods", "Camera"])

        viewModel.setSortOption(.rating)
        XCTAssertEqual(viewModel.filteredProducts.map(\.title), ["AirPods", "Camera"])
    }

    func test_LoadNextPageAppendsProductsAndUpdatesPaginationState() async {
        let repository = MockProductRepository(products: [
            .make(id: 1, title: "Alpha"),
            .make(id: 2, title: "Bravo"),
            .make(id: 3, title: "Charlie")
        ])
        let viewModel = ProductsViewModel(productRepository: repository, pageSize: 2)

        await viewModel.loadProducts()
        XCTAssertEqual(viewModel.products.map(\.id), [1, 2])
        XCTAssertTrue(viewModel.hasMoreProducts)

        await viewModel.loadNextPage()

        XCTAssertEqual(viewModel.products.map(\.id), [1, 2, 3])
        XCTAssertEqual(viewModel.filteredProducts.map(\.id), [1, 2, 3])
        XCTAssertFalse(viewModel.hasMoreProducts)
        XCTAssertFalse(viewModel.isLoadingNextPage)
    }
}

final class MockProductRepository: ProductRepository {
    var products: [Product]
    var addedProducts: [Product] = []
    var updatedProducts: [Product] = []
    var deletedProductIDs: [Int] = []

    init(products: [Product]) {
        self.products = products
    }

    func fetchProducts() async throws -> [Product] {
        products
    }

    func fetchProductsPage(limit: Int, skip: Int) async throws -> ProductsPage {
        ProductsPage(
            products: Array(products.dropFirst(skip).prefix(limit)),
            total: products.count,
            skip: skip,
            limit: limit,
            isFromCache: false
        )
    }

    func addProduct(_ product: Product) async throws {
        addedProducts.append(product)
        products.append(product)
    }

    func updateProduct(_ product: Product) async throws {
        updatedProducts.append(product)
    }

    func deleteProduct(id: Int) async throws {
        deletedProductIDs.append(id)
        products.removeAll { $0.id == id }
    }

    func resetLocalChangesFromAPI() async throws {}
}
