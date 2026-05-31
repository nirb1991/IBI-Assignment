//
//  ProductForm.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import Combine
import SwiftUI

enum ProductFormMode {
    case create(nextID: Int)
    case edit(Product)

    var title: String {
        switch self {
        case .create:
            return "Create Product"
        case .edit:
            return "Edit Product"
        }
    }

    var submitTitle: String {
        switch self {
        case .create:
            return "Create"
        case .edit:
            return "Save"
        }
    }
}

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
            errorMessage = "Title is required."
            return nil
        }

        guard !trimmedDescription.isEmpty else {
            errorMessage = "Description is required."
            return nil
        }

        guard let priceValue = Double(price.trimmed), priceValue >= 0 else {
            errorMessage = "Enter a valid price."
            return nil
        }

        guard !trimmedCategory.isEmpty else {
            errorMessage = "Category is required."
            return nil
        }

        guard let ratingValue = Double(rating.trimmed),
              (0...5).contains(ratingValue) else {
            errorMessage = "Rating must be between 0 and 5."
            return nil
        }

        guard !trimmedThumbnail.isEmpty else {
            errorMessage = "Thumbnail URL is required."
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

struct ProductFormView: View {
    @StateObject private var viewModel: ProductFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ProductFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Category", text: $viewModel.category)
                    TextField("Brand", text: $viewModel.brand)
                }

                Section("Pricing and Rating") {
                    TextField("Price", text: $viewModel.price)
                        .keyboardType(.decimalPad)
                    TextField("Rating", text: $viewModel.rating)
                        .keyboardType(.decimalPad)
                }

                Section("Images") {
                    TextField("Thumbnail URL", text: $viewModel.thumbnail)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Image URLs, one per line", text: $viewModel.images, axis: .vertical)
                        .lineLimit(3...6)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.mode.submitTitle) {
                        Task {
                            if await viewModel.save() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
