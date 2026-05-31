//
//  Product.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let category: String
    let brand: String?
    let rating: Double
    let thumbnail: String
    let images: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, price, category, brand, rating, thumbnail, images
    }
}
