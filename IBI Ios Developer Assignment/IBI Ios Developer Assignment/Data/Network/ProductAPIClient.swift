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

    func fetchProducts(limit: Int = 20, skip: Int = 0) async throws -> ProductsResponseDTO {
        var components = URLComponents(url: productsURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "skip", value: String(skip))
        ]

        guard let url = components?.url else {
            throw ProductAPIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw ProductAPIError.invalidResponse
        }

        return try decoder.decode(ProductsResponseDTO.self, from: data)
    }
}

enum ProductAPIError: Error, Equatable {
    case invalidURL
    case invalidResponse
}
