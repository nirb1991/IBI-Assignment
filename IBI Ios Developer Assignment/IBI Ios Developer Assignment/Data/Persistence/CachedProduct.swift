//
//  CachedProduct.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation
import SwiftData

@Model
final class CachedProduct {
    @Attribute(.unique) var id: Int
    var title: String
    var productDescription: String
    var price: Double
    var category: String
    var brand: String?
    var rating: Double
    var thumbnail: String
    var images: [String]

    init(
        id: Int,
        title: String,
        productDescription: String,
        price: Double,
        category: String,
        brand: String?,
        rating: Double,
        thumbnail: String,
        images: [String]
    ) {
        self.id = id
        self.title = title
        self.productDescription = productDescription
        self.price = price
        self.category = category
        self.brand = brand
        self.rating = rating
        self.thumbnail = thumbnail
        self.images = images
    }

    convenience init(product: Product) {
        self.init(
            id: product.id,
            title: product.title,
            productDescription: product.description,
            price: product.price,
            category: product.category,
            brand: product.brand,
            rating: product.rating,
            thumbnail: product.thumbnail,
            images: product.images
        )
    }

    convenience init(dto: ProductDTO) {
        self.init(
            id: dto.id,
            title: dto.title,
            productDescription: dto.description,
            price: dto.price,
            category: dto.category,
            brand: dto.brand,
            rating: dto.rating,
            thumbnail: dto.thumbnail,
            images: dto.images
        )
    }

    func update(with product: Product) {
        title = product.title
        productDescription = product.description
        price = product.price
        category = product.category
        brand = product.brand
        rating = product.rating
        thumbnail = product.thumbnail
        images = product.images
    }

    func update(with dto: ProductDTO) {
        title = dto.title
        productDescription = dto.description
        price = dto.price
        category = dto.category
        brand = dto.brand
        rating = dto.rating
        thumbnail = dto.thumbnail
        images = dto.images
    }

    func toDomainModel() -> Product {
        Product(
            id: id,
            title: title,
            description: productDescription,
            price: price,
            category: category,
            brand: brand,
            rating: rating,
            thumbnail: thumbnail,
            images: images
        )
    }
}
