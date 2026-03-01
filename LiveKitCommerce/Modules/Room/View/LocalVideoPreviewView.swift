//
//  LocalVideoPreviewView.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import LiveKit

/// Floating, draggable local video preview that snaps to the nearest screen corner.
final class LocalVideoPreviewView: UIView {

    // MARK: - Constants

    private enum Layout {
        static let width:    CGFloat = 100
        static let height:   CGFloat = 140
        static let margin:   CGFloat = 16
        static let corner:   CGFloat = 14
    }

    // MARK: - Subviews

    private let videoView: VideoView = {
        let v = VideoView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    private let placeholderView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.surfaceElevated

        let icon = UIImageView(image: UIImage(systemName: "video.slash.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = AppColors.textTertiary
        icon.contentMode = .scaleAspectFit
        v.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),
        ])
        return v
    }()

    private let minimizeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        btn.setImage(UIImage(systemName: "minus", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(white: 0, alpha: 0.5)
        btn.layer.cornerRadius = 10
        return btn
    }()

    private var isMinimized = false

    // MARK: - Drag State

    private var dragStartCenter: CGPoint = .zero

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Layout.width, height: Layout.height))
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        clipsToBounds    = false
        layer.cornerRadius = Layout.corner
        layer.shadowColor  = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius  = 12
        layer.shadowOffset  = CGSize(width: 0, height: 6)

        // Inner clip wrapper (so video clips to corners)
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.layer.cornerRadius = Layout.corner
        wrapper.clipsToBounds = true
        addSubview(wrapper)
        NSLayoutConstraint.activate([
            wrapper.topAnchor.constraint(equalTo: topAnchor),
            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        wrapper.addSubview(placeholderView)
        wrapper.addSubview(videoView)
        addSubview(minimizeButton)

        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),

            videoView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),

            minimizeButton.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            minimizeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            minimizeButton.widthAnchor.constraint(equalToConstant: 20),
            minimizeButton.heightAnchor.constraint(equalToConstant: 20),
        ])

        // Gestures
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        minimizeButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    // MARK: - Track

    func setTrack(_ track: LocalVideoTrack?) {
        videoView.track = track
        let hasVideo = track != nil
        placeholderView.isHidden = hasVideo
        videoView.isHidden = !hasVideo
    }

    // MARK: - Dragging

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let parent = superview else { return }

        switch gesture.state {
        case .began:
            dragStartCenter = center

        case .changed:
            let translation = gesture.translation(in: parent)
            center = CGPoint(x: dragStartCenter.x + translation.x,
                             y: dragStartCenter.y + translation.y)

        case .ended, .cancelled:
            snapToNearestCorner(in: parent)

        default:
            break
        }
    }

    private func snapToNearestCorner(in parent: UIView) {
        let safeInsets = parent.safeAreaInsets
        let minX = Layout.margin + bounds.width / 2
        let maxX = parent.bounds.width  - Layout.margin - bounds.width / 2
        let minY = safeInsets.top + 60 + Layout.margin + bounds.height / 2   // below controls bar
        let maxY = parent.bounds.height - safeInsets.bottom - Layout.margin - bounds.height / 2

        let snapX = center.x < parent.bounds.midX ? minX : maxX
        let snapY = center.y < parent.bounds.midY ? minY : maxY

        UIView.animate(
            withDuration: 0.4, 
            delay: 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.center = CGPoint(x: snapX, y: snapY)
        }
    }

    // MARK: - Minimize / Maximize

    @objc private func handleTap() {
        isMinimized.toggle()
        let scale: CGFloat = isMinimized ? 0.4 : 1.0
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let iconName = isMinimized ? "arrow.up.left.and.arrow.down.right" : "minus"
        minimizeButton.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)

        UIView.animate(
            withDuration: 0.35, 
            delay: 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3
        ) {
            self.transform = self.isMinimized
                ? CGAffineTransform(scaleX: scale, y: scale)
                : .identity
            self.alpha = self.isMinimized ? 0.65 : 1.0
        }
    }

    // MARK: - Initial Placement

    func placeInBottomTrailingCorner(of parent: UIView) {
        let insets = parent.safeAreaInsets
        let x = parent.bounds.width  - Layout.margin - Layout.width / 2
        let y = parent.bounds.height - insets.bottom - Layout.margin - Layout.height / 2
        center = CGPoint(x: x, y: y)
    }
}
