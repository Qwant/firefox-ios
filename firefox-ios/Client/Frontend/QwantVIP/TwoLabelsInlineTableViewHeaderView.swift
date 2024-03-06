// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class TwoLabelsInlineTableViewHeaderView: UITableViewHeaderFooterView, ThemeApplicable {
    static let Identifier = "TwoLabelsInlineTableViewHeaderView"

    private let lHeaderTitleLabel = UILabel()
    private let rHeaderTitleLabel = UILabel()

    private var internalConstraints = [NSLayoutConstraint]()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        lHeaderTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        lHeaderTitleLabel.font = QwantUX.Font.Text.s
        lHeaderTitleLabel.adjustsFontSizeToFitWidth = true
        lHeaderTitleLabel.textAlignment = .left
        lHeaderTitleLabel.numberOfLines = 1

        rHeaderTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rHeaderTitleLabel.font = QwantUX.Font.Text.s
        rHeaderTitleLabel.adjustsFontSizeToFitWidth = true
        rHeaderTitleLabel.textAlignment = .right
        rHeaderTitleLabel.numberOfLines = 1

        contentView.addSubviews(lHeaderTitleLabel, rHeaderTitleLabel)

        doConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func doConstraints() {
        NSLayoutConstraint.deactivate(internalConstraints)
        internalConstraints.removeAll()

        let headerConstraints = [
            lHeaderTitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: QwantUX.Spacing.m),
            lHeaderTitleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -QwantUX.Spacing.xxs),

            rHeaderTitleLabel.leadingAnchor.constraint(
                equalTo: lHeaderTitleLabel.trailingAnchor,
                constant: QwantUX.Spacing.m),
            rHeaderTitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -QwantUX.Spacing.m),
            rHeaderTitleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -QwantUX.Spacing.xxs)
        ]

        internalConstraints.append(contentsOf: headerConstraints)

        NSLayoutConstraint.activate(internalConstraints)
    }

    func applyTheme(theme: Theme) {
        contentView.backgroundColor = .clear

        lHeaderTitleLabel.textColor = theme.colors.vip_subtextColor
        rHeaderTitleLabel.textColor = theme.colors.vip_subtextColor
    }

    func setValues(lValue: String, rValue: String) {
        lHeaderTitleLabel.text = lValue
        rHeaderTitleLabel.text = rValue
    }
}
