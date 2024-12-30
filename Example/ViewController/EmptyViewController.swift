//
//  EmptyViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 30.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A simple view controller used to demonstrate modal presentation with dynamic sizes.
class EmptyViewController: UIViewController, MKPresentable {
    // MARK: - Properties

    /// Defines the preferred presentation size for the modal.
    var preferredPresentationSize: [MKPresentationSize]

    // MARK: - Init

    /// Initializes the `EmptyViewController` with a specified presentation size and background color.
    /// - Parameters:
    ///   - presentationSize: The preferred sizes for the modal.
    ///   - backgroundColor: The background color of the view controller.
    init(presentationSize: [MKPresentationSize], backgroundColor: UIColor) {
        preferredPresentationSize = presentationSize
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = backgroundColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
