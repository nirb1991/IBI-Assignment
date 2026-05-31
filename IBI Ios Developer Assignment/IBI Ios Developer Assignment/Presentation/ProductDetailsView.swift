//
//  ProductDetailsView.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import SwiftUI

struct ProductDetailsView: UIViewControllerRepresentable {
    let product: Product
    let favoritesRepository: FavoritesRepository

    func makeUIViewController(context: Context) -> ProductDetailsViewController {
        let viewModel = ProductDetailsViewModel(
            product: product,
            favoritesRepository: favoritesRepository
        )
        return ProductDetailsViewController(viewModel: viewModel)
    }

    func updateUIViewController(
        _ uiViewController: ProductDetailsViewController,
        context: Context
    ) {}
}
