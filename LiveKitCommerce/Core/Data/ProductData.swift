//
//  ProductData.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation

enum ProductData {

    // MARK: - Recommended (8 products)

    static let recommended: [Product] = [
        .init(id: "r1", name: "Premium Wireless Earbuds",
              price: 79.99, originalPrice: 129.99,
              imageURL: url("earbuds1"), category: .recommended,
              stockStatus: .inStock,
              description: "Immersive sound with active noise cancellation and 24-hour battery life."),

        .init(id: "r2", name: "Smart Watch Series X",
              price: 199.99, originalPrice: 299.99,
              imageURL: url("smartwatch1"), category: .recommended,
              stockStatus: .inStock,
              description: "Track fitness, receive notifications, and stay connected all day."),

        .init(id: "r3", name: "Mechanical Keyboard Pro",
              price: 149.99, originalPrice: nil,
              imageURL: url("keyboard1"), category: .recommended,
              stockStatus: .inStock,
              description: "Tactile switches with RGB backlighting. Built for speed and precision."),

        .init(id: "r4", name: "Ultra-Slim Laptop Stand",
              price: 49.99, originalPrice: 69.99,
              imageURL: url("stand1"), category: .recommended,
              stockStatus: .lowStock(count: 4),
              description: "Elevate your workflow with this premium aluminium laptop stand."),

        .init(id: "r5", name: "4K Webcam Pro",
              price: 119.99, originalPrice: 159.99,
              imageURL: url("webcam1"), category: .recommended,
              stockStatus: .inStock,
              description: "Crystal-clear 4K video for remote meetings and content creation."),

        .init(id: "r6", name: "USB-C Hub 7-in-1",
              price: 59.99, originalPrice: nil,
              imageURL: url("hub1"), category: .recommended,
              stockStatus: .inStock,
              description: "Expand connectivity with HDMI 4K, USB-A, SD card, and fast charging."),

        .init(id: "r7", name: "Portable Bluetooth Speaker",
              price: 89.99, originalPrice: 119.99,
              imageURL: url("speaker1"), category: .recommended,
              stockStatus: .inStock,
              description: "360° surround sound with IPX7 waterproofing. 20-hour playback."),

        .init(id: "r8", name: "Ergonomic Mouse Pad XL",
              price: 34.99, originalPrice: nil,
              imageURL: url("mousepad1"), category: .recommended,
              stockStatus: .inStock,
              description: "Extra-large surface with memory foam wrist support."),
    ]

    // MARK: - Explore (12 products)

    static let explore: [Product] = [
        .init(id: "e1", name: "LED Desk Lamp Smart",
              price: 44.99, originalPrice: 64.99,
              imageURL: url("lamp1"), category: .explore,
              stockStatus: .inStock,
              description: "Touch-sensitive dimmer with adjustable colour temperature."),

        .init(id: "e2", name: "Phone Charging Stand",
              price: 29.99, originalPrice: nil,
              imageURL: url("charger1"), category: .explore,
              stockStatus: .inStock,
              description: "MagSafe-compatible 15W fast wireless charging with cable management."),

        .init(id: "e3", name: "Noise-Cancelling Headphones",
              price: 249.99, originalPrice: 349.99,
              imageURL: url("headphones1"), category: .explore,
              stockStatus: .inStock,
              description: "Studio-quality audio with 30-hour ANC battery life."),

        .init(id: "e4", name: "Screen Protector Glass",
              price: 14.99, originalPrice: nil,
              imageURL: url("screenguard1"), category: .explore,
              stockStatus: .inStock,
              description: "9H hardness tempered glass with oleophobic coating."),

        .init(id: "e5", name: "Mini Portable Projector",
              price: 189.99, originalPrice: 249.99,
              imageURL: url("projector1"), category: .explore,
              stockStatus: .lowStock(count: 6),
              description: "100-inch display anywhere. 2-hour battery with built-in speaker."),

        .init(id: "e6", name: "Cable Management Kit",
              price: 19.99, originalPrice: 27.99,
              imageURL: url("cable1"), category: .explore,
              stockStatus: .inStock,
              description: "Keep your desk tidy with 50 reusable velcro cable ties."),

        .init(id: "e7", name: "Smart Plug Wi-Fi 2-Pack",
              price: 24.99, originalPrice: nil,
              imageURL: url("smartplug1"), category: .explore,
              stockStatus: .inStock,
              description: "Control any device remotely. Works with Alexa and Google Home."),

        .init(id: "e8", name: "Portable SSD 1TB",
              price: 109.99, originalPrice: 139.99,
              imageURL: url("ssd1"), category: .explore,
              stockStatus: .inStock,
              description: "1000MB/s read speeds in a pocket-sized aluminium enclosure."),

        .init(id: "e9", name: "Monitor Light Bar",
              price: 69.99, originalPrice: 89.99,
              imageURL: url("lightbar1"), category: .explore,
              stockStatus: .lowStock(count: 3),
              description: "Reduces eye strain. Clips to any monitor without screen glare."),

        .init(id: "e10", name: "Foldable Wireless Charger",
              price: 39.99, originalPrice: nil,
              imageURL: url("foldcharge1"), category: .explore,
              stockStatus: .inStock,
              description: "3-in-1: phone, watch, and earbuds charging in one elegant stand."),

        .init(id: "e11", name: "Compact Travel Router",
              price: 54.99, originalPrice: 74.99,
              imageURL: url("router1"), category: .explore,
              stockStatus: .inStock,
              description: "Secure private Wi-Fi anywhere. VPN support, no setup required."),

        .init(id: "e12", name: "Digital Drawing Tablet",
              price: 79.99, originalPrice: 99.99,
              imageURL: url("tablet1"), category: .explore,
              stockStatus: .outOfStock,
              description: "8192 pressure levels with 60-degree tilt recognition."),
    ]

    // MARK: - Helper

    private static func url(_ seed: String) -> URL {
        URL(string: "https://picsum.photos/seed/\(seed)/400/400")!
    }
}
