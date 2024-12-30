//
//  TabBarViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A custom tab bar controller that supports dynamic presentation sizes for its tabs.
final class TabBarViewController: UITabBarController, MKPresentable {
    // MARK: - MKPresentable Properties

    /// The preferred presentation size for the currently selected view controller.
    var preferredPresentationSize: [MKPresentationSize] {
        if let vc = selectedViewController as? MKPresentable {
            return vc.preferredPresentationSize
        }
        return [.large]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
        delegate = self
    }

    // MARK: - Methods

    func configure(_ configuration: inout MKPresentableConfiguration) {
        configuration.dragResistance = 0.5
        configuration.isDismissable = true
    }

    /// Sets up the view controllers for the tab bar.
    private func setupViewControllers() {
        let homeVC = EmptyViewController(presentationSize: [.contentHeight(150)], backgroundColor: .systemBlue)
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let settingsVC = EmptyViewController(presentationSize: [.contentHeight(300)], backgroundColor: .systemGreen)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

        let profileVC = EmptyViewController(presentationSize: [.contentHeight(450)], backgroundColor: .systemOrange)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 2)

        viewControllers = [homeVC, settingsVC, profileVC]
    }

    /// Customizes the appearance of the tab bar.
    private func setupTabBarAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        tabBar.backgroundColor = UIColor.systemGray6
        tabBar.layer.cornerRadius = 10
        tabBar.layer.masksToBounds = true
        tabBar.layer.borderWidth = 1.0
        tabBar.layer.borderColor = UIColor.systemGray4.cgColor
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarViewController: UITabBarControllerDelegate {
    /// Ensures the presentation layout is updated when a tab is selected.
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        presentationLayoutIfNeeded()
    }
}
