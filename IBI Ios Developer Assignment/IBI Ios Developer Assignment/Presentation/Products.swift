//
//  Products.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import Combine

enum SortOption: String, CaseIterable, Identifiable {
    case title
    case price
    case rating

    var id: String {
        rawValue
    }
}

enum FilterOption: Equatable, Identifiable {
    case all
    case category(String)

    var id: String {
        switch self {
        case .all:
            return "all"
        case .category(let category):
            return category
        }
    }
}

@MainActor
final class ProductsViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var filteredProducts: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    @Published var searchText = "" {
        didSet {
            applyFiltersAndSorting()
        }
    }

    @Published var sortOption: SortOption = .title {
        didSet {
            applyFiltersAndSorting()
        }
    }

    @Published var filterOption: FilterOption = .all {
        didSet {
            applyFiltersAndSorting()
        }
    }

    var availableFilters: [FilterOption] {
        let categories = Set(products.map(\.category)).sorted()
        return [.all] + categories.map { .category($0) }
    }

    private let productRepository: ProductRepository

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            products = try await productRepository.fetchProducts()
            applyFiltersAndSorting()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func setSortOption(_ option: SortOption) {
        sortOption = option
    }

    func setFilterOption(_ option: FilterOption) {
        filterOption = option
    }

    private func applyFiltersAndSorting() {
        var result = products

        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        if case .category(let category) = filterOption {
            result = result.filter { $0.category == category }
        }

        switch sortOption {
        case .title:
            result.sort {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .price:
            result.sort { $0.price < $1.price }
        case .rating:
            result.sort { $0.rating > $1.rating }
        }

        filteredProducts = result
    }
}
