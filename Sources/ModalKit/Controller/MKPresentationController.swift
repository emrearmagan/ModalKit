//
//  MKPresentationController.swift
//  ModalKit
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

/// A custom presentation controller for managing modal presentations with configurable sizes, gestures, and animations.
public class MKPresentationController: UIPresentationController {
    // MARK: Public Properties

    /// The view that dims the background when the modal is presented.
    open lazy var dimmingView: DimmingView = {
        let view = DimmingView(color: UIColor(white: 0.0, alpha: 0.5))
        view.state = .hidden
        return view
    }()

    /// The drag indicator shown at the top of the modal, allowing users to drag it.
    open lazy var swipeIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = config.dragIndicatorColor
        return view
    }()

    /// The gesture recognizer for dragging the modal view.
    open lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1

        // change to false to immediately listen on gesture movement
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.name = "mkpresentationcontroller.pangesture"
        gesture.delegate = self
        return gesture
    }()

    /// The configuration that defines how the modal is presented and interacted with.
    private var config: MKPresentableConfiguration = .init()

    // MARK: Private Properties

    /// Enum representing the direction of the drag gesture.
    private enum DragDirection {
        case up
        case down
    }

    /// A closure executed after the modal is dismissed.
    private var onDismiss: (() -> Void)?

    /// The current direction of the drag gesture.
    private var dragDirection: DragDirection = .down

    /// The size of the screen, calculated from the key window.
    private var screenSize: CGSize {
        return keyWindow?.bounds.size ?? UIScreen.main.bounds.size
    }

    /// The offset for the drag indicator.
    private let dragIndicatorOffset = 12.0

    /// The safe area insets for the current window.
    private var safeAreaInsets: UIEdgeInsets {
        //  We can not use `presentedViewController.view.safeAreaInsets` since the view ist not fully layed out yet. So we simply use the UIWindow for now
        let topInset = keyWindow?.safeAreaInsets.top ?? 64
        let bottomInset = (keyWindow?.safeAreaInsets.bottom ?? .zero)
        return UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    }

    /// The maximum allowable height of the modal view.
    private var maximumHeight: CGFloat {
        return screenSize.height - safeAreaInsets.top
    }

    /// The minimum allowable height of the modal view.
    private var minimumHeight: CGFloat {
        let bottomInset = safeAreaInsets.bottom
        return config.showDragIndicator
            ? config.dragIndicatorSize.height + bottomInset + dragIndicatorOffset
            : bottomInset
    }

    /// The current key window.
    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }

    /// The presented view controller conforming to `MKPresentable`, if applicable.
    private var presentable: MKPresentable? {
        presentedViewController as? MKPresentable
    }

    private var scrollViewContentOffsetObserver: NSKeyValueObservation?
    private var scrollViewLastOffsetY: CGFloat = 0
    private var hasScrollViewEmbeded: Bool = false
    /// A dictionary mapping Y-origin values to presentation sizes.
    private var sizeOrigins: [CGFloat: MKPresentationSize] = [:]
    /// The origins for valid modal positions.
    private var origins: [CGFloat] = []
    /// The current Y-origin of the modal.
    private var currentOrigin: CGFloat = 0
    /// The maximum Y-origin for the modal.
    private var maximumOrigin: CGFloat = 0
    /// The minimum Y-origin for the modal.
    private var minimiumOrigin: CGFloat = 0
    /// The smallest allowable Y-origin for the modal.
    private var smallestOrigin: CGFloat = 0
    /// The Y-origin at which the modal can be dismissed.
    private var dismissableOrigin: CGFloat = 0

    /// The frame of the presented view controller within the container view.
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
    ///
    /// - Parameters:
    ///   - presentedViewController: The view controller being presented.
    ///   - presentingViewController: The view controller presenting the modal.
    ///   - direction: The direction of the presentation.
    ///   - onDismiss: A closure to execute when the modal is dismissed.
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         direction: MKPresentationDirection,
         onDismiss: (() -> Void)?) {
        self.onDismiss = onDismiss
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    // MARK: Lifecycle

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

    override public func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        scrollViewContentOffsetObserver?.invalidate()
        scrollViewContentOffsetObserver = nil

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

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        onDismiss?()
    }

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        updateSafeAreaMarginGuide()
        presentedView?.frame = frameOfPresentedViewInContainerView
        if config.hasRoundedCorners {
            presentedView?.roundCorners(corners: .allCorners, radius: 20)
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
    /// It should be called when there are significant layout changes, such as updates to the preferred presentation size.
    open func layoutIfNeeded() {
        guard !presentingViewController.isBeingDismissed else { return }

        // Ensure the presented view controller's view is fully laid out
        presentedViewController.view.layoutIfNeeded()

        // TODO: Update configuration for dragIndicator and hasRoundedCorners
        presentable?.configure(&config)

        var currentOrigin = self.currentOrigin
        setNeedsLayout()
        // Retain the current frame if it exists in the calculated origins
        if origins.contains(currentOrigin) {
            self.currentOrigin = currentOrigin
        }
        animateContainerOrigin(frameOfPresentedViewInContainerView.origin)
    }

    /// Recomputes the modal’s valid Y-origins and snap points based on the presentable’s preferred sizes.
    /// This includes determining:
    /// - The minimum/maximum allowable positions for the modal.
    /// - The array of valid “snap” origins.
    /// - The smallest/largest feasible origins.
    /// - The dismissible threshold.
    ///
    /// This method should be called whenever the modal’s layout requirements change
    /// (e.g., device rotation, content size changes, or configuration updates).
    /// It also triggers observation of the modal’s scroll view (if any) for offset updates
    /// and updates the safe area insets for the modal.
    open func setNeedsLayout() {
        // Update the safe area constraints & begin observing scroll offsets
        updateSafeAreaMarginGuide()
        observeScrollView()

        hasScrollViewEmbeded = presentable?.scrollView != nil
        let preferredPresentationSizes = presentable?.preferredPresentationSize ?? [.intrinsicHeight]
        let preferredHeights = preferredPresentationSizes.map(height(for:)).unique()

        // Determine the smallest & largest raw heights from the list
        let smallestHeight = preferredHeights.min() ?? 0
        let largestHeight = preferredHeights.max() ?? CGFloat.greatestFiniteMagnitude

        // Translate the maximum & minimum allowable modal heights into Y-origins
        maxPossibleOrigin = translateHeight(height: maximumHeight)
        minPossibleOrigin = translateHeight(height: minimumHeight)

        // Convert each preferred height into a valid modal origin (snap point)
        origins = preferredHeights.map(translateHeight(height:))

        // Default the current origin to the first valid snap, or fall back to the minimum if none
        currentOrigin = origins.first ?? minPossibleOrigin

        // Convert the smallest & largest valid heights into Y-origins
        smallestOrigin = translateHeight(height: smallestHeight)
        largestOrigin = translateHeight(height: largestHeight)

        // Compute the Y-origin beyond which the modal is considered dismissible
        dismissableOrigin = translateHeight(height: smallestHeight * min(abs(config.dismissibleScale), 1))
    }

    /// Sets up the user interface components for the modal.
    private func setupUI() {
        setupDimmingView()
        setupSwipeIndicator()

        // Set a default background color if none is provided
        if presentedViewController.view.backgroundColor == nil {
            presentedViewController.view.backgroundColor = .modalKitBackground
        }
    }

    /// Configures the dimming view used for the modal background.
    private func setupDimmingView() {
        guard let containerView = containerView, !dimmingView.isDescendant(of: containerView) else { return }

        containerView.insertSubview(dimmingView, at: 0)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    /// Configures the swipe indicator for the modal.
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
            swipeIndicator.widthAnchor.constraint(equalToConstant: config.dragIndicatorSize.width)
        ])
        swipeIndicator.layer.cornerRadius = config.dragIndicatorSize.height / 2
    }

    /// Updates the safe area margins for the modal view controller.
    private func updateSafeAreaMarginGuide() {
        let bottomInset = presentedViewController.view.frame.origin.y
        let topMargin = config.showDragIndicator ? config.dragIndicatorSize.height + dragIndicatorOffset : 0
        presentedViewController.additionalSafeAreaInsets = .bottom(bottomInset) + .top(topMargin)
    }

    /// Observes the content offset changes of the scroll view provided by the `presentable`.
    ///
    /// This method sets up Key-Value Observation (KVO) on the scroll view’s `contentOffset`.
    /// Whenever the scroll view’s offset changes, `handleScrollViewOffsetChange(_:change:)`
    /// is called to determine if the scroll view should be “locked” or allowed to scroll freely.
    ///
    /// This way we dont interfere with the scrollViews delegate and rely only on the offset changes
    private func observeScrollView() {
        scrollViewContentOffsetObserver?.invalidate()

        if let scrollView = presentable?.scrollView {
            scrollViewContentOffsetObserver = scrollView.observe(
                \.contentOffset,
                options: .old
            ) { [weak self] scrollView, change in
                self?.handleScrollViewOffsetChange(scrollView, change: change)
            }
        }
    }
}

// MARK: - ScrollView

extension MKPresentationController {
    /// Clamps or releases the scroll view’s offset depending on whether the modal
    /// is fully expanded (`currentOrigin <= largestOrigin`).
    ///
    /// If the modal isn’t at top, the scroll view’s offset is pinned to
    /// `scrollViewLastOffsetY`, ensuring upward drags move the modal first.
    /// Otherwise, normal scrolling is allowed.
    private func handleScrollViewOffsetChange(
        _ scrollView: UIScrollView,
        change: NSKeyValueObservedChange<CGPoint>
    ) {
        let atTop = (currentOrigin.rounded() <= largestOrigin.rounded())
        let isUserDragging = scrollView.isTracking && scrollView.isDragging

        // If user isn't actively dragging, just record the current offset & bail.
        if !isUserDragging {
            scrollViewLastOffsetY = max(scrollView.contentOffset.y, 0)
            return
        }

        // If modal isn't at top, lock the scroll offset to the last known
        // so the modal can move up first.
        if !atTop {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollViewLastOffsetY), animated: false)
        } else {
            // Otherwise, let the scroll view track normally
            scrollViewLastOffsetY = max(scrollView.contentOffset.y, 0)
        }
    }
}

// MARK: - PanGesture Animation

extension MKPresentationController {
    /// Determines if the modal's pan gesture should proceed, giving priority
    /// to the scroll view if it still has content to scroll (offset > 0).
    ///
    /// Returns `false` if the scroll view is scrolling downward from a nonzero offset.
    private func shouldBegin(_ gesture: UIPanGestureRecognizer) -> Bool {
        // Check basic conditions & scrollView presence
        guard presentable?.shouldContinue(with: gesture) ?? true else {
            return false
        }

        // TODO: Fix behaviour when scrollViews contentOffset is intially not .zero for example due to manually setting the offset

        let currentOrigin = presentedViewController.view.frame.origin

        // Check whether the we have a scroll or the state isnt ended. When the state is ended, we need to snap back to the origin
        // and therefore allow it
        if let scrollView = presentable?.scrollView, gesture.state != .ended {
            let offsetY = scrollView.contentOffset.y
            let location = gesture.location(in: presentedViewController.view)
            let activelyScrolling = (scrollView.isTracking && scrollView.isDragging)

            // If user isn't dragging inside scrollView bounds, allow modal pan.
            // We also need to ensure that the user is currently not scrolling since he might me still scrolling but just went
            // out of bounds
            if !scrollView.frame.contains(location) && !activelyScrolling {
                return true
            }

            // If scrollView offset > 0, let the scrollView continue
            if offsetY > 0 {
                return false
            }
        }

        return true
    }

    /// Responds to pan gesture changes, moving the modal’s frame up or down.
    ///
    /// This method calculates the new origin based on the drag direction and applies
    /// any “resistance” factor or dismissible logic. When the gesture ends,
    /// it snaps to the nearest valid origin or dismisses if the user pulled it far enough.
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        // Get the current translation of the gesture
        let translation = gesture.translation(in: presentedViewController.view)
        gesture.setTranslation(.zero, in: presentedViewController.view)

        guard shouldBegin(gesture) else { return }
        if translation.y != 0 {
            dragDirection = translation.y > 0 ? .down : .up
        }

        let origin = presentedViewController.view.frame.origin
        var newOrigin = origin.y + translation.y

        switch gesture.state {
            case .changed:
                defer {
                    if newOrigin < smallestOrigin {
                        updateSafeAreaMarginGuide()
                        presentedViewController.viewSafeAreaInsetsDidChange()
                    }
                }

                let maxPossibleOrigin = hasScrollViewEmbeded ? largestOrigin : self.maxPossibleOrigin

                // Allow downward dragging without resistance
                if dragDirection == .down, config.isDismissable {
                    newOrigin = max(newOrigin, maxPossibleOrigin)
                } else {
                    // Scale translation by resistance
                    let resistanceFactor = min(max(config.dragResistance, 0.0), 1.0)
                    let effectiveTranslation = translation.y * (1.0 - resistanceFactor)
                    newOrigin = max(maxPossibleOrigin, origin.y + effectiveTranslation)
                }

                presentedViewController.view.frame.origin.y = newOrigin
                currentOrigin = newOrigin

            case .ended:
                let currentOrigin = presentedViewController.view.frame.origin.y

                // If new height is below min, dismiss controller
                if currentOrigin > dismissableOrigin, config.isDismissable {
                    dismissController()
                } else {
                    // Get the closest origin an update frame
                    let nearest = closestValue(to: currentOrigin, in: origins, dragDirection: dragDirection)
                    self.currentOrigin = nearest
                    animateContainerOrigin(CGPoint(x: origin.x, y: nearest))
                }

            default:
                break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MKPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // This ensures that other panGesture can work together with the scrollView's internal pan gesture
        return otherGestureRecognizer.view == presentable?.scrollView
    }
}

// MARK: - Helper Methods

extension MKPresentationController {
    /// Converts a modal “height” into its corresponding Y-origin, respecting the modal’s
    /// minimum and maximum allowable heights.
    ///
    /// - Parameter height: The proposed height for the modal.
    /// - Returns: A Y-origin value (relative to the screen’s bottom edge) after clamping
    ///   the height within `[minimumHeight, maximumHeight]`.
    ///
    /// This method effectively transforms a desired modal height into
    /// the coordinate space used by the presentation (where a lower Y means a taller modal).
    private func translateHeight(height: CGFloat) -> CGFloat {
        let boundedHeight = min(max(height, minimumHeight), maximumHeight)
        return screenSize.height - boundedHeight
    }

    /// Dismisses the presented view controller.
    private func dismissController() {
        presentingViewController.dismiss(animated: true)
    }

    /// Finds the closest valid snap point (Y-origin) to the user’s current drag position.
    ///
    /// This method ensures that when a user finishes dragging, the modal will
    /// “snap” to the most appropriate origin. For example, if they drag slightly
    /// below a snap point while moving downward, we might bias toward the next-lower snap
    /// instead of returning them to the higher one.
    private func closestValue(
        to target: CGFloat,
        in values: [CGFloat],
        dragDirection: DragDirection
    ) -> CGFloat {
        let weightedValues = values.map { origin -> (CGFloat, CGFloat) in
            // Apply bias based on dragging direction so we favor the origin in that direction
            let bias: CGFloat = dragDirection == .up
                ? (origin < target ? 0.5 : 1.0)
                : (origin > target ? 0.5 : 1.0)
            let weightedDistance = abs(origin - target) * bias
            return (origin, weightedDistance)
        }
        return weightedValues.min { $0.1 < $1.1 }?.0 ?? target
    }

    /// Animates the modal view to a new origin.
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
    private func height(for presentationSize: MKPresentationSize) -> CGFloat {
        switch presentationSize {
            case .large:
                return maximumHeight

            case .medium:
                return screenSize.height / 2

            case .small:
                return screenSize.height / 4

            case let .contentHeight(value):
                return value + minimumHeight

            case .intrinsicHeight:
                presentedViewController.view.layoutIfNeeded()

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
    }
}
