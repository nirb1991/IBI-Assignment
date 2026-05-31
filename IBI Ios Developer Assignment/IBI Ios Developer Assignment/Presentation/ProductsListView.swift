//
//  ProductsListView.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SwiftUI

struct ProductsListView: View {
    @StateObject private var viewModel: ProductsViewModel
    @State private var isCreateProductPresented = false
    @State private var productToEdit: Product?
    @State private var productToDelete: Product?
    @State private var isResetConfirmationPresented = false

    private let favoritesRepository: FavoritesRepository
    private let appState: AppState

    init(
        viewModel: ProductsViewModel,
        favoritesRepository: FavoritesRepository,
        appState: AppState
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.favoritesRepository = favoritesRepository
        self.appState = appState
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Products")
                .searchable(text: $viewModel.searchText, prompt: "Search products")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isCreateProductPresented = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Create product")
                    }

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        favoritesLink
                        settingsLink
                        categoryFilterMenu
                        sortMenu
                        resetButton
                    }
                }
                .sheet(isPresented: $isCreateProductPresented) {
                    ProductFormView(viewModel: viewModel.makeCreateProductViewModel())
                }
                .sheet(item: $productToEdit) { product in
                    ProductFormView(viewModel: viewModel.makeEditProductViewModel(for: product))
                }
                .confirmationDialog(
                    "Delete product?",
                    isPresented: Binding(
                        get: { productToDelete != nil },
                        set: { if !$0 { productToDelete = nil } }
                    ),
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        guard let productToDelete else { return }

                        Task {
                            await viewModel.deleteProduct(productToDelete)
                            self.productToDelete = nil
                        }
                    }

                    Button("Cancel", role: .cancel) {
                        productToDelete = nil
                    }
                } message: {
                    Text("This only deletes the locally cached product.")
                }
                .confirmationDialog(
                    "Reset local changes?",
                    isPresented: $isResetConfirmationPresented,
                    titleVisibility: .visible
                ) {
                    Button("Reset", role: .destructive) {
                        Task {
                            await viewModel.resetLocalChangesFromAPI()
                        }
                    }

                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Local product edits, additions, and deletions will be replaced with the latest API data.")
                }
                .task {
                    if viewModel.products.isEmpty {
                        await viewModel.loadProducts()
                    }
                }
                .refreshable {
                    await viewModel.loadProducts()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.products.isEmpty {
            LoadingStateView()
        } else if let errorMessage = viewModel.errorMessage,
                  viewModel.products.isEmpty {
            ErrorStateView(message: errorMessage) {
                Task {
                    await viewModel.loadProducts()
                }
            }
        } else if viewModel.filteredProducts.isEmpty {
            EmptyProductsStateView()
        } else {
            List {
                ForEach(viewModel.filteredProducts) { product in
                    NavigationLink {
                        ProductDetailsView(
                            product: product,
                            favoritesRepository: favoritesRepository
                        )
                    } label: {
                        ProductRowView(product: product)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            productToDelete = product
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            productToEdit = product
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .onAppear {
                        Task {
                            await viewModel.loadNextPageIfNeeded(currentProduct: product)
                        }
                    }
                }

                if viewModel.isLoadingNextPage {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let errorMessage = viewModel.errorMessage {
                    ErrorBannerView(message: errorMessage)
                }
            }
            .overlay {
                if viewModel.isResetting {
                    ProgressView("Resetting products")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    viewModel.setSortOption(option)
                } label: {
                    Label(
                        option.title,
                        systemImage: viewModel.sortOption == option ? "checkmark" : ""
                    )
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort products")
    }

    private var favoritesLink: some View {
        NavigationLink {
            FavoritesView(
                viewModel: viewModel.makeFavoritesViewModel(
                    favoritesRepository: favoritesRepository
                ),
                favoritesRepository: favoritesRepository
            )
        } label: {
            Image(systemName: "heart")
        }
        .accessibilityLabel("Favorites")
    }

    private var settingsLink: some View {
        NavigationLink {
            SettingsView(
                viewModel: SettingsViewModel(appState: appState)
            )
        } label: {
            Image(systemName: "gearshape")
        }
        .accessibilityLabel("Settings")
    }

    private var categoryFilterMenu: some View {
        Menu {
            ForEach(viewModel.availableFilters) { option in
                Button {
                    viewModel.setFilterOption(option)
                } label: {
                    Label(
                        option.title,
                        systemImage: viewModel.filterOption == option ? "checkmark" : ""
                    )
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel("Filter by category")
    }

    private var resetButton: some View {
        Button {
            isResetConfirmationPresented = true
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isResetting)
        .accessibilityLabel("Reset local product changes")
    }
}

private struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.secondary.opacity(0.12)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(product.category.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Text(product.price, format: .currency(code: "USD"))
                    Label(product.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading products")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Unable to load products", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: retry)
        }
    }
}

private struct EmptyProductsStateView: View {
    var body: some View {
        ContentUnavailableView(
            "No products found",
            systemImage: "magnifyingglass",
            description: Text("Try a different search or category.")
        )
    }
}

private struct ErrorBannerView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.red, in: Capsule())
            .padding()
    }
}

private extension SortOption {
    var title: String {
        switch self {
        case .title:
            return "Title"
        case .price:
            return "Price"
        case .rating:
            return "Rating"
        }
    }
}

private extension FilterOption {
    var title: String {
        switch self {
        case .all:
            return "All Categories"
        case .category(let category):
            return category.capitalized
        }
    }
}
