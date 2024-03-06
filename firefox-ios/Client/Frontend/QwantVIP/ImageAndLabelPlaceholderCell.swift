// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class ImageAndLabelPlaceholderCell: UITableViewCell, ThemeApplicable {
    static let Identifier = "ImageAndLabelPlaceholderCell"

    private let placeholder = UIImageView(image: UIImage(named: "illustration_no_trackers")!)
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.contentMode = .scaleAspectFit

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = QwantUX.Font.Text.l
        label.numberOfLines = 0
        label.textAlignment = .center

        contentView.addSubviews(placeholder, label)

        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeholder.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: QwantUX.Spacing.m),
            placeholder.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -QwantUX.Spacing.m),
            placeholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            label.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: QwantUX.Spacing.xxxxxl),
            label.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: QwantUX.Spacing.xxxxl),
            label.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -QwantUX.Spacing.xxxxl),
            label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme(theme: Theme) {
        label.textColor = theme.colors.vip_textColor
    }

    func setValue(value: String) {
        label.text = value
    }
}
