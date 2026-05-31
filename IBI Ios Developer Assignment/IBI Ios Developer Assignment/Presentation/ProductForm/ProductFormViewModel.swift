//
//  ProductFormViewModel.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import Combine

@MainActor
final class ProductFormViewModel: ObservableObject {
    @Published var title: String
    @Published var description: String
    @Published var price: String
    @Published var category: String
    @Published var brand: String
    @Published var rating: String
    @Published var thumbnail: String
    @Published var images: String
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSaving = false

    let mode: ProductFormMode

    private let productRepository: ProductRepository
    private let onSave: (Product) -> Void

    init(
        mode: ProductFormMode,
        productRepository: ProductRepository,
        onSave: @escaping (Product) -> Void
    ) {
        self.mode = mode
        self.productRepository = productRepository
        self.onSave = onSave

        switch mode {
        case .create:
            title = ""
            description = ""
            price = ""
            category = ""
            brand = ""
            rating = ""
            thumbnail = ""
            images = ""
        case .edit(let product):
            title = product.title
            description = product.description
            price = ProductFormViewModel.format(product.price)
            category = product.category
            brand = product.brand ?? ""
            rating = ProductFormViewModel.format(product.rating)
            thumbnail = product.thumbnail
            images = product.images.joined(separator: "\n")
        }
    }

    func save() async -> Bool {
        guard let product = validateProduct() else {
            return false
        }

        isSaving = true
        errorMessage = nil

        do {
            switch mode {
            case .create:
                try await productRepository.addProduct(product)
            case .edit:
                try await productRepository.updateProduct(product)
            }

            onSave(product)
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }

    private func validateProduct() -> Product? {
        let trimmedTitle = title.trimmed
        let trimmedDescription = description.trimmed
        let trimmedCategory = category.trimmed
        let trimmedBrand = brand.trimmed
        let trimmedThumbnail = thumbnail.trimmed
        let parsedImages = images
            .components(separatedBy: .newlines)
            .map(\.trimmed)
            .filter { !$0.isEmpty }

        guard !trimmedTitle.isEmpty else {
            errorMessage = L10n.tr("productForm.validation.titleRequired")
            return nil
        }

        guard !trimmedDescription.isEmpty else {
            errorMessage = L10n.tr("productForm.validation.descriptionRequired")
            return nil
        }

        guard let priceValue = Double(price.trimmed.replacingOccurrences(of: ",", with: "")), priceValue >= 0 else {
            errorMessage = L10n.tr("productForm.validation.validPrice")
            return nil
        }

        guard !trimmedCategory.isEmpty else {
            errorMessage = L10n.tr("productForm.validation.categoryRequired")
            return nil
        }

        guard let ratingValue = Double(rating.trimmed),
              (0...5).contains(ratingValue) else {
            errorMessage = L10n.tr("productForm.validation.ratingRange")
            return nil
        }

        guard !trimmedThumbnail.isEmpty else {
            errorMessage = L10n.tr("productForm.validation.thumbnailRequired")
            return nil
        }

        let id: Int
        switch mode {
        case .create(let nextID):
            id = nextID
        case .edit(let product):
            id = product.id
        }

        return Product(
            id: id,
            title: trimmedTitle,
            description: trimmedDescription,
            price: priceValue,
            category: trimmedCategory,
            brand: trimmedBrand.isEmpty ? nil : trimmedBrand,
            rating: ratingValue,
            thumbnail: trimmedThumbnail,
            images: parsedImages.isEmpty ? [trimmedThumbnail] : parsedImages
        )
    }

    private static func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
