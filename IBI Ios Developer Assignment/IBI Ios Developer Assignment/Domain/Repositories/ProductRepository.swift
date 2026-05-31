//
//  ProductRepository.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

protocol ProductRepository {
    func fetchProducts() async throws -> [Product]

    func addProduct(_ product: Product) async throws
    func updateProduct(_ product: Product) async throws
    func deleteProduct(id: Int) async throws

    func resetLocalChangesFromAPI() async throws
}
