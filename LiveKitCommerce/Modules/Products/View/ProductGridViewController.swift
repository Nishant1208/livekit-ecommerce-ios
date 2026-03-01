//
//  ProductGridViewController.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import Kingfisher

protocol ProductGridViewControllerDelegate: AnyObject {
    func productGrid(_ vc: ProductGridViewController, didSelect product: Product, cell: ProductCardCell)
    func productGrid(_ vc: ProductGridViewController, didAddToCart product: Product)
}

final class ProductGridViewController: UIViewController {

    enum Tab {
        case recommended, explore, wishlisted, recentlyViewed

        var title: String {
            switch self {
            case .recommended:   return "For You"
            case .explore:       return "Explore"
            case .wishlisted:    return "Wishlisted"
            case .recentlyViewed: return "Recent"
            }
        }
    }

    weak var delegate: ProductGridViewControllerDelegate?

    private let productTab: Tab
    private var products: [Product] = []

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.register(ProductCardCell.self, forCellWithReuseIdentifier: ProductCardCell.reuseId)
        cv.dataSource = self
        cv.delegate   = self
        cv.prefetchDataSource = self
        cv.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        return cv
    }()

    private let emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    // MARK: - Init

    init(tab: Tab) {
        self.productTab = tab
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
        setupEmptyState()
        observeManagers()
        loadProducts()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 220),
        ])
    }

    private func setupEmptyState() {
        let icon = UIImageView(image: UIImage(systemName: productTab == .wishlisted ? "heart.slash" : "clock.arrow.circlepath"))
        icon.tintColor = AppColors.textTertiary
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = productTab == .wishlisted
            ? "Your wishlist is empty\nTap ♡ on products you love"
            : "No recently viewed items\nBrowse products to get started"
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0

        emptyStateView.addSubview(icon)
        emptyStateView.addSubview(label)

        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            icon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalToConstant: 48),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
        ])
    }

    // MARK: - Compositional Layout

    private func makeLayout() -> UICollectionViewLayout {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                               heightDimension: .estimated(280))
        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(280))
        let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

        let section   = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Data

    private func loadProducts() {
        switch productTab {
        case .recommended:   products = ProductData.recommended
        case .explore:        products = ProductData.explore
        case .wishlisted:    products = WishlistManager.shared.wishlistedProducts
        case .recentlyViewed: products = RecentlyViewedManager.shared.products
        }
        refreshUI(animated: false)
    }

    private func reloadDynamic(animated: Bool = true) {
        switch productTab {
        case .wishlisted:    products = WishlistManager.shared.wishlistedProducts
        case .recentlyViewed: products = RecentlyViewedManager.shared.products
        default: return
        }
        refreshUI(animated: animated)
    }

    private func refreshUI(animated: Bool) {
        let isEmpty = products.isEmpty && (productTab == .wishlisted || productTab == .recentlyViewed)
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty

        if animated {
            UIView.transition(with: collectionView, duration: 0.25, options: .transitionCrossDissolve) {
                self.collectionView.reloadData()
            }
        } else {
            collectionView.reloadData()
        }
    }

    // MARK: - Observe Managers

    private func observeManagers() {
        WishlistManager.shared.onWishlistChanged = { [weak self] in
            guard let self, self.productTab == .wishlisted else { return }
            DispatchQueue.main.async { self.reloadDynamic() }
        }
        RecentlyViewedManager.shared.onProductsChanged = { [weak self] in
            guard let self, self.productTab == .recentlyViewed else { return }
            DispatchQueue.main.async { self.reloadDynamic() }
        }
    }

    // MARK: - Public

    func refreshIfNeeded() {
        reloadDynamic(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension ProductGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductCardCell.reuseId, for: indexPath) as! ProductCardCell
        cell.configure(with: products[indexPath.item])
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProductGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        RecentlyViewedManager.shared.trackView(product)
        let cell = collectionView.cellForItem(at: indexPath) as? ProductCardCell
        delegate?.productGrid(self, didSelect: product, cell: cell ?? ProductCardCell())
    }
}

// MARK: - Prefetching (lazy loading)

extension ProductGridViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { products[$0.item].imageURL as URL? }
        ImagePrefetcher(urls: urls).start()
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { products[$0.item].imageURL as URL? }
        ImagePrefetcher(urls: urls).stop()
    }
}

// MARK: - ProductCardCellDelegate

extension ProductGridViewController: ProductCardCellDelegate {
    func productCardCell(_ cell: ProductCardCell, didToggleWishlist product: Product) {
        // Wishlist badge in tab already observed via WishlistManager callback
    }
}
