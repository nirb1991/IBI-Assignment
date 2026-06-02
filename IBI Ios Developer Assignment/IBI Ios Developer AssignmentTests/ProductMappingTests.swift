//
//  ProductMappingTests.swift
//  IBI Ios Developer AssignmentTests
//
//  Created by Nir Barzilay on 02/06/2026.
//

import XCTest
@testable import IBI_Ios_Developer_Assignment

@MainActor
final class ProductMappingTests: XCTestCase {
    func test_DTOToCachedProductToDomainModelMapping() {
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

    func test_ProductToCachedProductToDomainModelMapping() {
        let originalProduct = Product(
            id: 9,
            title: "Domain Product",
            description: "Domain description",
            price: 42,
            category: "domain",
            brand: nil,
            rating: 3.9,
            thumbnail: "https://example.com/domain-thumb.png",
            images: [
                "https://example.com/domain-1.png",
                "https://example.com/domain-2.png"
            ]
        )

        let cachedProduct = CachedProduct(product: originalProduct)
        let mappedProduct = cachedProduct.toDomainModel()

        XCTAssertEqual(mappedProduct, originalProduct)
    }
}
