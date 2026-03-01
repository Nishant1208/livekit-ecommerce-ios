//
//  RoomViewController.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit

final class RoomViewController: UIViewController {

    // MARK: - Subviews

    private let controlsView = LiveKitControlsView()
    private let tabsVC       = ProductTabsViewController()
    private let videoPreview = LocalVideoPreviewView()

    // MARK: - ViewModel

    private let viewModel = RoomViewModel()

    // MARK: - Transition State (shared-element hero)

    private var pendingTransition: ProductDetailTransition?

    private var videoPreviewPlaced = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupLayout()
        bindViewModel()
        controlsView.update(isMicMuted: false)
        controlsView.update(isVideoEnabled: false)
        controlsView.update(connectionState: .connected)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabsVC.view.setNeedsLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Become nav delegate so we can intercept push/pop for hero transition
        navigationController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Restore default delegate when we're not visible
        if navigationController?.delegate === self {
            navigationController?.delegate = nil
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !videoPreviewPlaced, view.bounds.width > 0 else { return }
        videoPreviewPlaced = true
        videoPreview.placeInBottomTrailingCorner(of: view)
    }

    // MARK: - Public

    func cartButtonFrameInWindow() -> CGRect {
        controlsView.cartButtonFrameInWindow()
    }

    func animateCartBadgeBounce() {
        controlsView.animateCartBadgeBounce()
    }

    // MARK: - Layout

    private func setupLayout() {
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.delegate = self
        view.addSubview(controlsView)

        addChild(tabsVC)
        tabsVC.view.translatesAutoresizingMaskIntoConstraints = false
        tabsVC.delegate = self
        view.addSubview(tabsVC.view)
        tabsVC.didMove(toParent: self)

        view.addSubview(videoPreview)

        NSLayoutConstraint.activate([
            controlsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.heightAnchor.constraint(equalToConstant: 58),

            tabsVC.view.topAnchor.constraint(equalTo: controlsView.bottomAnchor),
            tabsVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabsVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabsVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        videoPreview.translatesAutoresizingMaskIntoConstraints = true
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.onConnectionStateChange = { [weak self] state in
            self?.controlsView.update(connectionState: state)
            if state == .disconnected { self?.handleUnexpectedDisconnect() }
        }
        viewModel.onMicStateChange   = { [weak self] m in self?.controlsView.update(isMicMuted: m) }
        viewModel.onVideoStateChange = { [weak self] v in self?.controlsView.update(isVideoEnabled: v) }
        viewModel.onVideoTrackReady  = { [weak self] t in self?.videoPreview.setTrack(t) }
        viewModel.onLeaveRoom        = { [weak self] in self?.navigationController?.popViewController(animated: true) }
    }

    // MARK: - Disconnect

    private func handleUnexpectedDisconnect() {
        let alert = UIAlertController(title: "Disconnected",
                                      message: "You have been disconnected from the room.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func confirmLeave() {
        let alert = UIAlertController(title: "Leave Room?",
                                      message: "You'll be disconnected from your shopping assistant.",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            UIView.animate(withDuration: 0.25) { self?.view.alpha = 0 } completion: { _ in
                self?.viewModel.leaveRoom()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = controlsView
        present(alert, animated: true)
    }
}

// MARK: - LiveKitControlsViewDelegate

extension RoomViewController: LiveKitControlsViewDelegate {
    func controlsViewDidTapMic(_ view: LiveKitControlsView)         { viewModel.toggleMic() }
    func controlsViewDidTapVideo(_ view: LiveKitControlsView)       { viewModel.toggleVideo() }
    func controlsViewDidTapFlipCamera(_ view: LiveKitControlsView)  { viewModel.flipCamera() }
    func controlsViewDidTapLeave(_ view: LiveKitControlsView)       { confirmLeave() }

    func controlsViewDidTapCart(_ view: LiveKitControlsView) {
        navigationController?.pushViewController(CartViewController(), animated: true)
    }
}

// MARK: - ProductTabsViewControllerDelegate

extension RoomViewController: ProductTabsViewControllerDelegate {

    func productTabs(_ vc: ProductTabsViewController,
                     didSelect product: Product,
                     sourceCell: ProductCardCell) {

        // Capture source image + frame (in window coords) for the shared-element transition
        let transition      = ProductDetailTransition()
        transition.direction   = .push
        transition.sourceImage = sourceCell.productImageView.image
        transition.sourceFrame = sourceCell.productImageView.convert(
            sourceCell.productImageView.bounds, to: nil
        )
        pendingTransition = transition

        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func productTabs(_ vc: ProductTabsViewController, didAddToCart product: Product) {
        CartManager.shared.add(product)
        controlsView.animateCartBadgeBounce()
    }
}

// MARK: - UINavigationControllerDelegate (hero transition)

extension RoomViewController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {

        if operation == .push, toVC is ProductDetailViewController {
            let t = pendingTransition ?? ProductDetailTransition()
            t.direction = .push
            return t
        }

        if operation == .pop, fromVC is ProductDetailViewController {
            // Reuse the same transition (same sourceFrame/image) for the pop
            let t = pendingTransition ?? ProductDetailTransition()
            t.direction = .pop
            return t
        }

        return nil  // use default animation for other transitions
    }
}
