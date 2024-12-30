//
//  UIViewController.swift
//  ModalKit
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

/// Extension on `UIViewController` to provide modal presentation functionality with a custom presentation style.
extension UIViewController {
    /// Presents a view controller modally using the custom `MKPresentationManager`.
    ///
    /// - Parameters:
    ///   - viewControllerToPresent: The view controller to present.
    ///   - completion: A closure to execute after the presentation finishes. Defaults to `nil`.
    public func presentModal(_ viewControllerToPresent: UIViewController,
                             completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
        viewControllerToPresent.transitioningDelegate = MKPresentationManager.default
        present(viewControllerToPresent, animated: true, completion: completion)
    }
}

/// Extension on `MKPresentable` for view controllers to interact with the custom presentation controller.
public extension MKPresentable where Self: UIViewController {
    /// The associated `MKPresentationController` managing the modal presentation.
    private var _presentationController: MKPresentationController? {
        presentationController as? MKPresentationController
    }

    /// Notifies the presentation controller that the layout needs to be updated.
    ///
    /// This method triggers a recalculation of the layout, ensuring that the modal
    /// is displayed correctly after changes such as size updates.
    func setNeedLayout() {
        _presentationController?.setNeedsLayout()
    }

    /// Transitions the modal presentation to a new size.
    ///
    /// - Parameter size: The new presentation size to transition to.
    /// This allows dynamic updates to the modal's size.
    func transition(to size: MKPresentationSize) {
        _presentationController?.transition(to: size)
    }

    /// Updates the layout of the presentation controller if needed.
    ///
    /// This method ensures that the modal is fully laid out and animates any required changes.
    func presentationLayoutIfNeeded() {
        _presentationController?.layoutIfNeeded()
    }
}
