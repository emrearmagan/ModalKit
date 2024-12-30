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
}

// MARK: - UINavigationControllerDelegate

extension NavigationViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.isBeingPresented else { return }
        /// Ensures the presentation layout is updated when transitioning between view controllers.
        presentationLayoutIfNeeded()
    }
}

// MARK: RootViewController

private class SettingsRootViewController: UIViewController, MKPresentable {
    // MARK: Properties

    /// Calculates the preferred presentation size based on the content and navigation bar height.
    var preferredPresentationSize: [MKPresentationSize] {
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        return [.contentHeight(contentStackView.frame.height + navigationBarHeight)]
    }

    private let contentStackView = UIStackView()

    /// An enumeration representing the available settings options.
    enum Settings: Int {
        case darkMode
        case language
        case accounts
        case dashboard
        case helpFeedback
        case upgrade

        var description: String {
            switch self {
            case .darkMode:
                "Dark Mode"
            case .language:
                "Language"
            case .accounts:
                "Accounts"
            case .dashboard:
                "Dashboard"
            case .helpFeedback:
                "Help & Feedback"
            case .upgrade:
                "Upgrade"
            }
        }

        var tintColor: UIColor {
            switch self {
            case .darkMode: return .systemGray
            case .language: return .systemBlue
            case .accounts: return .systemGreen
            case .dashboard: return .systemPurple
            case .helpFeedback: return .systemPink
            case .upgrade: return .systemYellow
            }
        }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }

    // MARK: Methods

    private func setupNavigationBar() {
        let label = UILabel()
        label.textColor = .label
        label.text = "Settings"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(dismissVC)
        )
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    private func setupUI() {
        let contentView = createContent()
        let footerView = createFooter()

        contentStackView.addArrangedSubview(contentView)
        contentStackView.addArrangedSubview(footerView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 16

        view.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    @objc private func settingTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag,
              let setting = Settings(rawValue: tag) else {
            return
        }

        let height = CGFloat.random(in: 100...UIScreen.main.bounds.height)
        let vc = EmptyViewController(presentationSize: [.contentHeight(height)], backgroundColor: .modalKitBackground)
        vc.title = setting.description
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

// MARK: UI

extension SettingsRootViewController {
    private func createContent() -> UIStackView {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 12

        let settingsItems: [(Settings, UIView?)] = [
            (.darkMode, createSwitch(isOn: true)),
            (.language, nil),
            (.accounts, nil),
            (.dashboard, nil),
            (.helpFeedback, nil),
            (.upgrade, nil)
        ]

        for (index, (setting, accessory)) in settingsItems.enumerated() {
            let itemView = createSettingItem(setting: setting, accessory: accessory)
            contentStackView.addArrangedSubview(itemView)

            // Add separator unless it's the last item
            if index < settingsItems.count - 1 {
                contentStackView.addArrangedSubview(createSeparator())
            }
        }

        return contentStackView
    }

    private func createFooter() -> UILabel {
        let footerLabel = UILabel()
        footerLabel.text = "© 2024 ModalKit"
        footerLabel.textColor = .lightGray
        footerLabel.font = .systemFont(ofSize: 12)
        footerLabel.textAlignment = .center
        return footerLabel
    }

    private func createSettingItem(setting: Settings, accessory: UIView?) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 20
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(settingTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        container.tag = setting.rawValue

        let imageContainer = UIView()
        imageContainer.backgroundColor = setting.tintColor
        imageContainer.layer.cornerRadius = 5
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageContainer.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let icon = UIImageView(image: UIImage(systemName: "gear"))
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(icon)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = setting.description
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        container.addArrangedSubview(imageContainer)
        container.addArrangedSubview(titleLabel)

        if let accessory = accessory {
            container.addArrangedSubview(accessory)
            accessory.setContentHuggingPriority(.required, for: .horizontal)
        }

        return container
    }

    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }

    private func createSwitch(isOn: Bool) -> UISwitch {
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.onTintColor = .systemGreen
        return toggle
    }
}
