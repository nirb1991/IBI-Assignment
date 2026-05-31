//
//  ProductFormView.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SwiftUI

struct ProductFormView: View {
    @StateObject private var viewModel: ProductFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ProductFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            Form {
                Section(L10n.tr("productForm.section.product")) {
                    TextField(L10n.tr("productForm.title"), text: $viewModel.title)
                    TextField(L10n.tr("productForm.description"), text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField(L10n.tr("productForm.category"), text: $viewModel.category)
                    TextField(L10n.tr("productForm.brand"), text: $viewModel.brand)
                }

                Section(L10n.tr("productForm.section.pricing")) {
                    TextField(L10n.tr("productForm.price"), text: $viewModel.price)
                        .keyboardType(.decimalPad)
                    TextField(L10n.tr("productForm.rating"), text: $viewModel.rating)
                        .keyboardType(.decimalPad)
                }

                Section(L10n.tr("productForm.section.images")) {
                    TextField(L10n.tr("productForm.thumbnail"), text: $viewModel.thumbnail)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField(L10n.tr("productForm.images"), text: $viewModel.images, axis: .vertical)
                        .lineLimit(3...6)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle(viewModel.mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.tr("common.cancel")) {
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

#Preview {
    struct PreviewWrapper: View {
        @StateObject private var viewModel = ProductFormViewModel(
            mode: .create(nextID: 1),
            productRepository: MockProductRepository(),
            onSave: { _ in }
        )
        var body: some View {
            ProductFormView(viewModel: viewModel)
        }
    }
    final class MockProductRepository: ProductRepository {
        func fetchProducts() async throws -> [Product] { [] }
        func fetchProductsPage(limit: Int, skip: Int) async throws -> ProductsPage {
            ProductsPage(products: [], total: 0, skip: 0, limit: 0, isFromCache: false)
        }
        func addProduct(_ product: Product) async throws {}
        func updateProduct(_ product: Product) async throws {}
        func deleteProduct(id: Int) async throws {}
        func resetLocalChangesFromAPI() async throws {}
    }

    return PreviewWrapper()
}
