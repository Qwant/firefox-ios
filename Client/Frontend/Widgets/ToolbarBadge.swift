// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class ToolbarBadge: UIView {
    // MARK: - Variables
    private let badgeSize: CGFloat
    private let badgeOffset = CGFloat(10)
    private lazy var background: UIImageView = .build { _ in }
    private lazy var badge: UIImageView = .build { _ in }

    // MARK: - Initializers
    init(imageName: String, imageMask: String, size: CGFloat, padding: CGFloat = 0) {
        badgeSize = size
        super.init(frame: CGRect(width: badgeSize, height: badgeSize))

        background.image = UIImage(imageLiteralResourceName: imageMask)
        badge.image = UIImage(imageLiteralResourceName: imageName)
        badge.tintAdjustmentMode = .normal

        setupLayout(padding: padding)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout(padding: CGFloat) {
        addSubview(background)
        addSubview(badge)
        isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: topAnchor),
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),

            badge.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            badge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            badge.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            badge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            widthAnchor.constraint(equalToConstant: badgeSize),
            heightAnchor.constraint(equalToConstant: badgeSize)
        ])
    }

    // MARK: - View setup

    func tintBackground(color: UIColor) {
        background.tintColor = color
    }

    func tintImage(color: UIColor) {
        badge.tintColor = color
    }
}
