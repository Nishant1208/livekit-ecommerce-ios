//
//  ProductDetailTransition.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit

// MARK: - Animator

final class ProductDetailTransition: NSObject, UIViewControllerAnimatedTransitioning {

    enum Direction { case push, pop }

    var direction: Direction = .push

    /// Source image captured from the tapped cell (window-coordinate frame).
    var sourceFrame: CGRect = .zero
    var sourceImage: UIImage?

    // MARK: - Timing

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        direction == .push ? 0.45 : 0.35
    }

    // MARK: - Transition

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        switch direction {
        case .push: animatePush(context)
        case .pop:  animatePop(context)
        }
    }

    // MARK: - Push

    private func animatePush(_ context: UIViewControllerContextTransitioning) {
        guard
            let toVC   = context.viewController(forKey: .to) as? ProductDetailViewController,
            let toView = context.view(forKey: .to)
        else { context.completeTransition(true); return }

        let container = context.containerView
        toView.frame  = context.finalFrame(for: toVC)
        container.addSubview(toView)
        toView.layoutIfNeeded()

        // Build floating snapshot that "expands" into the hero image
        let snapshot = makeSnapshot()
        let sourceInContainer = container.convert(sourceFrame, from: nil)
        snapshot.frame = sourceInContainer
        container.addSubview(snapshot)

        // Destination frame for the hero image in container coordinates
        let destFrame = toVC.heroImageView.convert(toVC.heroImageView.bounds, to: container)

        // Initially hide the real hero image and dim the rest
        toVC.heroImageView.alpha = 0
        toView.alpha = 0

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.3,
            options: [.curveEaseInOut]
        ) {
            snapshot.frame        = destFrame
            snapshot.layer.cornerRadius = 0
        }

        UIView.animate(withDuration: 0.25, delay: 0.05) {
            toView.alpha = 1
        }

        UIView.animate(withDuration: 0.15, delay: 0.30) {
            toVC.heroImageView.alpha = 1
        } completion: { _ in
            snapshot.removeFromSuperview()
            toVC.heroImageView.alpha = 1
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    // MARK: - Pop

    private func animatePop(_ context: UIViewControllerContextTransitioning) {
        guard
            let fromVC   = context.viewController(forKey: .from) as? ProductDetailViewController,
            let fromView = context.view(forKey: .from),
            let toView   = context.view(forKey: .to)
        else { context.completeTransition(true); return }

        let container = context.containerView
        container.insertSubview(toView, belowSubview: fromView)

        // Capture hero current frame
        let heroFrame = fromVC.heroImageView.convert(fromVC.heroImageView.bounds, to: container)
        let snapshot  = makeSnapshot()
        snapshot.frame = heroFrame
        container.addSubview(snapshot)

        fromVC.heroImageView.alpha = 0
        let targetFrame = container.convert(sourceFrame, from: nil)

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.2
        ) {
            snapshot.frame        = targetFrame
            snapshot.layer.cornerRadius = 14
        }

        UIView.animate(withDuration: 0.25) {
            fromView.alpha = 0
        } completion: { _ in
            snapshot.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    // MARK: - Helpers

    private func makeSnapshot() -> UIImageView {
        let iv = UIImageView(image: sourceImage)
        iv.contentMode     = .scaleAspectFill
        iv.clipsToBounds   = true
        iv.layer.cornerRadius = 14
        return iv
    }
}
