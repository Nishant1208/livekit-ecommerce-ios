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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupLayout()
        bindViewModel()
        // Initial mic state: unmuted (audio published on landing)
        controlsView.update(isMicMuted: false)
        controlsView.update(isVideoEnabled: false)
        controlsView.update(connectionState: .connected)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Refresh dynamic tabs
        tabsVC.view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if videoPreview.superview != nil && videoPreview.center == .zero {
            videoPreview.placeInBottomTrailingCorner(of: view)
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.delegate = self
        view.addSubview(controlsView)

        // Product tabs fill everything below the controls bar
        addChild(tabsVC)
        tabsVC.view.translatesAutoresizingMaskIntoConstraints = false
        tabsVC.delegate = self
        view.addSubview(tabsVC.view)
        tabsVC.didMove(toParent: self)

        // Floating video preview (above everything)
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
            if state == .disconnected {
                self?.handleUnexpectedDisconnect()
            }
        }

        viewModel.onMicStateChange = { [weak self] isMuted in
            self?.controlsView.update(isMicMuted: isMuted)
        }

        viewModel.onVideoStateChange = { [weak self] isEnabled in
            self?.controlsView.update(isVideoEnabled: isEnabled)
        }

        viewModel.onVideoTrackReady = { [weak self] track in
            self?.videoPreview.setTrack(track)
        }

        viewModel.onLeaveRoom = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Unexpected Disconnect

    private func handleUnexpectedDisconnect() {
        let alert = UIAlertController(
            title: "Disconnected",
            message: "You have been disconnected from the room.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Go Back", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    // MARK: - Leave Confirmation

    private func confirmLeave() {
        let alert = UIAlertController(
            title: "Leave Room?",
            message: "You'll be disconnected from your shopping assistant.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            self?.animateLeaveAndDisconnect()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = controlsView
        present(alert, animated: true)
    }

    private func animateLeaveAndDisconnect() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.viewModel.leaveRoom()
        })
    }
}

// MARK: - LiveKitControlsViewDelegate

extension RoomViewController: LiveKitControlsViewDelegate {

    func controlsViewDidTapMic(_ view: LiveKitControlsView) {
        viewModel.toggleMic()
    }

    func controlsViewDidTapVideo(_ view: LiveKitControlsView) {
        viewModel.toggleVideo()
    }

    func controlsViewDidTapFlipCamera(_ view: LiveKitControlsView) {
        viewModel.flipCamera()
    }

    func controlsViewDidTapLeave(_ view: LiveKitControlsView) {
        confirmLeave()
    }

    func controlsViewDidTapCart(_ view: LiveKitControlsView) {
        // TODO: Navigate to CartViewController (implemented in next phase)
        print("[RoomVC] Navigate to Cart")
    }
}

// MARK: - ProductTabsViewControllerDelegate

extension RoomViewController: ProductTabsViewControllerDelegate {

    func productTabs(_ vc: ProductTabsViewController,
                     didSelect product: Product,
                     sourceCell: ProductCardCell) {
        // TODO: Navigate to ProductDetailViewController with shared element transition
        print("[RoomVC] Navigate to Product Detail: \(product.name)")
    }

    func productTabs(_ vc: ProductTabsViewController, didAddToCart product: Product) {
        CartManager.shared.add(product)
        controlsView.animateCartBadgeBounce()
    }
}
