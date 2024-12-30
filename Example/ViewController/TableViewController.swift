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
        return [.contentHeight(tableView.contentSize.height)]
    }

    // MARK: - Properties

    /// The FAQ data to display, with titles and expandable content.
    private let faqData: [(title: String, content: String)] = [
        ("Why is the sky blue?", "Because it’s sad! Actually, it’s due to Rayleigh scattering, which causes the shorter blue wavelengths of light to scatter more than other colors."),
        ("How do I debug faster?", "Drink coffee. Write fewer bugs to begin with. Use a rubber duck to explain your problem. Embrace logging, breakpoints, and a good IDE."),
        ("What’s the secret to success?", "Hard work, a bit of luck, and writing excellent commit messages. Don't forget to learn from failure."),
        ("Can I use a fork as a spoon?", "Yes, if you’re brave enough, but it’s not practical. Soup will definitely be a challenge."),
        ("Why did the chicken cross the road?", "To get to the ModalKit demo. Or maybe to escape spaghetti code. Either way, it had its reasons.")
    ]

    /// Tracks the indices of expanded sections.
    private var expandedSectionIndices: Set<Int> = []

    /// The table view for displaying the FAQ content.
    private let tableView = UITableView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - Methods

    /// Configures and sets up the table view layout and appearance.
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
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
        let isExpanded = expandedSectionIndices.contains(indexPath.section)

        var config = UIListContentConfiguration.cell()
        config.text = faqData[indexPath.section].title
        config.textProperties.font = isExpanded ? .systemFont(ofSize: 16, weight: .semibold) : .systemFont(ofSize: 16)
        config.textProperties.color = isExpanded ? .systemBlue : .label
        config.secondaryTextProperties.font = .systemFont(ofSize: 12)
        config.secondaryText = isExpanded ? faqData[indexPath.section].content : nil
        config.textToSecondaryTextVerticalPadding = 8

        cell.contentConfiguration = config

        let accessoryImage = UIImageView(image: UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down"))
        accessoryImage.tintColor = .systemGray
        cell.accessoryView = accessoryImage
        cell.selectionStyle = .none

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        // Toggle expanded state for the selected section.
        if expandedSectionIndices.contains(indexPath.section) {
            expandedSectionIndices.remove(indexPath.section)
        } else {
            expandedSectionIndices.insert(indexPath.section)
        }

        tableView.reloadData()
        presentationLayoutIfNeeded()
    }
}
