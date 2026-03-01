//
//  ProductDetailViewController.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import Kingfisher

final class ProductDetailViewController: UIViewController {

    // MARK: - Product

    private let product: Product

    // MARK: - Exposed for shared-element transition

    let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode   = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = AppColors.surfaceElevated
        return iv
    }()

    // MARK: - Scroll Content

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Hero Overlay Buttons

    private lazy var backButton: UIButton = {
        let btn = makeOverlayButton(iconName: "chevron.left")
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var wishlistButton: UIButton = {
        let btn = makeOverlayButton(iconName: "heart.fill")
        btn.addTarget(self, action: #selector(wishlistTapped), for: .touchUpInside)
        return btn
    }()

    // Gradient at the bottom of the hero image
    private let heroGradient: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.5).cgColor]
        g.locations = [0.5, 1.0]
        return g
    }()

    // MARK: - Detail Labels

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = AppColors.textPrimary
        lbl.numberOfLines = 0
        return lbl
    }()

    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 24, weight: .heavy)
        lbl.textColor = AppColors.accent
        return lbl
    }()

    private let originalPriceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = AppColors.textTertiary
        lbl.isHidden = true
        return lbl
    }()

    private let discountBadge: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = .white
        lbl.backgroundColor = AppColors.error
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 8
        lbl.clipsToBounds = true
        lbl.isHidden = true
        return lbl
    }()

    private let stockBadge: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .semibold)
        lbl.layer.cornerRadius = 10
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        return lbl
    }()

    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = AppColors.textSecondary
        lbl.numberOfLines = 0
        return lbl
    }()

    // MARK: - Add To Cart

    private let bottomBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.background
        return v
    }()

    private lazy var addToCartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.primary
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - State

    private var isInCart: Bool { CartManager.shared.items.contains { $0.product == product } }

    // MARK: - Init

    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradient.frame = heroImageView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateCartButtonState()
        NotificationCenter.default.addObserver(
            self, selector: #selector(cartDidChange),
            name: .cartDidChange, object: nil
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .cartDidChange, object: nil)
    }

    @objc private func cartDidChange() {
        updateCartButtonState()
    }

    // MARK: - Layout

    private let heroHeight: CGFloat = 320

    private func setupLayout() {
        // --- Scroll view ---
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // --- Hero image ---
        contentView.addSubview(heroImageView)
        heroImageView.layer.addSublayer(heroGradient)

        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: heroHeight),
        ])

        // --- Hero overlay buttons (back + wishlist) ---
        // Add to view (not contentView) so they stay fixed even when scrolling
        [backButton, wishlistButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            // Use safeAreaLayoutGuide — valid at viewDidLoad, insets resolved at layout time
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            wishlistButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            wishlistButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            wishlistButton.widthAnchor.constraint(equalToConstant: 40),
            wishlistButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        // --- Detail content stack ---
        let priceRow = UIStackView(arrangedSubviews: [priceLabel, originalPriceLabel, discountBadge, UIView()])
        priceRow.axis = .horizontal
        priceRow.spacing = 8
        priceRow.alignment = .center

        // Wrap badge in a leading row so it hugs content width instead of
        // stretching full-width (which would break the cornerRadius appearance)
        stockBadge.setContentHuggingPriority(.required, for: .horizontal)
        stockBadge.heightAnchor.constraint(equalToConstant: 28).isActive = true
        let stockRow = UIStackView(arrangedSubviews: [stockBadge, UIView()])
        stockRow.axis = .horizontal
        stockRow.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [nameLabel, priceRow, stockRow, makeSeparator(), descriptionLabel])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.setCustomSpacing(16, after: nameLabel)
        mainStack.setCustomSpacing(8, after: priceRow)
        mainStack.setCustomSpacing(16, after: stockRow)
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -110),
        ])

        // --- Bottom bar (fixed) ---
        view.addSubview(bottomBar)
        bottomBar.addSubview(addToCartButton)

        let topSep = UIView()
        topSep.translatesAutoresizingMaskIntoConstraints = false
        topSep.backgroundColor = AppColors.separator
        bottomBar.addSubview(topSep)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 90),

            topSep.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            topSep.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            topSep.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            topSep.heightAnchor.constraint(equalToConstant: 0.5),

            addToCartButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            addToCartButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            addToCartButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            addToCartButton.heightAnchor.constraint(equalToConstant: 52),
        ])

        // Scroll view bottom inset so content isn't hidden behind bar
        scrollView.contentInset.bottom = 90
    }

    // MARK: - Configure

    private func configure() {
        nameLabel.text = product.name
        priceLabel.text = String(format: "$%.2f", product.price)
        descriptionLabel.text = product.description

        if let original = product.originalPrice, let pct = product.discountPercentage {
            let str = NSAttributedString(
                string: String(format: "$%.2f", original),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.attributedText = str
            originalPriceLabel.isHidden = false
            discountBadge.text = " -\(pct)% "
            discountBadge.isHidden = false
        }

        configureStockBadge()
        updateWishlistAppearance()
        updateCartButtonState()
        loadHeroImage()
    }

    private func configureStockBadge() {
        switch product.stockStatus {
        case .inStock:
            stockBadge.text = "  ✓  In Stock  "
            stockBadge.textColor = AppColors.success
            stockBadge.backgroundColor = AppColors.success.withAlphaComponent(0.12)
        case .lowStock(let n):
            stockBadge.text = "  ⚡  Only \(n) left  "
            stockBadge.textColor = AppColors.warning
            stockBadge.backgroundColor = AppColors.warning.withAlphaComponent(0.12)
        case .outOfStock:
            stockBadge.text = "  ✕  Out of Stock  "
            stockBadge.textColor = AppColors.error
            stockBadge.backgroundColor = AppColors.error.withAlphaComponent(0.12)
        }
    }

    private func updateWishlistAppearance() {
        let wishlisted = WishlistManager.shared.isWishlisted(product)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let icon = UIImage(systemName: wishlisted ? "heart.fill" : "heart", withConfiguration: cfg)
        wishlistButton.setImage(icon, for: .normal)
        wishlistButton.tintColor = wishlisted ? AppColors.wishlistActive : .white
    }

    private func updateCartButtonState() {
        let title = isInCart ? "Go to Cart" : "Add to Cart"
        let icon  = isInCart ? "cart.fill" : "cart.badge.plus"
        let cfg   = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        addToCartButton.setTitle("  \(title)", for: .normal)
        addToCartButton.setImage(UIImage(systemName: icon, withConfiguration: cfg), for: .normal)
        addToCartButton.tintColor = .white
        addToCartButton.backgroundColor = isInCart ? AppColors.success : AppColors.primary
    }

    private func loadHeroImage() {
        heroImageView.kf.setImage(with: product.imageURL, options: [.transition(.fade(0.2))])
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func wishlistTapped() {
        let isNowWishlisted = WishlistManager.shared.toggle(product)
        updateWishlistAppearance()
        animateWishlistButton()

        if isNowWishlisted {
            ToastView.show(
                message: "Added to Wishlist",
                icon: "heart.fill",
                iconColor: AppColors.wishlistActive,
                in: view,
                haptic: .success
            )
        } else {
            ToastView.show(
                message: "Removed from Wishlist",
                icon: "heart.slash",
                iconColor: AppColors.textSecondary,
                in: view,
                haptic: nil
            )
        }
    }

    @objc private func addToCartTapped() {
        if isInCart {
            // Button shows "Go to Cart" — user explicitly chose to navigate
            navigateToCart()
            return
        }

        CartManager.shared.add(product)
        animateAddToCartButton()
        animateItemFlyToCart()
        // Button updates to "Go to Cart" after fly animation lands
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.updateCartButtonState()
        }
    }

    // MARK: - Animations

    private func animateWishlistButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.wishlistButton.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, animations: {
                self.wishlistButton.transform = .identity
            })
        })
    }

    private func animateAddToCartButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.addToCartButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, animations: {
                self.addToCartButton.transform = .identity
            })
        })

        // Success state: show checkmark briefly
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        addToCartButton.setTitle("  Added!", for: .normal)
        addToCartButton.setImage(UIImage(systemName: "checkmark", withConfiguration: cfg), for: .normal)
        addToCartButton.backgroundColor = AppColors.success

        UIView.transition(with: addToCartButton, duration: 0.2, options: .transitionCrossDissolve) {}
    }

    private func animateItemFlyToCart() {
        guard
            let roomVC = navigationController?.viewControllers.first(where: { $0 is RoomViewController }) as? RoomViewController,
            let window = view.window
        else { return }

        let targetFrame  = roomVC.cartButtonFrameInWindow()
        let sourceCenter = heroImageView.convert(
            CGPoint(x: heroImageView.bounds.midX, y: heroImageView.bounds.midY), to: nil
        )

        // Circular snapshot
        let size: CGFloat = 50
        let snapshot = UIView()
        snapshot.frame = CGRect(x: sourceCenter.x - size / 2, y: sourceCenter.y - size / 2,
                                width: size, height: size)
        snapshot.layer.cornerRadius = size / 2
        snapshot.clipsToBounds      = true
        snapshot.layer.borderColor  = AppColors.primary.cgColor
        snapshot.layer.borderWidth  = 2

        let imgView = UIImageView(frame: snapshot.bounds)
        imgView.image        = heroImageView.image
        imgView.contentMode  = .scaleAspectFill
        imgView.clipsToBounds = true
        snapshot.addSubview(imgView)
        window.addSubview(snapshot)

        // Bezier curved path: arc over and toward cart
        let endPoint  = CGPoint(x: targetFrame.midX, y: targetFrame.midY)
        let ctrl1     = CGPoint(x: sourceCenter.x - 60, y: sourceCenter.y - 180)
        let ctrl2     = CGPoint(x: endPoint.x, y: endPoint.y - 80)
        let path      = UIBezierPath()
        path.move(to: sourceCenter)
        path.addCurve(to: endPoint, controlPoint1: ctrl1, controlPoint2: ctrl2)

        let posAnim      = CAKeyframeAnimation(keyPath: "position")
        posAnim.path     = path.cgPath
        posAnim.duration = 0.65
        posAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let scaleAnim     = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.toValue = 0.15
        scaleAnim.duration = 0.65

        let fadeAnim          = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue    = 1.0
        fadeAnim.toValue      = 0.0
        fadeAnim.beginTime    = 0.45
        fadeAnim.duration     = 0.2

        let group              = CAAnimationGroup()
        group.animations       = [posAnim, scaleAnim, fadeAnim]
        group.duration         = 0.65
        group.fillMode         = .forwards
        group.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            snapshot.removeFromSuperview()
            roomVC.animateCartBadgeBounce()
        }
        snapshot.layer.add(group, forKey: "fly")
        CATransaction.commit()

        // Haptic impact as item "lands"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - Navigation

    private func navigateToCart() {
        let cartVC = CartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }

    // MARK: - Helpers

    private func makeOverlayButton(iconName: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius  = 20
        btn.clipsToBounds       = true
        btn.tintColor           = .white
        // Simple semi-transparent background — reliable across all iOS versions.
        // UIVisualEffectView inside UIButton causes the vibrancy contentView to
        // overlay the button's own imageView, making the icon invisible.
        btn.backgroundColor = UIColor(white: 0, alpha: 0.50)

        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
        return btn
    }

    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = AppColors.separator
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }
}
