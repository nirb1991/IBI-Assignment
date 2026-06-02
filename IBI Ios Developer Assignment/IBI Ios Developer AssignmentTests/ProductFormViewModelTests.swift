//
//  ProductFormViewModelTests.swift
//  IBI Ios Developer AssignmentTests
//
//  Created by Nir Barzilay on 02/06/2026.
//

import XCTest
@testable import IBI_Ios_Developer_Assignment

@MainActor
final class ProductFormViewModelTests: XCTestCase {
    func test_SaveWithMissingTitleShowsValidationError() async {
        let repository = MockProductRepository(products: [])
        let viewModel = ProductFormViewModel(
            mode: .create(nextID: 1),
            productRepository: repository,
            onSave: { _ in XCTFail("Invalid product should not be saved.") }
        )

        fillValidFields(on: viewModel, title: "")

        let didSave = await viewModel.save()

        XCTAssertFalse(didSave)
        XCTAssertEqual(viewModel.errorMessage, "Title is required.")
        XCTAssertTrue(repository.addedProducts.isEmpty)
    }

    func test_SaveValidProductAddsProduct() async {
        let repository = MockProductRepository(products: [])
        var savedProduct: Product?
        let viewModel = ProductFormViewModel(
            mode: .create(nextID: 42),
            productRepository: repository,
            onSave: { savedProduct = $0 }
        )

        fillValidFields(
            on: viewModel,
            title: "New Product",
            price: "19.99",
            category: "test",
            rating: "4.5"
        )

        let didSave = await viewModel.save()

        XCTAssertTrue(didSave)
        XCTAssertEqual(repository.addedProducts.first?.id, 42)
        XCTAssertEqual(savedProduct?.title, "New Product")
    }

    func test_SaveEditedProductUpdatesExistingProduct() async {
        let product = Product.make(id: 12, title: "Old Product")
        let repository = MockProductRepository(products: [product])
        var savedProduct: Product?
        let viewModel = ProductFormViewModel(
            mode: .edit(product),
            productRepository: repository,
            onSave: { savedProduct = $0 }
        )

        fillValidFields(
            on: viewModel,
            title: "Updated Product",
            description: "Updated description",
            price: "25.5",
            category: "updated",
            brand: "",
            rating: "3.5",
            thumbnail: "https://example.com/new-thumb.png"
        )

        let didSave = await viewModel.save()

        XCTAssertTrue(didSave)
        XCTAssertEqual(repository.updatedProducts.first?.id, 12)
        XCTAssertEqual(repository.updatedProducts.first?.title, "Updated Product")
        XCTAssertNil(repository.updatedProducts.first?.brand)
        XCTAssertEqual(savedProduct?.images, ["https://example.com/new-thumb.png"])
    }

    private func fillValidFields(
        on viewModel: ProductFormViewModel,
        title: String = "Product",
        description: String = "Description",
        price: String = "10",
        category: String = "category",
        brand: String = "Brand",
        rating: String = "4",
        thumbnail: String = "https://example.com/image.png",
        images: String = ""
    ) {
        viewModel.title = title
        viewModel.description = description
        viewModel.price = price
        viewModel.category = category
        viewModel.brand = brand
        viewModel.rating = rating
        viewModel.thumbnail = thumbnail
        viewModel.images = images
    }
}

extension Product {
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
