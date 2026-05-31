//
//  DI.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Combine
import Foundation
import SwiftData

@MainActor
final class AppDependencies: ObservableObject {
    let keychainService: KeychainService
    let biometricAuthService: BiometricAuthService
    let authRepository: AuthRepository
    let productRepository: ProductRepository
    let favoritesRepository: FavoritesRepository
    let appState: AppState
    let productsViewModel: ProductsViewModel

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: CachedProduct.self)
        } catch {
            fatalError("Failed to create SwiftData model container: \(error)")
        }

        keychainService = KeychainService()
        biometricAuthService = BiometricAuthService()
        authRepository = MockAuthRepository(keychainService: keychainService)

        let apiClient = ProductAPIClient()
        productRepository = SwiftDataProductRepository(
            apiClient: apiClient,
            modelContext: modelContainer.mainContext
        )

        favoritesRepository = UserDefaultsFavoritesRepository()
        appState = AppState(authRepository: authRepository)
        productsViewModel = ProductsViewModel(productRepository: productRepository)
    }
}
