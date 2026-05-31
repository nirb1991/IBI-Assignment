//
//  ProductsResponseDTO.swift
//  IBI Ios Developer Assignment
//
//  Created by Nir Barzilay on 31/05/2026.
//

import Foundation

struct ProductsResponseDTO: Decodable {
    let products: [ProductDTO]
}
