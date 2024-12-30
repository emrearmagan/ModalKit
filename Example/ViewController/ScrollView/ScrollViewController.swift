//
//  ScrollViewController.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 30.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import ModalKit
import UIKit

/// A table view controller that displays comments, styled like a comment section.
final class ScrollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKPresentable {
    // MARK: - MKPresentable Properties

    /// Calculates the preferred presentation size based on the table view's content height.
    var preferredPresentationSize: [MKPresentationSize] = [.contentHeight(350), .large]

    var scrollView: UIScrollView? { tableView }

    // MARK: - Properties

    private let tableView = UITableView()

    /// Sample data for comments.
    private let comments: [Comment] = [
        Comment(
            image: .systemPurple,
            username: "@skyGazer99",
            text: "Why is the sky blue? Because it’s sad! Actually, it's due to Rayleigh scattering, which causes shorter blue wavelengths of light to scatter more than other colors."
        ),
        Comment(
            image: .systemBlue,
            username: "@debugMaster",
            text: "How do I debug faster? Panic, talk to a rubber duck, and sacrifice coffee to the debugging gods."
        ),
        Comment(
            image: .systemGreen,
            username: "@successGuru",
            text: "What’s the secret to success? Hard work, memes in the team chat, and excellent commit messages."
        ),
        Comment(
            image: .systemOrange,
            username: "@forkFanatic",
            text: "Can I use a fork as a spoon? Yes, but it’s not practical for soup."
        ),
        Comment(
            image: .systemPink,
            username: "@codeChicken",
            text: "Why did the chicken cross the road? To get to the ModalKit demo."
        ),
        Comment(
            image: .systemYellow,
            username: "@techieTurtle",
            text: "What’s the best programming language? Whichever one helps you finish your project!"
        ),
        Comment(
            image: .systemTeal,
            username: "@nightCoder",
            text: "Why do programmers prefer dark mode? Because light attracts bugs!"
        ),
        Comment(
            image: .systemIndigo,
            username: "@swiftFanboy",
            text: "Why is Swift so fast? Because it avoids slow syntax and runtime errors."
        ),
        Comment(
            image: .systemRed,
            username: "@bugSquasher",
            text: "What’s the best way to fix a bug? Stop writing new ones!"
        ),
        Comment(
            image: .systemBrown,
            username: "@lazyDev",
            text: "Why did I write this comment? Because I love contributing random thoughts."
        )
    ]

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        tableView.allowsMultipleSelection = true
    }

    // MARK: Methods

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
        tableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier, for: indexPath) as? CommentCell else {
            fatalError()
        }

        let comment = comments[indexPath.row]
        cell.configure(with: comment)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6

        let headerLabel = UILabel()
        headerLabel.text = "Comments \(comments.count)"
        headerLabel.font = .systemFont(ofSize: 14, weight: .bold)
        headerLabel.textColor = .systemGray

        headerView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        return headerView
    }
}
