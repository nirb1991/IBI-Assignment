//
//  Favorites.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favoriteProducts: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var recentlyRemovedProduct: Product?

    private let productRepository: ProductRepository
    private let favoritesRepository: FavoritesRepository

    init(
        productRepository: ProductRepository,
        favoritesRepository: FavoritesRepository
    ) {
        self.productRepository = productRepository
        self.favoritesRepository = favoritesRepository
    }

    func loadFavorites() async {
        isLoading = true
        errorMessage = nil

        do {
            let products = try await productRepository.fetchProducts()
            let favoriteIDs = await favoritesRepository.favoriteProductIDs()
            favoriteProducts = products
                .filter { favoriteIDs.contains($0.id) }
                .sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func removeFavorite(_ product: Product) async {
        await favoritesRepository.removeFavorite(productID: product.id)
        favoriteProducts.removeAll { $0.id == product.id }
        recentlyRemovedProduct = product
    }

    func undoRemoveFavorite() async {
        guard let recentlyRemovedProduct else { return }

        await favoritesRepository.addFavorite(productID: recentlyRemovedProduct.id)
        self.recentlyRemovedProduct = nil
        await loadFavorites()
    }

    func clearUndoState() {
        recentlyRemovedProduct = nil
    }
}

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    private let favoritesRepository: FavoritesRepository

    init(
        viewModel: FavoritesViewModel,
        favoritesRepository: FavoritesRepository
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.favoritesRepository = favoritesRepository
    }

    var body: some View {
        content
            .navigationTitle("Favorites")
            .task {
                await viewModel.loadFavorites()
            }
            .refreshable {
                await viewModel.loadFavorites()
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.favoriteProducts.isEmpty {
            FavoritesLoadingView()
        } else if let errorMessage = viewModel.errorMessage,
                  viewModel.favoriteProducts.isEmpty {
            FavoritesErrorView(message: errorMessage) {
                Task {
                    await viewModel.loadFavorites()
                }
            }
        } else if viewModel.favoriteProducts.isEmpty {
            FavoritesEmptyView()
        } else {
            List(viewModel.favoriteProducts) { product in
                NavigationLink {
                    ProductDetailsView(
                        product: product,
                        favoritesRepository: favoritesRepository
                    )
                } label: {
                    FavoriteProductRow(product: product)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.removeFavorite(product)
                        }
                    } label: {
                        Label("Remove", systemImage: "heart.slash")
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let product = viewModel.recentlyRemovedProduct {
                    FavoriteUndoBanner(productTitle: product.title) {
                        Task {
                            await viewModel.undoRemoveFavorite()
                        }
                    } dismiss: {
                        viewModel.clearUndoState()
                    }
                }
            }
        }
    }
}

private struct FavoriteProductRow: View {
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
                    Label(
                        product.rating.formatted(.number.precision(.fractionLength(1))),
                        systemImage: "star.fill"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct FavoriteUndoBanner: View {
    let productTitle: String
    let undo: () -> Void
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("Removed \(productTitle)")
                .font(.footnote)
                .lineLimit(1)

            Spacer()

            Button("Undo", action: undo)
                .font(.footnote.weight(.semibold))

            Button(action: dismiss) {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Dismiss undo")
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 8))
        .padding()
    }
}

private struct FavoritesLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading favorites")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FavoritesErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Unable to load favorites", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: retry)
        }
    }
}

private struct FavoritesEmptyView: View {
    var body: some View {
        ContentUnavailableView(
            "No favorites yet",
            systemImage: "heart",
            description: Text("Favorite products from the details screen.")
        )
    }
}
