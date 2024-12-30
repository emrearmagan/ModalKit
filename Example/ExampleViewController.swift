//
//  ExampleViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 25.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

class ExampleViewController: UIViewController {
    /// Types of modals available for presentation.
    enum MKType: Int, CaseIterable {
        case basic
        case `default`
        case `static`
        case textfield
        case tableView
        case stacked
        case navigation
        case tabBar
        case scrollView

        var description: String {
            switch self {
                case .basic: return "Basic"
                case .default: return "Default"
                case .static: return "Static"
                case .textfield: return "TextField"
                case .tableView: return "TableView"
                case .stacked: return "Stacked"
                case .navigation: return "Navigation"
                case .tabBar: return "TabBar"
                case .scrollView: return "ScrollView"
            }
        }
    }

    // MARK: - Properties

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureButtons()
    }

    // MARK: - UI Setup

    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func configureButtons() {
        for type in MKType.allCases {
            let button = createButton(for: type)
            stackView.addArrangedSubview(button)
        }
    }

    private func createButton(for type: MKType) -> UIButton {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.buttonSize = .large
        button.tag = type.rawValue
        button.setTitle(type.description, for: .normal)
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func didTapButton(_ sender: UIButton) {
        guard let type = MKType(rawValue: sender.tag) else { return }

        switch type {
            case .basic:
                presentModal(EmptyViewController(presentationSize: [.small, .medium, .large], backgroundColor: .modalKitBackground))

            case .default:
                presentModal(DefaultViewController())

            case .static:
                presentModal(StaticViewController())

            case .textfield:
                presentModal(TextFieldViewController())

            case .tableView:
                presentModal(TableViewController())

            case .stacked:
                presentModal(SettingsRootViewController())

            case .navigation:
                presentModal(NavigationViewController())

            case .tabBar:
                presentModal(TabBarViewController())

            case .scrollView:
                presentModal(ScrollViewController())
        }
    }
}
