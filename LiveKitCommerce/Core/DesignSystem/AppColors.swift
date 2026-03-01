//
//  AppColors.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit

enum AppColors {
    // MARK: - Backgrounds
    static let background      = UIColor(red: 0.043, green: 0.043, blue: 0.078, alpha: 1)
    static let surface         = UIColor(red: 0.071, green: 0.071, blue: 0.118, alpha: 1)
    static let surfaceElevated = UIColor(red: 0.110, green: 0.110, blue: 0.180, alpha: 1)
    static let surfaceHigh     = UIColor(red: 0.150, green: 0.150, blue: 0.220, alpha: 1)

    // MARK: - Brand
    static let primary         = UIColor(red: 0.345, green: 0.337, blue: 0.839, alpha: 1) // indigo
    static let accent          = UIColor(red: 0.120, green: 0.670, blue: 0.900, alpha: 1) // cyan

    // MARK: - Text
    static let textPrimary     = UIColor.white
    static let textSecondary   = UIColor(white: 0.60, alpha: 1)
    static let textTertiary    = UIColor(white: 0.38, alpha: 1)

    // MARK: - Semantic
    static let success         = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)
    static let warning         = UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1)
    static let error           = UIColor.systemRed
    static let separator       = UIColor(white: 1, alpha: 0.07)
    static let wishlistActive  = UIColor.systemPink
    static let wishlistInactive = UIColor(white: 0.55, alpha: 1)
}
