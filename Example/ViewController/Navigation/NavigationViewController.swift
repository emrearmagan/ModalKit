//
//  NavigationViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A custom navigation controller that supports dynamic presentation size adjustment for its view controllers.
final class NavigationViewController: UINavigationController, MKPresentable {
    /// Returns the preferred presentation size of the top view controller if it conforms to `MKPresentable`,
    /// otherwise defaults to `.large`.
    var preferredPresentationSize: [MKPresentationSize] {
        if let vc = topViewController as? MKPresentable {
            return vc.preferredPresentationSize
        }
        return [.large]
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [SettingsRootViewController()]
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationBar.prefersLargeTitles = false
        navigationBar.tintColor = .label
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.label
        ]
    }

    func configure(_ configuration: inout MKPresentableConfiguration) {
        configuration.dragResistance = 0.8
    }
}

// MARK: - UINavigationControllerDelegate

extension NavigationViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.isBeingPresented else { return }
        /// Ensures the presentation layout is updated when transitioning between view controllers.
        presentationLayoutIfNeeded()
    }
}
