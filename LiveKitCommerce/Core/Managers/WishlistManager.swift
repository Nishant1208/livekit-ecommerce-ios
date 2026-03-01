//
//  WishlistManager.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation

final class WishlistManager {

    static let shared = WishlistManager()
    private init() {}

    private var wishlistedIds: Set<String> = []

    var onWishlistChanged: (() -> Void)?

    // MARK: - Actions

    @discardableResult
    func toggle(_ product: Product) -> Bool {
        if wishlistedIds.contains(product.id) {
            wishlistedIds.remove(product.id)
        } else {
            wishlistedIds.insert(product.id)
        }
        onWishlistChanged?()
        return wishlistedIds.contains(product.id)
    }

    func isWishlisted(_ product: Product) -> Bool {
        wishlistedIds.contains(product.id)
    }

    var wishlistedProducts: [Product] {
        let all = ProductData.recommended + ProductData.explore
        return all.filter { wishlistedIds.contains($0.id) }
    }
}
