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
