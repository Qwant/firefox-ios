// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared

class QwantVIPButton: UIButton {
    private lazy var badgeLabel: UILabel = .build { label in
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.layer.zPosition = 1
        label.layer.masksToBounds = false
        label.textAlignment = .center
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        setImage(UIImage(imageLiteralResourceName: "qwant_vip_on"), for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBadgeValue(value: String?) {
        guard let value = value else {
            badgeLabel.isHidden = true
            return
        }
        badgeLabel.isHidden = false
        badgeLabel.text = value
    }

    private var badgeColor: UIColor = LightTheme().colors.vip_greenIcon

    func setBadgeColor(color: UIColor) {
        badgeColor = color
        applyTheme()
    }

    func animateIfNeeded() {
        let value = Int(badgeLabel.text ?? "") ?? 0
        if value > 0 {
            increaseAnimation()
        }
    }
}

// MARK: - Theme protocols
extension QwantVIPButton: ThemeApplicable {
    func applyTheme(theme: Theme) {
        badgeColor = theme.colors.vip_greenIcon
        applyTheme()
    }

    private func applyTheme() {
        badgeLabel.textColor = badgeColor
        badgeLabel.layer.backgroundColor = UIColor.clear.cgColor
    }
}
