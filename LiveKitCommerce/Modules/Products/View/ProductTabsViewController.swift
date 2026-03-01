//
//  ProductTabsViewController.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit

protocol ProductTabsViewControllerDelegate: AnyObject {
    func productTabs(_ vc: ProductTabsViewController, didSelect product: Product, sourceCell: ProductCardCell)
    func productTabs(_ vc: ProductTabsViewController, didAddToCart product: Product)
}

final class ProductTabsViewController: UIViewController {

    weak var delegate: ProductTabsViewControllerDelegate?

    // MARK: - Tabs

    private let tabs: [ProductGridViewController.Tab] = [
        .recommended, .explore, .wishlisted, .recentlyViewed
    ]
    private var selectedIndex = 0

    // MARK: - Tab Bar UI

    private let tabBarContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.surface
        return v
    }()

    private var tabButtons: [UIButton] = []

    private let indicatorView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.accent
        v.layer.cornerRadius = 2
        return v
    }()

    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorWidth: NSLayoutConstraint?

    // MARK: - Page Scroll

    private let pageScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = false
        return sv
    }()

    private let pageStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var gridControllers: [ProductGridViewController] = tabs.map {
        let vc = ProductGridViewController(tab: $0)
        vc.delegate = self
        return vc
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupTabBar()
        setupPageArea()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateIndicator(animated: false)
    }

    // MARK: - Tab Bar Setup

    private func setupTabBar() {
        view.addSubview(tabBarContainerView)

        NSLayoutConstraint.activate([
            tabBarContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            tabBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarContainerView.heightAnchor.constraint(equalToConstant: 50),
        ])

        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        tabBarContainerView.addSubview(buttonStack)
        tabBarContainerView.addSubview(indicatorView)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: tabBarContainerView.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: tabBarContainerView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: tabBarContainerView.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: tabBarContainerView.bottomAnchor, constant: -3),

            indicatorView.bottomAnchor.constraint(equalTo: tabBarContainerView.bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 3),
        ])

        indicatorLeading = indicatorView.leadingAnchor.constraint(equalTo: tabBarContainerView.leadingAnchor)
        indicatorWidth   = indicatorView.widthAnchor.constraint(equalToConstant: 80)
        indicatorLeading?.isActive = true
        indicatorWidth?.isActive   = true

        for (i, tab) in tabs.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(tab.title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: i == 0 ? .semibold : .regular)
            btn.setTitleColor(i == 0 ? AppColors.accent : AppColors.textSecondary, for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            buttonStack.addArrangedSubview(btn)
            tabButtons.append(btn)
        }

        // Bottom separator
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = AppColors.separator
        tabBarContainerView.addSubview(sep)
        NSLayoutConstraint.activate([
            sep.bottomAnchor.constraint(equalTo: tabBarContainerView.bottomAnchor),
            sep.leadingAnchor.constraint(equalTo: tabBarContainerView.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: tabBarContainerView.trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    // MARK: - Page Area Setup

    private func setupPageArea() {
        view.addSubview(pageScrollView)
        pageScrollView.addSubview(pageStackView)
        pageScrollView.delegate = self

        NSLayoutConstraint.activate([
            pageScrollView.topAnchor.constraint(equalTo: tabBarContainerView.bottomAnchor),
            pageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageStackView.topAnchor.constraint(equalTo: pageScrollView.topAnchor),
            pageStackView.leadingAnchor.constraint(equalTo: pageScrollView.leadingAnchor),
            pageStackView.trailingAnchor.constraint(equalTo: pageScrollView.trailingAnchor),
            pageStackView.bottomAnchor.constraint(equalTo: pageScrollView.bottomAnchor),
            pageStackView.heightAnchor.constraint(equalTo: pageScrollView.heightAnchor),
        ])

        for vc in gridControllers {
            addChild(vc)
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            pageStackView.addArrangedSubview(container)
            // Must be activated AFTER addArrangedSubview so container shares a common ancestor
            container.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            container.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: container.topAnchor),
                vc.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                vc.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
            vc.didMove(toParent: self)
        }
    }

    // MARK: - Tab Selection

    @objc private func tabTapped(_ sender: UIButton) {
        selectTab(at: sender.tag, animated: true, scroll: true)
    }

    private func selectTab(at index: Int, animated: Bool, scroll: Bool) {
        guard index != selectedIndex || !animated else {
            selectedIndex = index
            updateTabStyles()
            updateIndicator(animated: animated)
            if scroll { scrollPage(to: index, animated: animated) }
            return
        }
        selectedIndex = index
        updateTabStyles()
        updateIndicator(animated: animated)
        if scroll { scrollPage(to: index, animated: animated) }
        gridControllers[index].refreshIfNeeded()
    }

    private func updateTabStyles() {
        for (i, btn) in tabButtons.enumerated() {
            let active = i == selectedIndex
            UIView.animate(withDuration: 0.2) {
                btn.titleLabel?.font = .systemFont(ofSize: 13, weight: active ? .semibold : .regular)
                btn.setTitleColor(active ? AppColors.accent : AppColors.textSecondary, for: .normal)
            }
        }
    }

    private func updateIndicator(animated: Bool) {
        guard !tabButtons.isEmpty,
              selectedIndex < tabButtons.count else { return }

        let btn = tabButtons[selectedIndex]
        let tabWidth = tabBarContainerView.bounds.width / CGFloat(tabs.count)
        let indicatorW = tabWidth * 0.5
        let x = tabWidth * CGFloat(selectedIndex) + (tabWidth - indicatorW) / 2

        indicatorLeading?.constant = x
        indicatorWidth?.constant   = indicatorW

        if animated {
            UIView.animate(
                withDuration: 0.3, 
                delay: 0.2,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.4
            ) { self.tabBarContainerView.layoutIfNeeded() }
        } else {
            tabBarContainerView.layoutIfNeeded()
        }
        _ = btn
    }

    private func scrollPage(to index: Int, animated: Bool) {
        let x = pageScrollView.bounds.width * CGFloat(index)
        pageScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
}

// MARK: - UIScrollViewDelegate

extension ProductTabsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0 else { return }
        let pageWidth = scrollView.bounds.width
        let page = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        let clamped = max(0, min(page, tabs.count - 1))
        if clamped != selectedIndex {
            selectedIndex = clamped
            updateTabStyles()
            updateIndicator(animated: true)
        }
    }
}

// MARK: - ProductGridViewControllerDelegate

extension ProductTabsViewController: ProductGridViewControllerDelegate {
    func productGrid(_ vc: ProductGridViewController, didSelect product: Product, cell: ProductCardCell) {
        delegate?.productTabs(self, didSelect: product, sourceCell: cell)
    }

    func productGrid(_ vc: ProductGridViewController, didAddToCart product: Product) {
        delegate?.productTabs(self, didAddToCart: product)
    }
}
