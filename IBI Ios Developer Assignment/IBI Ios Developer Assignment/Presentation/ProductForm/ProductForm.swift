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
            return L10n.tr("productForm.create.title")
        case .edit:
            return L10n.tr("productForm.edit.title")
        }
    }

    var submitTitle: String {
        switch self {
        case .create:
            return L10n.tr("common.create")
        case .edit:
            return L10n.tr("common.save")
        }
    }
}
