//
//  Product.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation

struct Product: Equatable {
    let id: String
    let name: String
    let price: Double
    let originalPrice: Double?
    let imageURL: URL
    let category: ProductCategory
    let stockStatus: StockStatus
    let description: String

    var isDiscounted: Bool { originalPrice != nil }

    var discountPercentage: Int? {
        guard let original = originalPrice, original > 0 else { return nil }
        return Int((1.0 - price / original) * 100)
    }

    static func == (lhs: Product, rhs: Product) -> Bool { lhs.id == rhs.id }
}

// MARK: - Cart

struct CartItem: Equatable {
    let product: Product
    var quantity: Int

    var subtotal: Double { product.price * Double(quantity) }
}

// MARK: - Enums

enum ProductCategory: String {
    case recommended
    case explore
}

enum StockStatus {
    case inStock
    case lowStock(count: Int)
    case outOfStock

    var displayText: String {
        switch self {
        case .inStock:            return "In Stock"
        case .lowStock(let n):   return "Only \(n) left"
        case .outOfStock:         return "Out of Stock"
        }
    }

    var isAvailable: Bool {
        if case .outOfStock = self { return false }
        return true
    }
}
