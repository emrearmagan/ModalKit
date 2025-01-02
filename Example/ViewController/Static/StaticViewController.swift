//
//  StaticViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 29.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A static view controller demonstrating a confirmation modal with interactive elements.
final class StaticViewController: UIViewController, MKPresentable {
    // MARK: - MKPresentable Properties

    /// The preferred presentation size for the modal.
    var preferredPresentationSize: [MKPresentationSize] {
        return [.intrinsicHeight]
    }

    // MARK: - Properties

    private let confirmButton = UIButton(type: .system)
    private let checkboxButton = UIButton(type: .system)
    private let subtitle = UILabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        confirmButton.isEnabled = false
        subtitle.isHidden = true
        subtitle.alpha = 0
    }

    // MARK: - Methods

    func configure(_ configuration: inout MKPresentableConfiguration) {
        configuration.isDismissable = false
        configuration.dragResistance = 1.0
        configuration.showDragIndicator = false
    }

    func onDimmingViewTap() {
        closeButtonTapped()
        view.shake()
    }

    private func setupUI() {
        let headerStackView = createHeader()
        let contentStackView = createContent()
        let footerStackView = createFooter()

        let mainStackView = UIStackView(arrangedSubviews: [headerStackView, contentStackView, footerStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20

        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    // MARK: Actions

    @objc private func closeButtonTapped() {
        guard subtitle.isHidden else { return }
        subtitle.isHidden = false

        UIView.animate(withDuration: 0.4) {
            self.subtitle.alpha = 1
            self.presentationLayoutIfNeeded()
        }
    }

    @objc private func dismissVC() {
        dismiss(animated: true)
    }

    @objc private func toggleCheckbox() {
        let isChecked = checkboxButton.isSelected
        checkboxButton.isSelected.toggle()
        confirmButton.isEnabled = !isChecked
    }
}

// MARK: - Helpers

extension StaticViewController {
    private func createHeader() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "Confirmation"
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        let headerStackView = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = 8

        closeButton.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        return headerStackView
    }

    private func createContent() -> UIView {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "square")
        configuration.imagePadding = 12
        configuration.imagePlacement = .leading
        configuration.contentInsets = .zero

        configuration.title = "I confirm that this is the best modal I have ever seen!"
        configuration.baseForegroundColor = .label
        configuration.background.backgroundColor = .clear

        checkboxButton.configuration = configuration
        checkboxButton.configurationUpdateHandler = { button in
            var updatedConfiguration = button.configuration
            updatedConfiguration?.image = button.isSelected
                ? UIImage(systemName: "checkmark.square.fill")
                : UIImage(systemName: "square")
            button.configuration = updatedConfiguration
        }

        checkboxButton.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)

        subtitle.text = "Nope, you can’t leave before confirming. Nice try though!"
        subtitle.textColor = .secondaryLabel
        subtitle.font = .systemFont(ofSize: 13, weight: .regular)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [checkboxButton, subtitle])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8

        return stackView
    }

    private func createFooter() -> UIView {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = "Continue"
        config.buttonSize = .large

        confirmButton.configuration = config
        confirmButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)

        return confirmButton
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.4
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.0, 2.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}
