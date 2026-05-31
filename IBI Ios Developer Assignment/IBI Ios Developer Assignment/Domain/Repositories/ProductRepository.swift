//
//  ProductRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

struct ProductsPage {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
    let isFromCache: Bool
}

protocol ProductRepository {
    func fetchProducts() async throws -> [Product]
    func fetchProductsPage(limit: Int, skip: Int) async throws -> ProductsPage

    func addProduct(_ product: Product) async throws
    func updateProduct(_ product: Product) async throws
    func deleteProduct(id: Int) async throws

    func resetLocalChangesFromAPI() async throws
}
