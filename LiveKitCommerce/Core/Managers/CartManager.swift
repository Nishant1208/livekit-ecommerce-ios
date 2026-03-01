//
//  CartManager.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation

final class CartManager {

    static let shared = CartManager()
    private init() {}

    private(set) var items: [CartItem] = []

    var onItemsChanged: (() -> Void)?

    // MARK: - Computed

    var totalAmount: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var isEmpty: Bool { items.isEmpty }

    // MARK: - Actions

    func add(_ product: Product) {
        if let idx = items.firstIndex(where: { $0.product == product }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
        onItemsChanged?()
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.product == item.product }
        onItemsChanged?()
    }

    func setQuantity(_ quantity: Int, for item: CartItem) {
        guard quantity > 0 else { remove(item); return }
        if let idx = items.firstIndex(where: { $0.product == item.product }) {
            items[idx].quantity = quantity
            onItemsChanged?()
        }
    }

    func clear() {
        items.removeAll()
        onItemsChanged?()
    }
}
