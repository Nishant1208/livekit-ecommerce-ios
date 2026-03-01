//
//  CartViewController.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import Kingfisher

final class CartViewController: UIViewController {

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseId)
        tv.dataSource = self
        tv.delegate   = self
        tv.contentInset.bottom = 100
        return tv
    }()

    private let emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true

        let icon = UIImageView(image: UIImage(systemName: "cart"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = AppColors.textTertiary
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your cart is empty\nBrowse products to get started"
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0

        v.addSubview(icon)
        v.addSubview(label)
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: v.topAnchor),
            icon.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 56),
            icon.heightAnchor.constraint(equalToConstant: 56),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        return v
    }()

    private let bottomBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.surface
        return v
    }()

    private let totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = AppColors.textSecondary
        lbl.text = "Total"
        return lbl
    }()

    private let totalAmountLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 20, weight: .heavy)
        lbl.textColor = AppColors.textPrimary
        return lbl
    }()

    private lazy var checkoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Checkout", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.primary
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNav()
        setupLayout()
        observeCart()
        refreshUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        refreshUI()
    }

    // MARK: - Setup

    private func setupNav() {
        title = "My Cart"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.surface
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
        navigationController?.navigationBar.standardAppearance  = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = AppColors.accent

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        if !CartManager.shared.isEmpty {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Clear All",
                style: .plain,
                target: self,
                action: #selector(clearAll)
            )
            navigationItem.rightBarButtonItem?.tintColor = AppColors.error
        }
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(bottomBar)

        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = AppColors.separator
        bottomBar.addSubview(sep)
        bottomBar.addSubview(totalLabel)
        bottomBar.addSubview(totalAmountLabel)
        bottomBar.addSubview(checkoutButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateView.widthAnchor.constraint(equalToConstant: 240),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 100),

            sep.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            sep.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),

            totalLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 14),
            totalLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),

            totalAmountLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 2),
            totalAmountLabel.leadingAnchor.constraint(equalTo: totalLabel.leadingAnchor),

            checkoutButton.centerYAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 30),
            checkoutButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            checkoutButton.widthAnchor.constraint(equalToConstant: 130),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func observeCart() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: .cartDidChange,
            object: nil
        )
    }

    @objc private func cartDidChange() {
        refreshUI()
    }

    // MARK: - Refresh

    private func refreshUI() {
        let items = CartManager.shared.items
        emptyStateView.isHidden = !items.isEmpty
        tableView.isHidden      = items.isEmpty
        bottomBar.isHidden      = items.isEmpty

        totalAmountLabel.text = String(format: "$%.2f", CartManager.shared.totalAmount)

        tableView.reloadData()
        navigationItem.rightBarButtonItem = items.isEmpty ? nil : navigationItem.rightBarButtonItem
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func clearAll() {
        let alert = UIAlertController(title: "Clear Cart?", message: "Remove all items from cart.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            CartManager.shared.clear()
            self?.refreshUI()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func checkoutTapped() {
        ToastView.show(message: "Checkout coming soon!", icon: "bag.fill", iconColor: AppColors.accent, in: view, haptic: nil)
    }
}

// MARK: - TableView DataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CartManager.shared.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseId, for: indexPath) as! CartItemCell
        cell.configure(with: CartManager.shared.items[indexPath.row])
        cell.onQuantityChanged = { [weak self] item, newQty in
            CartManager.shared.setQuantity(newQty, for: item)
            self?.refreshUI()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CartManager.shared.remove(CartManager.shared.items[indexPath.row])
        }
    }
}

// MARK: - TableView Delegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }
}

// MARK: - CartItemCell

private final class CartItemCell: UITableViewCell {

    static let reuseId = "CartItemCell"

    var onQuantityChanged: ((CartItem, Int) -> Void)?
    private var item: CartItem?

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.surface
        v.layer.cornerRadius = 12
        return v
    }()

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = AppColors.surfaceElevated
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
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

    private lazy var minusButton: UIButton = makeQtyButton(icon: "minus")
    private lazy var plusButton: UIButton  = makeQtyButton(icon: "plus")

    private let qtyLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = AppColors.textPrimary
        lbl.textAlignment = .center
        lbl.widthAnchor.constraint(equalToConstant: 28).isActive = true
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        contentView.addSubview(cardView)
        [productImageView, nameLabel, priceLabel, minusButton, qtyLabel, plusButton].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            productImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 64),
            productImageView.heightAnchor.constraint(equalToConstant: 64),

            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            plusButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            plusButton.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),

            qtyLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor),
            qtyLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),

            minusButton.trailingAnchor.constraint(equalTo: qtyLabel.leadingAnchor),
            minusButton.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
        ])

        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped),  for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: CartItem) {
        self.item = item
        nameLabel.text = item.product.name
        priceLabel.text = String(format: "$%.2f", item.subtotal)
        qtyLabel.text = "\(item.quantity)"
        productImageView.kf.setImage(with: item.product.imageURL, options: [.transition(.fade(0.2))])
    }

    @objc private func minusTapped() {
        guard let item else { return }
        onQuantityChanged?(item, max(0, item.quantity - 1))
    }

    @objc private func plusTapped() {
        guard let item else { return }
        onQuantityChanged?(item, item.quantity + 1)
    }

    private func makeQtyButton(icon: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        btn.setImage(UIImage(systemName: icon, withConfiguration: cfg), for: .normal)
        btn.tintColor = AppColors.textPrimary
        btn.backgroundColor = AppColors.surfaceElevated
        btn.layer.cornerRadius = 12
        btn.widthAnchor.constraint(equalToConstant: 24).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return btn
    }
}
