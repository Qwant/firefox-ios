// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class ButtonCell: UITableViewCell, ThemeApplicable {
    static let Identifier = "ButtonCell"

    private lazy var button: UIButton =  {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = QwantUX.Spacing.xxs
        return UIButton(configuration: configuration)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.clipsToBounds = true

        button.titleLabel?.font = QwantUX.Font.Text.l
        button.isUserInteractionEnabled = false

        contentView.addSubviews(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: QwantUX.Spacing.s),
            button.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: QwantUX.Spacing.m),
            button.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -QwantUX.Spacing.m),
            button.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -QwantUX.Spacing.s)
        ])
    }

    func configureCell(icon: UIImage, text: String, color: UIColor) {
        button.setImage(icon, for: .normal)
        button.setTitle(text, for: .normal)
        button.setTitleColor(color, for: .normal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme(theme: Theme) { }
}
