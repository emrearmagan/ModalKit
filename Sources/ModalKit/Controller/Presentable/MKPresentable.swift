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

    /// Configures the view controller with the necessary presentation settings.
    ///
    /// This method allows the conforming view controller to customize its presentation behavior by modifying
    /// the provided `MKPresentableConfiguration` object. The configuration may include properties such as
    /// whether to show a drag indicator, apply rounded corners, or specify the size and appearance of the
    /// presented view.
    func configure(_ configuration: inout MKPresentableConfiguration)

    /// Determines if the view controller should respond to a gesture recognized by the pan modal gesture recognizer.
    ///
    /// This method is called when a gesture is detected. Returning `false` will disable interaction with the gesture.
    ///
    /// - Parameter panModalGestureRecognizer: The gesture recognizer detecting the pan gesture.
    /// - Returns: A Boolean value indicating whether the view controller should respond to the gesture. Defaults to `true`.
    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool

    /// Determines if the view controller should transition to a new presentation size.
    ///
    /// This method is called when the presentation controller attempts to transition to a new size. Returning `false`
    /// prevents the transition.
    ///
    /// - Parameter size: The proposed `MKPresentationSize` to transition to.
    /// - Returns: A Boolean value indicating whether the transition should occur. Defaults to `true`.
    func shouldTransition(to size: MKPresentationSize) -> Bool

    /// Called when the view controller is about to transition to a new presentation size.
    ///
    /// Use this method to perform any necessary updates or animations in preparation for the transition.
    ///
    /// - Parameter size: The new `MKPresentationSize` the presentation is transitioning to.
    func willTransition(to size: MKPresentationSize)
}

/// Default values for the `MKPresentable`
public extension MKPresentable {
    var preferredPresentationSize: [MKPresentationSize] { [.intrinsicHeight] }

    func configure(_ configuration: inout MKPresentableConfiguration) {}

    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool { return true }

    func shouldTransition(to size: MKPresentationSize) -> Bool { return true }

    func willTransition(to size: MKPresentationSize) {}
}
