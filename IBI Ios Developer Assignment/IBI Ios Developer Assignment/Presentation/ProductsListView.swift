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
                .navigationTitle(L10n.tr("products.title"))
                .searchable(text: $viewModel.searchText, prompt: Text(L10n.tr("products.search.placeholder")))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isCreateProductPresented = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel(Text(L10n.tr("products.create.accessibility")))
                    }

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        favoritesLink
                        categoryFilterMenu
                        sortMenu
                        resetButton
                        settingsLink
                    }
                }
                .sheet(isPresented: $isCreateProductPresented) {
                    ProductFormView(viewModel: viewModel.makeCreateProductViewModel())
                }
                .sheet(item: $productToEdit) { product in
                    ProductFormView(viewModel: viewModel.makeEditProductViewModel(for: product))
                }
                .confirmationDialog(
                    L10n.tr("products.delete.confirmation.title"),
                    isPresented: Binding(
                        get: { productToDelete != nil },
                        set: { if !$0 { productToDelete = nil } }
                    ),
                    titleVisibility: .visible
                ) {
                    Button(L10n.tr("common.delete"), role: .destructive) {
                        guard let productToDelete else { return }

                        Task {
                            await viewModel.deleteProduct(productToDelete)
                            self.productToDelete = nil
                        }
                    }

                    Button(L10n.tr("common.cancel"), role: .cancel) {
                        productToDelete = nil
                    }
                } message: {
                    Text(L10n.tr("products.delete.confirmation.message"))
                }
                .confirmationDialog(
                    L10n.tr("products.reset.confirmation.title"),
                    isPresented: $isResetConfirmationPresented,
                    titleVisibility: .visible
                ) {
                    Button(L10n.tr("common.reset"), role: .destructive) {
                        Task {
                            await viewModel.resetLocalChangesFromAPI()
                        }
                    }

                    Button(L10n.tr("common.cancel"), role: .cancel) {}
                } message: {
                    Text(L10n.tr("products.reset.confirmation.message"))
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
                            Label(L10n.tr("common.delete"), systemImage: "trash")
                        }

                        Button {
                            productToEdit = product
                        } label: {
                            Label(L10n.tr("common.edit"), systemImage: "pencil")
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
                    ProgressView(L10n.tr("products.reset.loading"))
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
                    MenuOptionLabel(
                        title: option.title,
                        isSelected: viewModel.sortOption == option
                    )
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
        .accessibilityLabel(Text(L10n.tr("products.sort.accessibility")))
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
        .accessibilityLabel(Text(L10n.tr("favorites.title")))
    }

    private var settingsLink: some View {
        NavigationLink {
            SettingsView(
                viewModel: SettingsViewModel(appState: appState)
            )
        } label: {
            Image(systemName: "gearshape")
        }
        .accessibilityLabel(Text(L10n.tr("settings.title")))
    }

    private var categoryFilterMenu: some View {
        Menu {
            ForEach(viewModel.availableFilters) { option in
                Button {
                    viewModel.setFilterOption(option)
                } label: {
                    MenuOptionLabel(
                        title: option.title,
                        isSelected: viewModel.filterOption == option
                    )
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel(Text(L10n.tr("products.filter.accessibility")))
    }

    private var resetButton: some View {
        Button {
            isResetConfirmationPresented = true
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isResetting)
        .accessibilityLabel(Text(L10n.tr("products.reset.accessibility")))
    }
}

private struct MenuOptionLabel: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        if isSelected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
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
            Text(L10n.tr("products.loading"))
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
            Label(L10n.tr("products.error.title"), systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button(L10n.tr("common.retry"), action: retry)
        }
    }
}

private struct EmptyProductsStateView: View {
    var body: some View {
        ContentUnavailableView(
            L10n.tr("products.empty.title"),
            systemImage: "magnifyingglass",
            description: Text(L10n.tr("products.empty.description"))
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
            return L10n.tr("products.sort.title")
        case .price:
            return L10n.tr("products.sort.price")
        case .rating:
            return L10n.tr("products.sort.rating")
        }
    }
}

private extension FilterOption {
    var title: String {
        switch self {
        case .all:
            return L10n.tr("products.filter.all")
        case .category(let category):
            return category.capitalized
        }
    }
}
