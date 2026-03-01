//
//  CartViewController.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import Kingfisher

final class CartViewController: UIViewController {

    // MARK: - State

    /// Prevents a full table reload when only a quantity is changing (preserves cell animations).
    private var isUpdatingQuantity = false

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
        return tv
    }()

    // MARK: Empty State

    private lazy var emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true

        let icon = UIImageView(image: UIImage(systemName: "cart"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = AppColors.textTertiary
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Your cart is empty"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Browse products and add something you love"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = AppColors.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let continueBtn = UIButton(type: .system)
        continueBtn.translatesAutoresizingMaskIntoConstraints = false
        continueBtn.setTitle("Continue Shopping", for: .normal)
        continueBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        continueBtn.setTitleColor(.white, for: .normal)
        continueBtn.backgroundColor = AppColors.primary
        continueBtn.layer.cornerRadius = 12
        continueBtn.addTarget(self, action: #selector(continueShopping), for: .touchUpInside)

        v.addSubview(icon)
        v.addSubview(titleLabel)
        v.addSubview(subtitleLabel)
        v.addSubview(continueBtn)

        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: v.topAnchor),
            icon.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 72),
            icon.heightAnchor.constraint(equalToConstant: 72),

            titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor),

            continueBtn.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            continueBtn.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            continueBtn.widthAnchor.constraint(equalToConstant: 200),
            continueBtn.heightAnchor.constraint(equalToConstant: 48),
            continueBtn.bottomAnchor.constraint(equalTo: v.bottomAnchor),
        ])
        return v
    }()

    // MARK: Summary Card

    private let summaryCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.surface
        return v
    }()

    private let topSeparator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.separator
        return v
    }()

    private let itemsTitleLabel: UILabel = makeRowLabel(style: .body)
    private let itemsValueLabel: UILabel = makeRowLabel(style: .body, alignment: .right)

    private let discountRow: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let discountTitleLabel: UILabel = makeRowLabel(style: .body)
    private let discountValueLabel: UILabel = makeRowLabel(style: .body, alignment: .right)

    private let divider: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.separator
        return v
    }()

    private let totalTitleLabel: UILabel = makeRowLabel(style: .total)
    private let totalValueLabel: UILabel  = makeRowLabel(style: .total, alignment: .right)

    private lazy var checkoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Proceed to Checkout", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.primary
        btn.layer.cornerRadius = 14
        btn.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var continueShoppingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Continue Shopping", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(AppColors.accent, for: .normal)
        btn.addTarget(self, action: #selector(continueShopping), for: .touchUpInside)
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
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance  = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = AppColors.accent

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(summaryCard)

        // Summary card internals
        let discountTitle = discountTitleLabel
        let discountValue = discountValueLabel
        discountTitle.text = "Savings"
        discountValue.textColor = AppColors.success

        discountRow.addSubview(discountTitle)
        discountRow.addSubview(discountValue)

        summaryCard.addSubview(topSeparator)
        summaryCard.addSubview(itemsTitleLabel)
        summaryCard.addSubview(itemsValueLabel)
        summaryCard.addSubview(discountRow)
        summaryCard.addSubview(divider)
        summaryCard.addSubview(totalTitleLabel)
        summaryCard.addSubview(totalValueLabel)
        summaryCard.addSubview(checkoutButton)
        summaryCard.addSubview(continueShoppingButton)

        totalTitleLabel.text = "Total"

        NSLayoutConstraint.activate([
            // Table fills view; bottom inset set dynamically after layout
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyStateView.widthAnchor.constraint(equalToConstant: 280),

            // Summary card pinned to bottom
            summaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            topSeparator.topAnchor.constraint(equalTo: summaryCard.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),

            // Items row
            itemsTitleLabel.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 16),
            itemsTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            itemsValueLabel.centerYAnchor.constraint(equalTo: itemsTitleLabel.centerYAnchor),
            itemsValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),

            // Discount row
            discountRow.topAnchor.constraint(equalTo: itemsTitleLabel.bottomAnchor, constant: 8),
            discountRow.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            discountRow.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            discountRow.heightAnchor.constraint(equalToConstant: 20),

            discountTitle.leadingAnchor.constraint(equalTo: discountRow.leadingAnchor),
            discountTitle.centerYAnchor.constraint(equalTo: discountRow.centerYAnchor),
            discountValue.trailingAnchor.constraint(equalTo: discountRow.trailingAnchor),
            discountValue.centerYAnchor.constraint(equalTo: discountRow.centerYAnchor),

            // Divider
            divider.topAnchor.constraint(equalTo: discountRow.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            // Total row
            totalTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            totalTitleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            totalValueLabel.centerYAnchor.constraint(equalTo: totalTitleLabel.centerYAnchor),
            totalValueLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),

            // Checkout button
            checkoutButton.topAnchor.constraint(equalTo: totalTitleLabel.bottomAnchor, constant: 16),
            checkoutButton.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            checkoutButton.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            checkoutButton.heightAnchor.constraint(equalToConstant: 52),

            // Continue shopping
            continueShoppingButton.topAnchor.constraint(equalTo: checkoutButton.bottomAnchor, constant: 4),
            continueShoppingButton.centerXAnchor.constraint(equalTo: summaryCard.centerXAnchor),
            continueShoppingButton.heightAnchor.constraint(equalToConstant: 40),
            continueShoppingButton.bottomAnchor.constraint(equalTo: summaryCard.safeAreaLayoutGuide.bottomAnchor, constant: -4),
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
        if isUpdatingQuantity {
            updateSummary()
        } else {
            refreshUI()
        }
    }

    // MARK: - Refresh

    private func refreshUI() {
        let items = CartManager.shared.items
        let hasItems = !items.isEmpty

        emptyStateView.isHidden = hasItems
        tableView.isHidden      = !hasItems
        summaryCard.isHidden    = !hasItems

        navigationItem.rightBarButtonItem = hasItems
            ? UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAll))
            : nil
        navigationItem.rightBarButtonItem?.tintColor = AppColors.error

        // Adjust table bottom inset to clear the summary card
        tableView.layoutIfNeeded()
        tableView.contentInset.bottom = summaryCard.frame.height + 8

        tableView.reloadData()
        updateSummary()
    }

    private func updateSummary() {
        let manager  = CartManager.shared
        let count    = manager.itemCount
        let savings  = manager.totalSavings
        let total    = manager.totalAmount

        itemsTitleLabel.text = "Items (\(count))"
        itemsValueLabel.text  = String(format: "$%.2f", total + savings)

        let hasSavings = savings > 0.005
        UIView.animate(withDuration: 0.2) {
            self.discountRow.alpha      = hasSavings ? 1 : 0
            self.discountRow.isHidden   = !hasSavings
        }
        discountValueLabel.text = String(format: "-$%.2f", savings)

        UIView.transition(with: totalValueLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.totalValueLabel.text = String(format: "$%.2f", total)
        })
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func continueShopping() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func clearAll() {
        let alert = UIAlertController(title: "Clear Cart?", message: "All items will be removed.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            let snapshot = CartManager.shared.items
            CartManager.shared.clear()
            guard let self else { return }
            ToastView.showWithAction(
                message: "Cart cleared",
                actionTitle: "Undo",
                icon: "trash.fill",
                iconColor: AppColors.error,
                in: self.view
            ) {
                snapshot.forEach { CartManager.shared.restore($0) }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func checkoutTapped() {
        // Button press feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.checkoutButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.checkoutButton.transform = .identity }
        }
        showCheckoutSuccess()
    }

    // MARK: - Checkout Success Overlay

    private func showCheckoutSuccess() {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        overlay.alpha = 0
        view.addSubview(overlay)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColors.surface
        card.layer.cornerRadius = 24
        card.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        overlay.addSubview(card)

        let checkIcon = UIImageView()
        checkIcon.translatesAutoresizingMaskIntoConstraints = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 56, weight: .medium)
        checkIcon.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg)
        checkIcon.tintColor = AppColors.success
        checkIcon.contentMode = .scaleAspectFit
        checkIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        let titleLbl = UILabel()
        titleLbl.text = "Order Placed!"
        titleLbl.font = .systemFont(ofSize: 22, weight: .bold)
        titleLbl.textColor = AppColors.textPrimary
        titleLbl.textAlignment = .center

        let subtitleLbl = UILabel()
        subtitleLbl.text = "Your order has been placed successfully.\nSit back and relax!"
        subtitleLbl.font = .systemFont(ofSize: 14)
        subtitleLbl.textColor = AppColors.textSecondary
        subtitleLbl.textAlignment = .center
        subtitleLbl.numberOfLines = 0

        let continueBtn = UIButton(type: .system)
        continueBtn.setTitle("Continue Shopping", for: .normal)
        continueBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        continueBtn.setTitleColor(.white, for: .normal)
        continueBtn.backgroundColor = AppColors.primary
        continueBtn.layer.cornerRadius = 14

        [checkIcon, titleLbl, subtitleLbl, continueBtn].forEach {
            ($0 as UIView).translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 300),

            checkIcon.topAnchor.constraint(equalTo: card.topAnchor, constant: 36),
            checkIcon.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            checkIcon.widthAnchor.constraint(equalToConstant: 80),
            checkIcon.heightAnchor.constraint(equalToConstant: 80),

            titleLbl.topAnchor.constraint(equalTo: checkIcon.bottomAnchor, constant: 20),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            titleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            subtitleLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            subtitleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            subtitleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            continueBtn.topAnchor.constraint(equalTo: subtitleLbl.bottomAnchor, constant: 28),
            continueBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            continueBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            continueBtn.heightAnchor.constraint(equalToConstant: 52),
            continueBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),
        ])

        // Action
        continueBtn.addAction(UIAction { [weak self, weak overlay] _ in
            CartManager.shared.clear()
            UIView.animate(withDuration: 0.25, animations: { overlay?.alpha = 0 }) { _ in
                overlay?.removeFromSuperview()
                self?.navigationController?.popViewController(animated: true)
            }
        }, for: .touchUpInside)

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Animate in
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, animations: {
            overlay.alpha = 1
            card.transform = .identity
        })

        // Bounce the checkmark icon with a spring delay
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, animations: {
            checkIcon.transform = .identity
        })
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

        cell.onQuantityChanged = { [weak self, weak tableView] item, newQty in
            guard let self, let tableView else { return }
            self.isUpdatingQuantity = true
            CartManager.shared.setQuantity(newQty, for: item)
            self.isUpdatingQuantity = false
            // Reload just this row after the cell's own animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }

        cell.onRemove = { [weak self] item in
            guard let self else { return }
            let snapshot = item
            CartManager.shared.remove(item)
            ToastView.showWithAction(
                message: "Item removed",
                actionTitle: "Undo",
                icon: "trash.fill",
                iconColor: AppColors.error,
                in: self.view
            ) {
                CartManager.shared.restore(snapshot)
            }
        }

        return cell
    }
}

// MARK: - TableView Delegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 108 }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            let item = CartManager.shared.items[indexPath.row]
            CartManager.shared.remove(item)
            ToastView.showWithAction(
                message: "Item removed",
                actionTitle: "Undo",
                icon: "trash.fill",
                iconColor: AppColors.error,
                in: self.view
            ) {
                CartManager.shared.restore(item)
            }
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

// MARK: - Factory Helpers

private extension CartViewController {
    enum RowStyle { case body, total }

    static func makeRowLabel(style: RowStyle, alignment: NSTextAlignment = .left) -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = alignment
        switch style {
        case .body:
            lbl.font = .systemFont(ofSize: 14, weight: .regular)
            lbl.textColor = AppColors.textSecondary
        case .total:
            lbl.font = .systemFont(ofSize: 18, weight: .heavy)
            lbl.textColor = AppColors.textPrimary
        }
        return lbl
    }
}

// MARK: - CartItemCell

private final class CartItemCell: UITableViewCell {

    static let reuseId = "CartItemCell"

    var onQuantityChanged: ((CartItem, Int) -> Void)?
    var onRemove: ((CartItem) -> Void)?
    private var item: CartItem?

    // MARK: Views

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.surface
        v.layer.cornerRadius = 14
        return v
    }()

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = AppColors.surfaceElevated
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = AppColors.textPrimary
        lbl.numberOfLines = 2
        return lbl
    }()

    private let unitPriceLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = AppColors.textSecondary
        return lbl
    }()

    private lazy var trashButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        btn.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        btn.tintColor = AppColors.error
        btn.backgroundColor = AppColors.error.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 14
        btn.widthAnchor.constraint(equalToConstant: 28).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 28).isActive = true
        btn.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var minusButton: UIButton = makeQtyButton(icon: "minus")
    private lazy var plusButton: UIButton  = makeQtyButton(icon: "plus")

    private let qtyLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = AppColors.textPrimary
        lbl.textAlignment = .center
        lbl.widthAnchor.constraint(equalToConstant: 32).isActive = true
        return lbl
    }()

    private let subtotalLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = AppColors.accent
        lbl.textAlignment = .right
        return lbl
    }()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        contentView.addSubview(cardView)

        [productImageView, nameLabel, unitPriceLabel, trashButton,
         minusButton, qtyLabel, plusButton, subtotalLabel].forEach { cardView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            // Thumbnail
            productImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 70),
            productImageView.heightAnchor.constraint(equalToConstant: 70),

            // Trash (top-right)
            trashButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            trashButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // Name (below trash, beside image)
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trashButton.leadingAnchor, constant: -8),

            // Unit price
            unitPriceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            unitPriceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            // Qty selector (bottom-left of content area)
            minusButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            minusButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            qtyLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor),
            qtyLabel.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),

            plusButton.leadingAnchor.constraint(equalTo: qtyLabel.trailingAnchor),
            plusButton.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),

            // Subtotal (bottom-right)
            subtotalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            subtotalLabel.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
        ])

        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped),  for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Configure

    func configure(with item: CartItem) {
        self.item = item
        nameLabel.text     = item.product.name
        unitPriceLabel.text = String(format: "$%.2f / item", item.product.price)
        subtotalLabel.text  = String(format: "$%.2f", item.subtotal)
        qtyLabel.text       = "\(item.quantity)"
        minusButton.alpha   = item.quantity <= 1 ? 0.4 : 1.0
        productImageView.kf.setImage(with: item.product.imageURL, options: [.transition(.fade(0.2))])
    }

    // MARK: Actions

    @objc private func minusTapped() {
        guard let item else { return }
        animateQtyChange()
        onQuantityChanged?(item, max(0, item.quantity - 1))
    }

    @objc private func plusTapped() {
        guard let item else { return }
        animateQtyChange()
        onQuantityChanged?(item, item.quantity + 1)
    }

    @objc private func removeTapped() {
        guard let item else { return }
        // Button bounce
        UIView.animate(withDuration: 0.1, animations: { self.trashButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85) }) { _ in
            UIView.animate(withDuration: 0.1) { self.trashButton.transform = .identity }
        }
        onRemove?(item)
    }

    private func animateQtyChange() {
        UIView.animate(withDuration: 0.1, animations: {
            self.qtyLabel.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, animations: {
                self.qtyLabel.transform = .identity
            })
        }
    }

    // MARK: Factory

    private func makeQtyButton(icon: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        btn.setImage(UIImage(systemName: icon, withConfiguration: cfg), for: .normal)
        btn.tintColor = AppColors.textPrimary
        btn.backgroundColor = AppColors.surfaceElevated
        btn.layer.cornerRadius = 13
        btn.widthAnchor.constraint(equalToConstant: 26).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 26).isActive = true
        return btn
    }
}
