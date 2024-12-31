//
//  MKPresentable.swift
//  ModalKit
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import Foundation
import UIKit

/// `MKPresentable` is a protocol that defines the necessary properties for a view controller that can be presented using the `MKPresentationController`.
/// Conforming to this protocol allows the view controller to specify custom behavior related to presentation, such as preferred content height, appearance,
/// and interaction with gestures or size transitions.
public protocol MKPresentable: AnyObject {
    /// The preferred height for the content of the presented view controller.
    /// - Default: `.intrinsicHeight`
    var preferredPresentationSize: [MKPresentationSize] { get }

    /// A `UIScrollView` instance, if any, contained within the view controller.
    ///
    /// The `scrollView` property allows the `MKPresentationController` to seamlessly track and manage interactions
    /// between the modal's pan gesture and the scroll view's content scrolling. If provided, this enables the modal
    /// to handle gestures dynamically, supporting smooth transitions and dismissals while respecting the scroll
    /// view's scrolling behavior.
    ///
    /// - Default: `nil`
    var scrollView: UIScrollView? { get }

    /// Handles the event when the dimming view (the background area outside the modal) is tapped.
    ///
    /// The default implementation dismisses the modal, but you can override this method to provide custom behavior,
    /// such as displaying an alert or preventing dismissal.
    func onDimmingViewTap()

    /// Configures the view controller with the necessary presentation settings.
    ///
    /// This method allows the conforming view controller to customize its presentation behavior by modifying
    /// the provided `MKPresentableConfiguration` object. The configuration may include properties such as
    /// whether to show a drag indicator, apply rounded corners, or specify the size and appearance of the
    /// presented view.
    func configure(_ configuration: inout MKPresentableConfiguration)

    /// Determines if the view controller should respond to a gesture recognized by the modal gesture recognizer.
    ///
    /// This method is called when a gesture is detected. Returning `false` will disable interaction with the gesture.
    ///
    /// - Parameter gestureRecognizer: The gesture recognizer detecting the pan gesture.
    /// - Returns: A Boolean value indicating whether the view controller should respond to the gesture. Defaults to `true`.
    func shouldContinue(with gestureRecognizer: UIPanGestureRecognizer) -> Bool

    /// Determines if the view controller should transition to a new presentation size.
    ///
    /// Called right before the presentation controller attempts to transition.
    /// Return `false` to prevent the transition; `true` to allow it.
    /// The default implementation returns `true`.
    ///
    /// - Parameter size: The proposed `MKPresentationSize`.
    /// - Returns: A Boolean indicating whether the transition can occur.
    func shouldTransition(to size: MKPresentationSize) -> Bool

    /// Called when the view controller is about to transition to a new presentation size.
    ///
    /// This is your chance to adjust layout or perform any animations in tandem
    /// with the modal’s own transition.
    ///
    /// - Parameter size: The new `MKPresentationSize` the modal is transitioning to.
    func willTransition(to size: MKPresentationSize)

    /// Called after the view controller has transitioned to a new presentation size.
    ///
    /// Use this to finalize layout changes or trigger any post-transition updates.
    ///
    /// - Parameter size: The new `MKPresentationSize` the modal ended up with.
    func didTransition(to size: MKPresentationSize)
}

/// Default values for the `MKPresentable`
public extension MKPresentable {
    var preferredPresentationSize: [MKPresentationSize] { [.intrinsicHeight] }

    var scrollView: UIScrollView? { nil }

    func onDimmingViewTap() {}

    func configure(_ configuration: inout MKPresentableConfiguration) {}

    func shouldContinue(with gestureRecognizer: UIPanGestureRecognizer) -> Bool { return true }

    func shouldTransition(to size: MKPresentationSize) -> Bool { return true }

    func willTransition(to size: MKPresentationSize) {}

    func didTransition(to size: MKPresentationSize) {}
}
