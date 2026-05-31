//
//  ProductAPIClient.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

struct ProductAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let productsURL: URL

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        productsURL: URL = URL(string: "https://dummyjson.com/products")!
    ) {
        self.session = session
        self.decoder = decoder
        self.productsURL = productsURL
    }

    func fetchProducts() async throws -> [ProductDTO] {
        let (data, response) = try await session.data(from: productsURL)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw ProductAPIError.invalidResponse
        }

        return try decoder.decode(ProductsResponseDTO.self, from: data).products
    }
}

enum ProductAPIError: Error, Equatable {
    case invalidResponse
}
