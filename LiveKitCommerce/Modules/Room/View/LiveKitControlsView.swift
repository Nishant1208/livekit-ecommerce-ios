//
//  LiveKitControlsView.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import Lottie

// MARK: - Delegate

protocol LiveKitControlsViewDelegate: AnyObject {
    func controlsViewDidTapMic(_ view: LiveKitControlsView)
    func controlsViewDidTapVideo(_ view: LiveKitControlsView)
    func controlsViewDidTapFlipCamera(_ view: LiveKitControlsView)
    func controlsViewDidTapLeave(_ view: LiveKitControlsView)
    func controlsViewDidTapCart(_ view: LiveKitControlsView)
}

// MARK: - View

final class LiveKitControlsView: UIView {

    weak var delegate: LiveKitControlsViewDelegate?

    // MARK: - Connection Badge

    private let badgeDot: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.success
        v.layer.cornerRadius = 5
        return v
    }()

    private let badgeLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Connected"
        lbl.font = .systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = AppColors.textPrimary
        return lbl
    }()

    private lazy var badgePill: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.surfaceHigh
        v.layer.cornerRadius = 12
        v.layer.borderColor = AppColors.separator.cgColor
        v.layer.borderWidth = 1
        v.addSubview(badgeDot)
        v.addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeDot.widthAnchor.constraint(equalToConstant: 10),
            badgeDot.heightAnchor.constraint(equalToConstant: 10),
            badgeDot.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 10),
            badgeDot.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeDot.trailingAnchor, constant: 6),
            badgeLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -10),
            badgeLabel.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            v.heightAnchor.constraint(equalToConstant: 28),
        ])
        return v
    }()

    // MARK: - Mic Audio Wave

    private let micWaveAnimation: LottieAnimationView = {
        let v = LottieAnimationView(name: "audio_wave")
        v.loopMode = .loop
        v.animationSpeed = 1.2
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    // MARK: - Control Buttons

    private let micButton     = ControlButton(icon: "mic.fill",          activeColor: AppColors.accent)
    private let videoButton   = ControlButton(icon: "video.slash.fill",  activeColor: AppColors.accent)
    private let flipButton    = ControlButton(icon: "camera.rotate.fill", activeColor: AppColors.accent)
    private let leaveButton   = ControlButton(icon: "phone.down.fill",   activeColor: AppColors.error)

    // MARK: - Cart Button

    private let cartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "cart.fill", withConfiguration: config), for: .normal)
        btn.tintColor = AppColors.textPrimary
        btn.backgroundColor = AppColors.primary
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()

    private let cartBadge: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 9, weight: .bold)
        lbl.textColor = .white
        lbl.backgroundColor = AppColors.error
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 8
        lbl.clipsToBounds = true
        lbl.isHidden = true
        return lbl
    }()

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
        // Frosted-glass background
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Bottom separator
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = AppColors.separator
        addSubview(sep)

        // Connection badge
        addSubview(badgePill)

        // Mic wave
        addSubview(micWaveAnimation)

        // Control buttons stack
        let controlsStack = UIStackView(arrangedSubviews: [micButton, videoButton, flipButton, leaveButton])
        controlsStack.translatesAutoresizingMaskIntoConstraints = false
        controlsStack.axis    = .horizontal
        controlsStack.spacing = 10
        addSubview(controlsStack)

        // Cart
        addSubview(cartButton)
        addSubview(cartBadge)

        NSLayoutConstraint.activate([
            sep.leadingAnchor.constraint(equalTo: leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: trailingAnchor),
            sep.bottomAnchor.constraint(equalTo: bottomAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5),

            badgePill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            badgePill.centerYAnchor.constraint(equalTo: centerYAnchor),

            micWaveAnimation.leadingAnchor.constraint(equalTo: badgePill.trailingAnchor, constant: 8),
            micWaveAnimation.centerYAnchor.constraint(equalTo: centerYAnchor),
            micWaveAnimation.widthAnchor.constraint(equalToConstant: 36),
            micWaveAnimation.heightAnchor.constraint(equalToConstant: 24),

            controlsStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            controlsStack.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor, constant: -12),

            cartButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cartButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40),

            cartBadge.topAnchor.constraint(equalTo: cartButton.topAnchor, constant: -4),
            cartBadge.trailingAnchor.constraint(equalTo: cartButton.trailingAnchor, constant: 4),
            cartBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            cartBadge.heightAnchor.constraint(equalToConstant: 16),
        ])

        micButton.addTarget(self,  action: #selector(micTapped),   for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(videoTapped), for: .touchUpInside)
        flipButton.addTarget(self,  action: #selector(flipTapped),  for: .touchUpInside)
        leaveButton.addTarget(self, action: #selector(leaveTapped), for: .touchUpInside)
        cartButton.addTarget(self,  action: #selector(cartTapped),  for: .touchUpInside)

        // Initial state
        flipButton.isHidden = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: .cartDidChange,
            object: nil
        )
    }

    // MARK: - Public Update Methods

    func update(connectionState: RoomConnectionState) {
        let color: UIColor
        let text: String
        switch connectionState {
        case .connected:
            color = AppColors.success;   text = "Connected"
        case .reconnecting:
            color = AppColors.warning;   text = "Reconnecting..."
        case .disconnected:
            color = AppColors.error;     text = "Disconnected"
        }

        badgeDot.backgroundColor = color
        badgeLabel.text = text

        // Pulse the dot when reconnecting
        badgeDot.layer.removeAnimation(forKey: "pulse")
        if connectionState == .reconnecting {
            let pulse = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue  = 1.0
            pulse.toValue    = 0.2
            pulse.duration   = 0.6
            pulse.autoreverses  = true
            pulse.repeatCount   = .infinity
            badgeDot.layer.add(pulse, forKey: "pulse")
        }
    }

    func update(isMicMuted: Bool) {
        let iconName = isMicMuted ? "mic.slash.fill" : "mic.fill"
        micButton.updateIcon(iconName)
        micButton.setActive(!isMicMuted)

        if isMicMuted {
            micWaveAnimation.stop()
            micWaveAnimation.isHidden = true
        } else {
            micWaveAnimation.isHidden = false
            micWaveAnimation.play()
        }
    }

    func update(isVideoEnabled: Bool) {
        let iconName = isVideoEnabled ? "video.fill" : "video.slash.fill"
        videoButton.updateIcon(iconName)
        videoButton.setActive(isVideoEnabled)

        UIView.animate(withDuration: 0.2) {
            self.flipButton.alpha  = isVideoEnabled ? 1 : 0
            self.flipButton.isHidden = !isVideoEnabled
        }
    }

    /// Returns the cart button's frame in window coordinates (for fly-to-cart animation).
    func cartButtonFrameInWindow() -> CGRect {
        cartButton.convert(cartButton.bounds, to: nil)
    }

    func animateCartBadgeBounce() {
        updateCartBadge()
        UIView.animate(withDuration: 0.12, animations: {
            self.cartButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { _ in
            UIView.animate(withDuration: 0.18, delay: 0.2, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.8) {
                self.cartButton.transform = .identity
            }
        })
    }

    // MARK: - Cart Badge

    @objc private func cartDidChange() {
        updateCartBadge()
    }

    private func updateCartBadge() {
        let count = CartManager.shared.itemCount
        if count > 0 {
            cartBadge.text = count > 99 ? "99+" : "\(count)"
            cartBadge.isHidden = false
        } else {
            cartBadge.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func micTapped()   { delegate?.controlsViewDidTapMic(self);         animateButtonTap(micButton) }
    @objc private func videoTapped() { delegate?.controlsViewDidTapVideo(self);        animateButtonTap(videoButton) }
    @objc private func flipTapped()  { delegate?.controlsViewDidTapFlipCamera(self);   animateCameraFlip() }
    @objc private func leaveTapped() { delegate?.controlsViewDidTapLeave(self);        animateButtonTap(leaveButton) }
    @objc private func cartTapped()  { delegate?.controlsViewDidTapCart(self);         animateButtonTap(cartButton) }

    private func animateButtonTap(_ view: UIView) {
        UIView.animate(withDuration: 0.1, animations: { view.transform = CGAffineTransform(scaleX: 0.88, y: 0.88) }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
                view.transform = .identity
            }
        }
    }

    private func animateCameraFlip() {
        UIView.transition(with: flipButton, duration: 0.35, options: .transitionFlipFromLeft) {}
    }
}

// MARK: - ControlButton Helper

private final class ControlButton: UIButton {

    private var iconName: String
    private var isActiveState = true
    private let activeColor: UIColor

    init(icon: String, activeColor: UIColor) {
        self.iconName    = icon
        self.activeColor = activeColor
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor    = AppColors.surfaceHigh
        layer.cornerRadius = 20
        clipsToBounds      = true
        widthAnchor.constraint(equalToConstant: 40).isActive  = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        refreshIcon()
    }

    required init?(coder: NSCoder) { fatalError() }

    func updateIcon(_ name: String) {
        iconName = name
        refreshIcon()
    }

    func setActive(_ active: Bool) {
        isActiveState = active
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = active ? self.activeColor.withAlphaComponent(0.25) : AppColors.surfaceHigh
        }
        refreshIcon()
    }

    private func refreshIcon() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let img = UIImage(systemName: iconName, withConfiguration: cfg)
        setImage(img, for: .normal)
        tintColor = isActiveState ? activeColor : AppColors.textSecondary
    }
}
