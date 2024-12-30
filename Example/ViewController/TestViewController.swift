//
//  TestViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

final class TestViewController: UIViewController, MKPresentable {
    // MARK: - MKPresentable Properties

    var preferredPresentationSize: [MKPresentationSize] {
        return [
            .contentHeight(100),
            .contentHeight(250),
            .contentHeight(450),
            .contentHeight(700),
            .large
        ]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Private Methods

    private func setupUI() {
        // Create the stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(createColoredView(color: .systemRed, height: 100))
        stackView.addArrangedSubview(createColoredView(color: .systemBlue, height: 150))
        stackView.addArrangedSubview(createColoredView(color: .systemGreen, height: 200))
        stackView.addArrangedSubview(createColoredView(color: .systemYellow, height: 250))

        // Add the stack view to the main view
        view.addSubview(stackView)

        // Set constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func createColoredView(color: UIColor, height: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false

        // Add a height constraint
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.tag = Int(height)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }

    @objc private func didTap(_ gesture: UITapGestureRecognizer) {
        if let tag = gesture.view?.tag {
            print(tag)
            transition(to: .contentHeight(CGFloat(tag)))
        }
    }
}
