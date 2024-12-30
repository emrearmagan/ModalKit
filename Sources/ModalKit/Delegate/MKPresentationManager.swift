//
//  MKPresentationManager.swift
//  ModalKit
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import Foundation
import UIKit

/// `MKPresentationManager` is responsible for managing the transition and presentation of view controllers in the `ModalKit` framework.
/// It conforms to `UIViewControllerTransitioningDelegate` and provides the necessary methods to handle custom presentation and dismissal animations.
public class MKPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    // MARK: Properties

    /// The default instance of `MKPresentationManager` used for presenting and dismissing view controllers.
    public static var `default`: MKPresentationManager = .init()

    /// A closure executed after the presented view controller has been dismissed.
    public var onDismiss: (() -> Void)?

    // MARK: - Initialization

    /// Initializes a new instance of `MKPresentationManager`.
    ///
    /// - Parameters:
    ///   - closeOnTap: Determines whether tapping the background dismisses the modal. Default is `true`.
    ///   - onDismiss: A closure executed after the presented view controller is dismissed. Default is `nil`.
    public init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }

    // MARK: - UIViewControllerTransitioningDelegate

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = MKPresentationController(presentedViewController: presented,
                                                              presenting: presenting,
                                                              direction: .bottom,
                                                              onDismiss: nil
        )

        return presentationController
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MKPresentationAnimator(direction: .bottom, isPresenting: true, tranistionDuration: 0.4)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MKPresentationAnimator(direction: .bottom, isPresenting: false, tranistionDuration: 0.4)
    }
}
