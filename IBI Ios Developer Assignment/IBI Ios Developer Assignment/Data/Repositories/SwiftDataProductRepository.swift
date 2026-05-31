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

        guard cachedProducts.isEmpty else {
            return cachedProducts.map { $0.toDomainModel() }
        }

        let response = try await apiClient.fetchProducts()
        try upsertCache(with: response.products)
        return try fetchCachedProducts().map { $0.toDomainModel() }
    }

    func fetchProductsPage(limit: Int, skip: Int) async throws -> ProductsPage {
        let cachedProducts = try fetchCachedProducts()

        if skip == 0, !cachedProducts.isEmpty {
            let products = cachedProducts.map { $0.toDomainModel() }
            return ProductsPage(
                products: products,
                total: products.count + (products.count >= limit ? limit : 0),
                skip: 0,
                limit: limit,
                isFromCache: true
            )
        }

        do {
            let response = try await apiClient.fetchProducts(limit: limit, skip: skip)
            try upsertCache(with: response.products)

            return ProductsPage(
                products: response.products.map { $0.toDomainModel() },
                total: response.total,
                skip: response.skip,
                limit: response.limit,
                isFromCache: false
            )
        } catch {
            guard skip == 0, !cachedProducts.isEmpty else {
                throw error
            }

            let products = cachedProducts.map { $0.toDomainModel() }
            return ProductsPage(
                products: products,
                total: products.count,
                skip: 0,
                limit: limit,
                isFromCache: true
            )
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
        let productDTOs = try await fetchAllProductDTOs()
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

    private func fetchAllProductDTOs(pageSize: Int = 20) async throws -> [ProductDTO] {
        var skip = 0
        var allProducts: [ProductDTO] = []
        var total = Int.max

        while allProducts.count < total {
            let response = try await apiClient.fetchProducts(limit: pageSize, skip: skip)
            allProducts.append(contentsOf: response.products)
            total = response.total
            skip += response.limit

            if response.products.isEmpty {
                break
            }
        }

        return allProducts
    }

    private func upsertCache(with productDTOs: [ProductDTO]) throws {
        for productDTO in productDTOs {
            if let cachedProduct = try cachedProduct(id: productDTO.id) {
                cachedProduct.update(with: productDTO)
            } else {
                modelContext.insert(CachedProduct(dto: productDTO))
            }
        }

        try modelContext.save()
    }
}

private extension ProductDTO {
    func toDomainModel() -> Product {
        Product(
            id: id,
            title: title,
            description: description,
            price: price,
            category: category,
            brand: brand,
            rating: rating,
            thumbnail: thumbnail,
            images: images
        )
    }
}

enum ProductRepositoryError: Error, Equatable {
    case productAlreadyExists
    case productNotFound
}

extension ProductRepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .productAlreadyExists:
            return "A product with this ID already exists."
        case .productNotFound:
            return "The product could not be found."
        }
    }
}
