//
//  RecentlyViewedManager.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation

final class RecentlyViewedManager {

    static let shared = RecentlyViewedManager()
    private init() {}

    private let maxCount = 20
    private(set) var products: [Product] = []

    var onProductsChanged: (() -> Void)?

    func trackView(_ product: Product) {
        products.removeAll { $0.id == product.id }
        products.insert(product, at: 0)
        if products.count > maxCount { products.removeLast() }
        onProductsChanged?()
    }
}
