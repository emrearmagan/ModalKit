//
//  MKPresentationAnimator.swift
//  ModalKit
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

/// `MKPresentationAnimator` is responsible for managing the presentation and dismissal.
/// It conforms to `UIViewControllerAnimatedTransitioning` to provide custom transition animations.
public final class MKPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: Properties

    /// The direction in which the view is presented or dismissed.
    private let direction: MKPresentationDirection

    /// Flag indicating whether the VC is being presented or dismissed.
    private let isPresenting: Bool

    /// The duration for the transition animation.
    private let tranistionDuration: TimeInterval

    // MARK: Init

    /// Initializes the animator with the specified direction, transition style, and duration.
    /// - Parameters:
    ///   - direction: The direction of the transition (e.g., from the bottom).
    ///   - transitionStyle: The style of transition (whether it's presenting or dismissing).
    ///   - tranistionDuration: The duration of the transition animation.
    init(direction: MKPresentationDirection, isPresenting: Bool, tranistionDuration: TimeInterval) {
        self.direction = direction
        self.isPresenting = isPresenting
        self.tranistionDuration = tranistionDuration
        super.init()
    }

    // MARK: UIViewControllerAnimatedTransitioning

    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return tranistionDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        // Retrieve the view controller for the transition
        guard let controller = transitionContext.viewController(forKey: key) else { return }

        let containerView = transitionContext.containerView
        if isPresenting {
            containerView.addSubview(controller.view)
        }

        // calls `viewWillAppear` and `viewWillDisappear`
        controller.beginAppearanceTransition(isPresenting, animated: true)

        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        switch direction {
            case .bottom:
                dismissedFrame.origin.y = containerView.frame.size.height
        }

        let initialFrame = isPresenting ? dismissedFrame : presentedFrame
        let finalFrame = isPresenting ? presentedFrame : dismissedFrame

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: [.curveEaseInOut]) {
            controller.view.frame = finalFrame
        } completion: { finished in
            if !self.isPresenting {
                controller.view.removeFromSuperview()
            }

            // calls `viewDidAppear` and `viewDidDisappear`
            controller.endAppearanceTransition()
            transitionContext.completeTransition(finished)
        }
    }
}
