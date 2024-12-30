//
//  DefaultViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A simple default view controller demonstrating the usage of ModalKit.
final class DefaultViewController: UIViewController, MKPresentable {
    var preferredPresentationSize: [MKPresentationSize] {
        [.intrinsicHeight]
    }

    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let button1 = UIButton()
    private let button2 = UIButton()

    private lazy var gradientView = customGradientView()
    private let gradientLayer = CAGradientLayer()

    // MARK: Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }

    // MARK: Methods

    /// Configures the modal's behavior.
    func configure(_ configuration: inout MKPresentableConfiguration) {
        configuration.dragResistance = 0.8
        configuration.isDismissable = false
    }

    private func setupUI() {
        titleLabel.text = "How to use"
        titleLabel.font = .systemFont(ofSize: 35, weight: .medium)

        descriptionLabel.text = "Simply download ModalKit and get started with your own Sheets."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        button1.configuration = buttonConfiguration(title: "Got it", tintColor: .clear)
        button1.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        button2.configuration = buttonConfiguration(title: "Get started", tintColor: .systemBlue)
        button2.configuration?.baseForegroundColor = .white
        button2.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.spacing = 16

        configureConstraints()
    }

    private func configureConstraints() {
        buttonStackView.addArrangedSubview(button1)
        buttonStackView.addArrangedSubview(button2)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(gradientView)
        contentStackView.addArrangedSubview(buttonStackView)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor),

            gradientView.heightAnchor.constraint(equalToConstant: 200),
            gradientView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            buttonStackView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ])
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Helper

private extension DefaultViewController {
    func customGradientView() -> UIView {
        let contentView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 200)))
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true

        let colorTop = UIColor(red: 127/255, green: 0, blue: 255/255, alpha: 1).cgColor
        let colorMiddle = UIColor(red: 200/255, green: 80/255, blue: 192/255, alpha: 1).cgColor
        let colorBottom = UIColor(red: 255/255, green: 0, blue: 255/255, alpha: 1).cgColor

        gradientLayer.colors = [colorTop, colorMiddle, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = contentView.bounds

        contentView.layer.insertSublayer(gradientLayer, at: 0)
        return contentView
    }

    func buttonConfiguration(title: String, tintColor: UIColor) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.baseBackgroundColor = tintColor
        config.baseForegroundColor = .label
        config.cornerStyle = .medium
        config.titleAlignment = .center
        config.buttonSize = .large
        return config
    }
}
