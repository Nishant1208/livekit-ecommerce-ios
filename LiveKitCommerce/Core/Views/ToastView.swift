//
//  ToastView.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit

final class ToastView: UIView {

    // MARK: - Subviews

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 1
        return lbl
    }()

    // MARK: - Init

    private init(message: String, iconName: String, iconColor: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor(white: 0.12, alpha: 0.92)
        layer.cornerRadius = 22
        layer.masksToBounds = true

        // Blur backing
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)

        addSubview(iconView)
        addSubview(messageLabel)

        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        iconView.image = UIImage(systemName: iconName, withConfiguration: cfg)
        iconView.tintColor = iconColor
        messageLabel.text = message

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            messageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public Show

    @discardableResult
    static func show(
        message: String,
        icon: String = "checkmark.circle.fill",
        iconColor: UIColor = AppColors.success,
        in view: UIView,
        haptic: UINotificationFeedbackGenerator.FeedbackType? = .success,
        duration: TimeInterval = 2.0
    ) -> ToastView {
        let toast = ToastView(message: message, iconName: icon, iconColor: iconColor)
        view.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
        ])

        // Haptic
        if let hapticType = haptic {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(hapticType)
        }

        // Animate in
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, animations: {
            toast.alpha = 1
            toast.transform = .identity
        })

        // Dismiss after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            toast.alpha = 0
            toast.transform = CGAffineTransform(translationX: 0, y: -10)
        }, completion: { _ in
            toast.removeFromSuperview()
        })
        }

        return toast
    }
}
