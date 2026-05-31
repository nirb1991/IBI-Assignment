//
//  IBI_Ios_Developer_AssignmentTests.swift
//  IBI Ios Developer AssignmentTests
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SwiftData
import XCTest
@testable import IBI_Ios_Developer_Assignment

final class MockAuthRepositoryTests: XCTestCase {
    func testLoginWithValidCredentialsReturnsAndStoresSession() async throws {
        let keychainService = KeychainService(service: "test.auth.success.\(UUID().uuidString)")
        let repository = MockAuthRepository(keychainService: keychainService)

        let session = try await repository.login(username: "admin", password: "1234")

        XCTAssertEqual(session.username, "admin")
        let restoredSession = await repository.restoreSession()
        XCTAssertEqual(restoredSession, session)
    }

    func testLoginWithInvalidCredentialsThrowsInvalidCredentials() async {
        let keychainService = KeychainService(service: "test.auth.failure.\(UUID().uuidString)")
        let repository = MockAuthRepository(keychainService: keychainService)

        do {
            _ = try await repository.login(username: "admin", password: "wrong")
            XCTFail("Expected invalid credentials error.")
        } catch let error as AuthenticationError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

@MainActor
final class AppStateTests: XCTestCase {
    func testRestoreLoginLogoutFlow() async {
        let repository = StubAuthRepository()
        repository.restoredSession = UserSession(username: "restored")
        let appState = AppState(authRepository: repository)

        await appState.restoreSession()
        XCTAssertEqual(appState.userSession?.username, "restored")
        XCTAssertTrue(appState.isAuthenticated)

        repository.loginSession = UserSession(username: "admin")
        await appState.login(username: "admin", password: "1234")
        XCTAssertEqual(appState.userSession?.username, "admin")

        await appState.logout()
        XCTAssertNil(appState.userSession)
        XCTAssertTrue(repository.didLogout)
    }
}

@MainActor
final class ProductsViewModelTests: XCTestCase {
    func testLoadProductsSearchSortAndFilter() async {
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
}

@MainActor
final class ProductFormViewModelTests: XCTestCase {
    func testSaveWithMissingTitleShowsValidationError() async {
        let repository = MockProductRepository(products: [])
        let viewModel = ProductFormViewModel(
            mode: .create(nextID: 1),
            productRepository: repository,
            onSave: { _ in XCTFail("Invalid product should not be saved.") }
        )

        viewModel.description = "Description"
        viewModel.price = "10"
        viewModel.category = "category"
        viewModel.rating = "4"
        viewModel.thumbnail = "https://example.com/image.png"

        let didSave = await viewModel.save()

        XCTAssertFalse(didSave)
        XCTAssertEqual(viewModel.errorMessage, "Title is required.")
        XCTAssertTrue(repository.addedProducts.isEmpty)
    }

    func testSaveValidProductAddsProduct() async {
        let repository = MockProductRepository(products: [])
        var savedProduct: Product?
        let viewModel = ProductFormViewModel(
            mode: .create(nextID: 42),
            productRepository: repository,
            onSave: { savedProduct = $0 }
        )

        viewModel.title = "New Product"
        viewModel.description = "Description"
        viewModel.price = "19.99"
        viewModel.category = "test"
        viewModel.rating = "4.5"
        viewModel.thumbnail = "https://example.com/image.png"

        let didSave = await viewModel.save()

        XCTAssertTrue(didSave)
        XCTAssertEqual(repository.addedProducts.first?.id, 42)
        XCTAssertEqual(savedProduct?.title, "New Product")
    }
}

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    func testRemoveFavoriteAndUndoRestoresFavoriteProduct() async {
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
}

@MainActor
final class ProductMappingTests: XCTestCase {
    func testDTOToCachedProductToDomainModelMapping() {
        let dto = ProductDTO(
            id: 7,
            title: "Mapped Product",
            description: "Mapped description",
            price: 12.5,
            category: "mapping",
            brand: "Brand",
            rating: 4.7,
            thumbnail: "https://example.com/thumb.png",
            images: ["https://example.com/1.png"]
        )

        let cachedProduct = CachedProduct(dto: dto)
        let product = cachedProduct.toDomainModel()

        XCTAssertEqual(product.id, dto.id)
        XCTAssertEqual(product.title, dto.title)
        XCTAssertEqual(product.description, dto.description)
        XCTAssertEqual(product.price, dto.price)
        XCTAssertEqual(product.category, dto.category)
        XCTAssertEqual(product.brand, dto.brand)
        XCTAssertEqual(product.rating, dto.rating)
        XCTAssertEqual(product.thumbnail, dto.thumbnail)
        XCTAssertEqual(product.images, dto.images)
    }
}

private final class StubAuthRepository: AuthRepository {
    var restoredSession: UserSession?
    var loginSession = UserSession(username: "admin")
    var loginError: Error?
    var didLogout = false

    func login(username: String, password: String) async throws -> UserSession {
        if let loginError {
            throw loginError
        }

        return loginSession
    }

    func logout() async {
        didLogout = true
    }

    func restoreSession() async -> UserSession? {
        restoredSession
    }
}

private final class MockProductRepository: ProductRepository {
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

private extension Product {
    static func make(
        id: Int,
        title: String,
        price: Double = 10,
        category: String = "category",
        rating: Double = 4
    ) -> Product {
        Product(
            id: id,
            title: title,
            description: "Description",
            price: price,
            category: category,
            brand: "Brand",
            rating: rating,
            thumbnail: "https://example.com/thumb.png",
            images: ["https://example.com/image.png"]
        )
    }
}
