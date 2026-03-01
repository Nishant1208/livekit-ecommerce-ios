//
//  CartManager.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation

extension Notification.Name {
    static let cartDidChange = Notification.Name("com.livekitcommerce.cartDidChange")
}

final class CartManager {

    static let shared = CartManager()
    private init() {}

    private(set) var items: [CartItem] = []

    // MARK: - Computed

    var totalAmount: Double { items.reduce(0) { $0 + $1.subtotal } }
    var itemCount: Int      { items.reduce(0) { $0 + $1.quantity } }
    var isEmpty: Bool       { items.isEmpty }

    var totalSavings: Double {
        items.reduce(0) { total, item in
            guard let original = item.product.originalPrice else { return total }
            return total + (original - item.product.price) * Double(item.quantity)
        }
    }

    // MARK: - Actions

    func add(_ product: Product) {
        if let idx = items.firstIndex(where: { $0.product == product }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
        notify()
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.product == item.product }
        notify()
    }

    func setQuantity(_ quantity: Int, for item: CartItem) {
        guard quantity > 0 else { remove(item); return }
        if let idx = items.firstIndex(where: { $0.product == item.product }) {
            items[idx].quantity = quantity
            notify()
        }
    }

    func clear() {
        items.removeAll()
        notify()
    }

    /// Re-inserts a previously removed CartItem exactly (preserving quantity). Used for undo.
    func restore(_ item: CartItem) {
        items.removeAll { $0.product == item.product }
        items.append(item)
        notify()
    }

    // MARK: - Private

    private func notify() {
        // Post to all observers simultaneously — no single-closure overwrite problem
        NotificationCenter.default.post(name: .cartDidChange, object: nil)
    }
}
