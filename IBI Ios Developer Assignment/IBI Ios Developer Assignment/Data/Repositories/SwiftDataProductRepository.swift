//
//  SwiftDataProductRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataProductRepository: ProductRepository {
    private let apiClient: ProductAPIClient
    private let modelContext: ModelContext

    init(apiClient: ProductAPIClient, modelContext: ModelContext) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    func fetchProducts() async throws -> [Product] {
        let cachedProducts = try fetchCachedProducts()

        do {
            let productDTOs = try await apiClient.fetchProducts()
            try replaceCache(with: productDTOs)
            return try fetchCachedProducts().map { $0.toDomainModel() }
        } catch {
            guard !cachedProducts.isEmpty else {
                throw error
            }

            return cachedProducts.map { $0.toDomainModel() }
        }
    }

    func addProduct(_ product: Product) async throws {
        guard try cachedProduct(id: product.id) == nil else {
            throw ProductRepositoryError.productAlreadyExists
        }

        modelContext.insert(CachedProduct(product: product))
        try modelContext.save()
    }

    func updateProduct(_ product: Product) async throws {
        guard let cachedProduct = try cachedProduct(id: product.id) else {
            throw ProductRepositoryError.productNotFound
        }

        cachedProduct.update(with: product)
        try modelContext.save()
    }

    func deleteProduct(id: Int) async throws {
        guard let cachedProduct = try cachedProduct(id: id) else {
            throw ProductRepositoryError.productNotFound
        }

        modelContext.delete(cachedProduct)
        try modelContext.save()
    }

    func resetLocalChangesFromAPI() async throws {
        let productDTOs = try await apiClient.fetchProducts()
        try replaceCache(with: productDTOs)
    }

    private func fetchCachedProducts() throws -> [CachedProduct] {
        let descriptor = FetchDescriptor<CachedProduct>(
            sortBy: [SortDescriptor(\.id)]
        )

        return try modelContext.fetch(descriptor)
    }

    private func cachedProduct(id: Int) throws -> CachedProduct? {
        var descriptor = FetchDescriptor<CachedProduct>(
            predicate: #Predicate { product in
                product.id == id
            }
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }

    private func replaceCache(with productDTOs: [ProductDTO]) throws {
        for cachedProduct in try fetchCachedProducts() {
            modelContext.delete(cachedProduct)
        }

        for productDTO in productDTOs {
            modelContext.insert(CachedProduct(dto: productDTO))
        }

        try modelContext.save()
    }
}

enum ProductRepositoryError: Error, Equatable {
    case productAlreadyExists
    case productNotFound
}
