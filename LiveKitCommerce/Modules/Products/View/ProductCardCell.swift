//
//  ProductCardCell.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import Kingfisher

protocol ProductCardCellDelegate: AnyObject {
    func productCardCell(_ cell: ProductCardCell, didToggleWishlist product: Product)
}

final class ProductCardCell: UICollectionViewCell {

    static let reuseId = "ProductCardCell"

    weak var delegate: ProductCardCellDelegate?
    private(set) var product: Product?

    // MARK: - Subviews

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = AppColors.surfaceElevated
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let shimmerView: ShimmerView = {
        let v = ShimmerView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let wishlistButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = AppColors.wishlistInactive
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .normal)
        btn.backgroundColor = UIColor(white: 0, alpha: 0.45)
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        return btn
    }()

    private let discountBadge: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = .white
        lbl.backgroundColor = AppColors.error
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 8
        lbl.clipsToBounds = true
        lbl.isHidden = true
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = AppColors.textPrimary
        lbl.numberOfLines = 2
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 14, weight: .bold)
        lbl.textColor = AppColors.accent
        return lbl
    }()

    private let originalPriceLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = AppColors.textTertiary
        lbl.isHidden = true
        return lbl
    }()

    private let stockLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = AppColors.warning
        lbl.isHidden = true
        return lbl
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
        setupLayout()
        wishlistButton.addTarget(self, action: #selector(wishlistTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Card Appearance

    private func setupCard() {
        backgroundColor = .clear

        // Shadow lives on the cell layer (no clip)
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius  = 10
        layer.shadowOffset  = CGSize(width: 0, height: 5)
        layer.cornerRadius  = 14

        // Content lives in contentView (clips for image corners)
        contentView.backgroundColor    = AppColors.surface
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds      = true
    }

    // MARK: - Layout

    private func setupLayout() {
        [imageView, shimmerView, wishlistButton, discountBadge,
         nameLabel, priceLabel, originalPriceLabel, stockLabel]
            .forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),

            shimmerView.topAnchor.constraint(equalTo: imageView.topAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            wishlistButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            wishlistButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            wishlistButton.widthAnchor.constraint(equalToConstant: 32),
            wishlistButton.heightAnchor.constraint(equalToConstant: 32),

            discountBadge.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            discountBadge.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            discountBadge.heightAnchor.constraint(equalToConstant: 18),
            discountBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 36),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            originalPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            originalPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 6),

            stockLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            stockLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            stockLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    // MARK: - Configure

    func configure(with product: Product) {
        self.product = product

        nameLabel.text = product.name
        priceLabel.text = String(format: "$%.2f", product.price)

        if let original = product.originalPrice, let pct = product.discountPercentage {
            let str = NSAttributedString(
                string: String(format: "$%.2f", original),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.attributedText = str
            originalPriceLabel.isHidden = false
            discountBadge.text = " -\(pct)% "
            discountBadge.isHidden = false
        } else {
            originalPriceLabel.isHidden = true
            discountBadge.isHidden = true
        }

        if case .lowStock = product.stockStatus {
            stockLabel.text = product.stockStatus.displayText
            stockLabel.isHidden = false
        } else if case .outOfStock = product.stockStatus {
            stockLabel.text = product.stockStatus.displayText
            stockLabel.textColor = AppColors.error
            stockLabel.isHidden = false
        } else {
            stockLabel.isHidden = true
        }

        updateWishlistAppearance()
        loadImage(url: product.imageURL)
    }

    // MARK: - Wishlist

    private func updateWishlistAppearance() {
        guard let product else { return }
        let wishlisted = WishlistManager.shared.isWishlisted(product)
        wishlistButton.tintColor = wishlisted ? AppColors.wishlistActive : AppColors.wishlistInactive
    }

    @objc private func wishlistTapped() {
        guard let product else { return }
        delegate?.productCardCell(self, didToggleWishlist: product)
        WishlistManager.shared.toggle(product)
        updateWishlistAppearance()
        animateWishlist()
    }

    private func animateWishlist() {
        UIView.animate(withDuration: 0.12, animations: {
            self.wishlistButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }, completion: { _ in
            UIView.animate(
                withDuration: 0.20, 
                delay: 0.2,
                usingSpringWithDamping: 0.45,
                initialSpringVelocity: 0.6
            ) { self.wishlistButton.transform = .identity }
        })
    }

    // MARK: - Image Loading

    private func loadImage(url: URL) {
        imageView.image = nil
        shimmerView.isHidden = false
        shimmerView.startShimmering()

        imageView.kf.setImage(with: url, options: [.transition(.fade(0.25))]) { [weak self] result in
            DispatchQueue.main.async {
                self?.shimmerView.stopShimmering()
                UIView.animate(withDuration: 0.2) {
                    self?.shimmerView.alpha = 0
                } completion: { _ in
                    self?.shimmerView.isHidden = true
                    self?.shimmerView.alpha = 1
                }
            }
        }
    }

    // MARK: - Press Animation

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.15, 
                delay: 0.2,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5
            ) {
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                    : .identity
            }
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        shimmerView.isHidden = false
        shimmerView.stopShimmering()
        shimmerView.alpha = 1
        product = nil
    }
}
