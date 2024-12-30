//
//  MKPresentationController.swift
//  ModalKit
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

public class MKPresentationController: UIPresentationController {
    // MARK: Public Properties

    /// View that dims the background when the modal is presented.
    open lazy var dimmingView: DimmingView = {
        let view = DimmingView(color: UIColor(white: 0.0, alpha: 0.5))
        view.state = .hidden
        return view
    }()

    /// Indicator that shows a drag handle to the user.
    open lazy var swipeIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = config.dragIndicatorColor
        return view
    }()

    /// Gesture recognizer for dragging the view controller.
    open lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1

        // change to false to immediately listen on gesture movement
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false

        return gesture
    }()

    private var config: MKPresentableConfiguration = .init()

    // MARK: Private Properties

    private enum DragDirection {
        case up
        case down
    }

    /// Closure that will be executed after the presented view controller has been dismissed
    private var onDismiss: (() -> Void)?

    /// Flag indicating whether the PanGesture is currently dragging down.
    private var dragDirection: DragDirection = .down

    /// Screen size based on the key window
    private var screenSize: CGSize {
        return keyWindow?.bounds.size ?? UIScreen.main.bounds.size
    }

    private let dragIndicatorOffset = 12.0

    private var safeAreaInsets: UIEdgeInsets {
        //  We can not use `presentedViewController.view.safeAreaInsets` since the view ist not fully layed out yet. So we simply use the UIWindow for now
        let topInset = keyWindow?.safeAreaInsets.top ?? 64
        let bottomInset = (keyWindow?.safeAreaInsets.bottom ?? .zero)
        return UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    }

    /// The maximum height of the presented view controller.
    private var maximumHeight: CGFloat {
        let safeAreaInsets = safeAreaInsets
        return screenSize.height - safeAreaInsets.top
    }

    /// The minimum height of the presented view controller.
    private var minimumHeight: CGFloat {
        let safeAreaHeight = safeAreaInsets.bottom
        return config.showDragIndicator ? config.dragIndicatorSize.height + safeAreaHeight + dragIndicatorOffset : safeAreaHeight
    }

    /// The key window used to calculate safe area insets.
    private var keyWindow: UIWindow? {
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }

    /// The presented view controller conforming to `MKPresentable`.
    private var presentable: MKPresentable? {
        return presentedViewController as? MKPresentable
    }

    private var sizeOrigins: [CGFloat : MKPresentationSize] = [:]

    private var origins: [CGFloat] = []
    private var currentOrigin: CGFloat = 0
    private var maximumOrigin: CGFloat = 0
    private var minimiumOrigin: CGFloat = 0
    private var smallestOrigin: CGFloat = 0
    private var dismissableOrigin: CGFloat = 0

    /// The frame of the presented view controller within its container.
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        var frame: CGRect = .zero

        frame.size = size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size
        )

        frame.origin.y = currentOrigin
        return frame
    }

    // MARK: Init

    /// Initializes the presentation controller.
    /// - Parameters:
    ///   - presentedViewController: The view controller being presented.
    ///   - presentingViewController: The view controller presenting the modal.
    ///   - direction: The direction of the presentation.
    ///   - closeOnTap: Determines if tapping outside dismisses the modal.
    ///   - onDismiss: A closure called when the modal is dismissed.
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         direction: MKPresentationDirection,
         onDismiss: (() -> Void)?
    ) {
        self.onDismiss = onDismiss

        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
    }

    // MARK: Lifecyle

    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        presentedViewController.view.layoutIfNeeded()

        presentable?.configure(&config)
        setNeedsLayout()
        setupUI()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.state = .visible
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.state = .visible
        })
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
        dimmingView.handler = { [weak self] in
            guard let self = self, self.config.closeOnTap else { return }
            self.dismissController()
        }
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        onDismiss?()
    }

    override public func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.state = .hidden
            dimmingView.removeFromSuperview()
            return
        }

        coordinator.animate { _ in
            self.dimmingView.state = .hidden
        } completion: { _ in
            self.dimmingView.removeFromSuperview()
        }
    }

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        updateSafeAreaMarginGuide()
        presentedView?.frame = frameOfPresentedViewInContainerView
        if config.hasRoundedCorners {
            presentedView?.roundCorners(corners: .allCorners, radius: 25)
        }
    }

    override public func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    // MARK: Functions

    /// Transitions the presented view controller to a new presentation size.
    ///
    /// This method adjusts the layout and animates the transition to the specified size.
    ///
    /// - Parameter size: The new presentation size to transition to.
    open func transition(to size: MKPresentationSize) {
        currentOrigin = translateHeight(height: height(for: size))
        animateContainerOrigin(frameOfPresentedViewInContainerView.origin)
    }

    /// Ensures the layout of the presented view controller is updated if needed.
    ///
    /// This method recalculates the layout and animates any changes in the presentation frame.
    /// It should be called when there are significant layout changes, such as  updates to the preferred presentation size.
    open func layoutIfNeeded() {
        guard !presentingViewController.isBeingDismissed else { return }

        // make sure presented viewcontroller is fully layed out
        presentedViewController.view.layoutIfNeeded()

        // TODO: Update configuration for dragIndicator and hasRoundedCorners
        presentable?.configure(&config)

        var currentOrigin = self.currentOrigin
        setNeedsLayout()
        // Check whether the current frame still exists, so we dont force the frame back to the first size and keep the current frame
        if origins.contains(currentOrigin) {
            self.currentOrigin = currentOrigin
        }
        animateContainerOrigin(frameOfPresentedViewInContainerView.origin)
    }

    /// Updates the layout configuration based on the current state.
    open func setNeedsLayout() {
        updateSafeAreaMarginGuide()

//        sizeOrigins = [:]
        let preferredPresentationSizes = presentable?.preferredPresentationSize ?? [.intrinsicHeight]
//        for size in preferredPresentationSizes {
//            let height = translateHeight(height: height(for: size))
//            sizeOrigins[height] = size
//        }

        let preferredHeights = preferredPresentationSizes.map(height(for:)).unique().compactMap { $0 }
        let smallesHeight = preferredHeights.min() ?? 0

        maximumOrigin = translateHeight(height: maximumHeight)
        minimiumOrigin = translateHeight(height: minimumHeight)
        origins = preferredHeights.map(translateHeight(height:))
        currentOrigin = origins.first ?? minimiumOrigin
        smallestOrigin = translateHeight(height: smallesHeight)
        dismissableOrigin = translateHeight(height: smallesHeight * min(abs(config.dismissibleScale), 1))
    }

    /// Sets up the user interface components.
    private func setupUI() {
        setupDimmingView()
        setupSwipeIndicator()

        // set default backgroundColor
        if presentedViewController.view.backgroundColor == nil {
            presentedViewController.view.backgroundColor = .modalKitBackground
        }
    }

    /// Configures the dimming view.
    private func setupDimmingView() {
        guard let containerView = containerView, !dimmingView.isDescendant(of: containerView) else { return }

        containerView.insertSubview(dimmingView, at: 0)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }

    /// Configures the swipe indicator.
    private func setupSwipeIndicator() {
        guard config.showDragIndicator,
              let rootView = presentedView,
              !swipeIndicator.isDescendant(of: rootView) else { return }

        rootView.addSubview(swipeIndicator)
        swipeIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            swipeIndicator.topAnchor.constraint(equalTo: rootView.topAnchor, constant: dragIndicatorOffset),
            swipeIndicator.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
            swipeIndicator.heightAnchor.constraint(equalToConstant: config.dragIndicatorSize.height),
            swipeIndicator.widthAnchor.constraint(equalToConstant: config.dragIndicatorSize.width),

        ])
        swipeIndicator.layer.cornerRadius = config.dragIndicatorSize.height / 2
    }

    /// Updates the safe area insets for the presented view controller.
    private func updateSafeAreaMarginGuide() {
        let bottomInset = presentedViewController.view.frame.origin.y
        let topMargin = config.showDragIndicator ? config.dragIndicatorSize.height + 12 : 0
        presentedViewController.additionalSafeAreaInsets = .bottom(bottomInset) + .top(topMargin)
    }
}

// MARK: PanGesture animation

extension MKPresentationController {
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard presentable?.shouldRespond(to: gesture) ?? true,
              !presentedViewController.isBeingDismissed,
              !presentedViewController.isBeingPresented else { return }

        // Get the current translation of the gesture
        let translation = gesture.translation(in: presentedViewController.view)
        // Reset the gesture translation for the next drag movement
        gesture.setTranslation(CGPoint.zero, in: presentedViewController.view)

        if translation.y != 0 {
            dragDirection = translation.y > 0 ? .down : .up
        }

        // Calculate the new origin for the presented view
        let origin = presentedViewController.view.frame.origin
        var newOrigin = origin.y + translation.y

        let tolerance: CGFloat = 10.0 // Define a tolerance range
        switch gesture.state {
            case .changed:
                defer {
                    if newOrigin < smallestOrigin {
                        updateSafeAreaMarginGuide()
                        presentedViewController.viewSafeAreaInsetsDidChange()
                    }
                }

                // Check if the newOrigin is close to any of the predefined origins
                if let closestOrigin = origins.first(where: { abs($0 - newOrigin) <= tolerance }),
                   let size = sizeOrigins[closestOrigin] {
                    presentable?.willTransition(to: size)
                }

                // Allow downward dragging without resistance
                if dragDirection == .down || newOrigin > currentOrigin, config.isDismissable {
                    presentedViewController.view.frame.origin.y = max(newOrigin, maximumOrigin)
                    return
                }

                // Scale translation by resistance
                let resistanceFactor = min(max(config.dragResistance, 0.0), 1.0)
                let effectiveTranslation = translation.y * (1.0 - resistanceFactor)
                newOrigin = max(maximumOrigin, origin.y + effectiveTranslation)
                presentedViewController.view.frame.origin.y = newOrigin

            case .ended:
                let currentOrigin = presentedViewController.view.frame.origin.y

                // If new height is below min, dismiss controller
                if currentOrigin > dismissableOrigin, config.isDismissable {
                    dismissController()
                } else {
                    let nearest = closestValue(to: currentOrigin, in: origins, isDraggingUp: dragDirection == .up)
                    self.currentOrigin = nearest
                    animateContainerOrigin(CGPoint(x: origin.x, y: nearest))
                }

            default:
                break
        }
    }
}

// MARK: Helper

extension MKPresentationController {
    /// Translates a given height into a Y-coordinate for positioning the presented view.
    /// The translation considers the screen size and ensures the resulting point respects the minimum and maximum height bounds.
    private func translateHeight(height: CGFloat) -> CGFloat {
        let boundedHeight = min(max(height, minimumHeight), maximumHeight)
        return screenSize.height - boundedHeight
    }

    /// Dismisses the presented view controller.
    private func dismissController() {
        presentingViewController.dismiss(animated: true)
    }

    /// Finds the closest value to a target within a list of values, with a bias based on dragging direction.
    private func closestValue(to target: CGFloat, in values: [CGFloat], isDraggingUp: Bool) -> CGFloat {
        let weightedValues = values.map { origin -> (CGFloat, CGFloat) in
            // Apply bias based on dragging direction
            let bias: CGFloat = isDraggingUp
                ? (origin < target ? 0.5 : 1.0) // Favor smaller origins when dragging up
                : (origin > target ? 0.5 : 1.0) // Favor larger origins when dragging down

            let weightedDistance = abs(origin - target) * bias
            return (origin, weightedDistance)
        }

        return weightedValues.min { $0.1 < $1.1 }?.0 ?? target
    }

    /// Animates the origin of the container.
    private func animateContainerOrigin(_ point: CGPoint) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [.curveEaseIn, .allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.presentedViewController.view.frame.origin = point
                self.updateSafeAreaMarginGuide()
                self.presentedViewController.view.layoutIfNeeded()
            },
            completion: { _ in
                self.presentedViewController.viewSafeAreaInsetsDidChange()
            }
        )
    }

    /// Calculates the height for a given presentation size.
    /// - Parameter presentationSize: The presentation size.
    /// - Returns: The calculated height.
    private func height(for presentationSize: MKPresentationSize) -> CGFloat {
        let preferredHeight = {
            switch presentationSize {
                case .large:
                    return self.maximumHeight

                case .medium:
                    return screenSize.height / 2

                case .small:
                    return screenSize.height / 4

                case let .contentHeight(value):
                    return value + minimumHeight

                case .intrinsicHeight:
                    self.presentedViewController.view.layoutIfNeeded()

                    // Try calculation the height with constraints
                    guard let presentedView, let containerView else {
                        return 0.0
                    }

                    let targetHeight = presentedView.systemLayoutSizeFitting(
                        CGSize(
                            width: containerView.frame.width,
                            height: UIView.layoutFittingCompressedSize.height
                        )
                    ).height

                    return targetHeight + minimumHeight
            }

        }()

        return min(max(preferredHeight, minimumHeight), maximumHeight)
    }
}
