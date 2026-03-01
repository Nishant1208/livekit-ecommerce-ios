//
//  ShimmerView.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit

/// Overlay this view on top of any content that is loading to show a shimmer effect.
final class ShimmerView: UIView {

    private let gradientLayer = CAGradientLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = AppColors.surfaceElevated

        let light = UIColor(white: 1, alpha: 0.10).cgColor
        let base  = UIColor(white: 1, alpha: 0.04).cgColor
        let dark  = UIColor(white: 1, alpha: 0.00).cgColor

        gradientLayer.colors = [dark, light, dark]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(
            x: -bounds.width,
            y: 0,
            width: bounds.width * 3,
            height: bounds.height
        )
    }

    // MARK: - Animation

    func startShimmering() {
        guard gradientLayer.animation(forKey: "shimmer") == nil else { return }

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width * 2
        animation.toValue   =  bounds.width * 2
        animation.duration  = 1.4
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "shimmer")
    }

    func stopShimmering() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}
