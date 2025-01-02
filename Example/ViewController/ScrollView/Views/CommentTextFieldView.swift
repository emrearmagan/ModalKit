//
//  CommentTextFieldView.swift
//  ModalKitExample
//
//  Created by Emre Armagan on 02.01.25.
//  Copyright © 2025 Emre Armagan. All rights reserved.
//

import UIKit

final class CommentTextFieldView: UIView {
    private let profileView = UIView()
    // not an actual Textfield. We could probably do that and adjust the safeAreaInsets so that this view is always sticky
    private let textfieldView = UIStackView()
    private let placeholderLabel = UILabel()
    private let sendButton = UIButton()
    private let emojiStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }

    private func setupUI() {
        createEmojis()
        profileView.layer.cornerRadius = 20
        profileView.backgroundColor = .purple

        placeholderLabel.text = "Add a comment..."
        placeholderLabel.font = .systemFont(ofSize: 14, weight: .medium)
        placeholderLabel.textColor = .secondaryLabel

        textfieldView.layer.borderColor = UIColor.secondaryLabel.cgColor
        textfieldView.layer.borderWidth = 1
        textfieldView.layer.cornerRadius = 5
        textfieldView.layoutMargins = .init(top: 5, left: 5, bottom: 5, right: 5)
        textfieldView.isLayoutMarginsRelativeArrangement = true

        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "paperplane.circle.fill")
        sendButton.configuration = config
        sendButton.isUserInteractionEnabled = false

        textfieldView.addArrangedSubview(placeholderLabel)
        textfieldView.addArrangedSubview(sendButton)
        sendButton.setContentHuggingPriority(.required, for: .horizontal)

        addSubview(profileView)
        addSubview(textfieldView)
        addSubview(emojiStackView)

        profileView.translatesAutoresizingMaskIntoConstraints = false
        textfieldView.translatesAutoresizingMaskIntoConstraints = false
        emojiStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            profileView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            profileView.centerYAnchor.constraint(equalTo: textfieldView.centerYAnchor),
            profileView.widthAnchor.constraint(equalToConstant: 40),
            profileView.heightAnchor.constraint(equalToConstant: 40),

            textfieldView.topAnchor.constraint(equalTo: emojiStackView.bottomAnchor, constant: 16),
            textfieldView.leadingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: 8),
            textfieldView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textfieldView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func createEmojis() {
        emojiStackView.axis = .horizontal
        emojiStackView.distribution = .fillEqually
        emojiStackView.alignment = .center
        emojiStackView.spacing = 10

        let emojis = ["🔥", "❤️" ,"👏", "🙏", "💪", "🚀", "😂", "🎉"]

        for emoji in emojis {
            let label = UILabel()
            label.text = emoji
            label.font = UIFont.systemFont(ofSize: 20)
            label.textAlignment = .center
            emojiStackView.addArrangedSubview(label)
        }
    }
}
