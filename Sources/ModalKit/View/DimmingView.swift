//
//  DimmingView.swift
//  ModalKit
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

/// A custom view that dims the background when presented.
/// It supports visibility states and allows for tap gestures with customizable handlers.
open class DimmingView: UIView {
    // MARK: - State

    /// Represents the visibility state of the `DimmingView`.
    enum State {
        /// The view is fully visible.
        case visible
        /// The view is fully hidden.
        case hidden
    }

    // MARK: - Properties

    /// The current state of the `DimmingView`.
    /// Changing this state updates the alpha value to toggle visibility.
    var state: State = .hidden {
        didSet {
            switch state {
                case .visible:
                    alpha = 1 // Make the view fully visible
                case .hidden:
                    alpha = 0 // Make the view fully transparent
            }
        }
    }

    /// A closure handler that is invoked when the view is tapped.
    var handler: (() -> Void)?

    // MARK: - Initializers

    /// Initializes a `DimmingView` with a specified background color.
    /// - Parameter color: The background color of the dimming view. Defaults to a semi-transparent black.
    init(color: UIColor = UIColor.black.withAlphaComponent(0.5)) {
        super.init(frame: .zero)

        // Set the background color and initial state
        backgroundColor = color
        state = .hidden

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView(_:))))
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    @objc private func didTapView(_ gesture: UIGestureRecognizer) {
        handler?()
    }
}
