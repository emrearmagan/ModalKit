//
//  CommentCell.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 30.12.24.
//  Copyright © 2024 Emre Armagan. All rights reserved.
//

import UIKit

/// A custom table view cell representing a comment.
final class CommentCell: UITableViewCell {
    static let reuseIdentifier = "CommentCell"

    private let profileView = UIView()
    private let usernameLabel = UILabel()
    private let commentLabel = UILabel()
    private let heartButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the cell with the provided `Comment`.
    /// - Parameter comment: The comment data to display in the cell.
    func configure(with comment: Comment) {
        profileView.backgroundColor = comment.image
        usernameLabel.text = comment.username
        commentLabel.text = comment.text
    }

    private func setupUI() {
        selectionStyle = .none

        profileView.layer.cornerRadius = 35 / 2

        usernameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        usernameLabel.textColor = .label

        commentLabel.font = .systemFont(ofSize: 14)
        commentLabel.textColor = .secondaryLabel
        commentLabel.numberOfLines = 0

        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.image = UIImage(systemName: "heart")
        heartButton.configuration = config
        heartButton.configurationUpdateHandler = { button in
            button.configuration?.baseForegroundColor = button.isSelected ? .red : .systemGray
            button.configuration?.image = button.isSelected
                ? UIImage(systemName: "heart.fill")
                : UIImage(systemName: "heart")
        }
        heartButton.isUserInteractionEnabled = false

        contentView.addSubview(profileView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(heartButton)

        profileView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        heartButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileView.widthAnchor.constraint(equalToConstant: 35),
            profileView.heightAnchor.constraint(equalToConstant: 35),

            usernameLabel.leadingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: heartButton.leadingAnchor, constant: -16),
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            commentLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            commentLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            commentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            heartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            heartButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 30),
            heartButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        heartButton.isSelected = selected
    }
}
