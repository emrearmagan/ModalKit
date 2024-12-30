//
//  TableViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 28.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A table view controller that displays FAQs with expandable sections, adjusting its presentation size dynamically.
final class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKPresentable {
    // MARK: - MKPresentable Properties

    /// Calculates the preferred presentation size based on the table view's content height.
    var preferredPresentationSize: [MKPresentationSize] {
        return [.contentHeight(tableView.contentSize.height + headerLabel.frame.height + 28)]
    }

    // MARK: - Properties

    private let faqData: [(title: String, content: String)] = [
        ("Why is the sky blue?", "Because it’s sad! Actually, it's due to Rayleigh scattering, which causes shorter blue wavelengths of light to scatter more than other colors. And no, it’s not just a big blue screen for debugging."),
        ("How do I debug faster?", "First, panic. Then, talk to a rubber duck or your favorite houseplant about the bug. Use logs, breakpoints, and maybe sacrifice a coffee to the debugging gods. Short on time? Avoid introducing bugs in the first place."),
        ("What’s the secret to success?", "Hard work and a pinch of luck. But let’s be honest: a well-placed meme in the team chat works wonders too."),
        ("Can I use a fork as a spoon?", "Yes, but it’ll be messy. Especially for soup. If you manage to eat cereal with it, congratulations, you’ve unlocked a new skill."),
        ("Why did the chicken cross the road?", "To get to the ModalKit demo. Or maybe to escape spaghetti code. Either way, the chicken made the right call!")
    ]

    /// Tracks the indices of expanded sections.
    private var expandedSectionIndice: Int? = nil

    /// The table view for displaying the FAQ content.
    private let tableView = UITableView()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Frequently Asked Questions"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupTableView()
    }

    // MARK: - Methods

    private func setupHeader() {
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.alwaysBounceVertical = false
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return faqData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        let isExpanded = expandedSectionIndice == indexPath.section

        var config = UIListContentConfiguration.cell()
        config.text = faqData[indexPath.section].title
        config.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        config.textProperties.color = .systemBlue
        config.secondaryText = isExpanded ? faqData[indexPath.section].content : nil
        config.secondaryTextProperties.font = .systemFont(ofSize: 14)
        config.secondaryTextProperties.color = .secondaryLabel
        config.textToSecondaryTextVerticalPadding = 8

        cell.contentConfiguration = config

        let accessoryImage = UIImageView(image: UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down"))
        accessoryImage.tintColor = .systemGray
        cell.accessoryView = accessoryImage
        cell.selectionStyle = .none
        cell.backgroundColor = isExpanded ? .systemBlue.withAlphaComponent(0.2) : .clear
        cell.contentView.layoutMargins = UIEdgeInsets(top: 21, left: 0, bottom: 21, right: 0)

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if expandedSectionIndice == indexPath.section {
            expandedSectionIndice = nil
        } else {
            expandedSectionIndice = indexPath.section
        }

        tableView.reloadData()
        presentationLayoutIfNeeded()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
