//
//  TextFieldViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A view controller that displays a text field with dynamic keyboard height adjustment.
final class TextFieldViewController: UIViewController, MKPresentable {
    // MARK: - MKPresentable Properties

    /// Calculates the preferred presentation size based on the content and keyboard height.
    var preferredPresentationSize: [MKPresentationSize] {
        let buttonHeight = confirmButton.isHidden ? 0 : confirmButton.frame.height + 24 // Includes spacing
        let contentHeight = contentStackView.frame.height + buttonHeight + keyboardHeight
        return [.contentHeight(contentHeight)]
    }

    // MARK: - Properties

    private var keyboardHeight: CGFloat = 0.0
    private let contentStackView = UIStackView()
    private let confirmButton = UIButton()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeKeyboardNotifications()
    }

    // MARK: - Methods

    func configure(_ configuration: inout MKPresentableConfiguration) {
        configuration.dragResistance = 0.7
    }

    private func setupUI() {
        let headerView = createHeader()
        let contentView = createContent()
        let footerView = createFooter()

        contentStackView.axis = .vertical
        contentStackView.spacing = 12
        contentStackView.addArrangedSubview(headerView)
        contentStackView.addArrangedSubview(contentView)

        view.addSubview(contentStackView)
        view.addSubview(footerView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    /// Adds observers for keyboard notifications.
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Actions

    @objc private func handleKeyboardNotification(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let keyboardWillShow = notification.name == UIResponder.keyboardWillShowNotification
        keyboardHeight = keyboardWillShow ? keyboardFrame.height : 0
        confirmButton.isHidden = keyboardWillShow
        presentationLayoutIfNeeded()
    }

    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

// MARK: - Helper

extension TextFieldViewController {
    /// Creates the header view with a title label.
    private func createHeader() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "Search GitHub Tags"
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        return titleLabel
    }

    /// Creates the content view with an informational label and a text field.
    private func createContent() -> UIView {
        let label = UILabel()
        label.text = "Add tags that best describe your content. Think of keywords your audience might search for."
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .lightGray
        label.numberOfLines = 0

        let textField = UITextField()
        textField.leftViewMode = .always
        let icon = UIImageView(frame: .init(origin: .zero, size: .init(width: 35, height: 35)))
        icon.image = UIImage(systemName: "magnifyingglass")
        icon.tintColor = .label
        textField.leftView = icon

        textField.placeholder = "Enter your name"
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.cornerRadius = 5
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.delegate = self
        textField.returnKeyType = .done

        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.axis = .vertical
        stackView.spacing = 16

        textField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return stackView
    }

    /// Creates the footer view with a confirm button.
    private func createFooter() -> UIView {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.title = "Continue"
        config.buttonSize = .large

        confirmButton.configuration = config
        confirmButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)

        return confirmButton
    }
}

// MARK: - UITextFieldDelegate

extension TextFieldViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
