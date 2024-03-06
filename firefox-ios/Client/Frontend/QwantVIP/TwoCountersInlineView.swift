// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class TwoCountersInlineView: UIView, ThemeApplicable {
    private let lView = UIView()
    private let lImageView = UIImageView()
    private let lCountLabel = UILabel()
    private let lTitleLabel = UILabel()

    private let rView = UIView()
    private let rImageView = UIImageView()
    private let rCountLabel = UILabel()
    private let rTitleLabel = UILabel()

    private var internalConstraints = [NSLayoutConstraint]()

    init(lIcon: UIImage, lValue: String, lTitle: String,
         rIcon: UIImage, rValue: String, rTitle: String) {
        super.init(frame: .zero)

        lView.translatesAutoresizingMaskIntoConstraints = false
        lView.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius

        lImageView.translatesAutoresizingMaskIntoConstraints = false
        lImageView.contentMode = .scaleAspectFit
        lImageView.layer.zPosition = 0
        lImageView.image = lIcon

        lCountLabel.translatesAutoresizingMaskIntoConstraints = false
        lCountLabel.font = QwantUX.Font.Title.m
        lCountLabel.adjustsFontSizeToFitWidth = true
        lCountLabel.textAlignment = .natural
        lCountLabel.numberOfLines = 1
        lCountLabel.layer.zPosition = 1
        lCountLabel.text = lValue

        lTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        lTitleLabel.font = QwantUX.Font.Text.m
        lTitleLabel.adjustsFontSizeToFitWidth = true
        lTitleLabel.textAlignment = .natural
        lTitleLabel.numberOfLines = 1
        lTitleLabel.layer.zPosition = 1
        lTitleLabel.text = lTitle

        rView.translatesAutoresizingMaskIntoConstraints = false
        rView.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius

        rImageView.translatesAutoresizingMaskIntoConstraints = false
        rImageView.contentMode = .scaleAspectFit
        rImageView.layer.zPosition = 0
        rImageView.image = rIcon

        rCountLabel.translatesAutoresizingMaskIntoConstraints = false
        rCountLabel.font = QwantUX.Font.Title.m
        rCountLabel.adjustsFontSizeToFitWidth = true
        rCountLabel.textAlignment = .natural
        rCountLabel.numberOfLines = 1
        rCountLabel.layer.zPosition = 1
        rCountLabel.text = rValue

        rTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rTitleLabel.font = QwantUX.Font.Text.m
        rTitleLabel.adjustsFontSizeToFitWidth = true
        rTitleLabel.textAlignment = .natural
        rTitleLabel.numberOfLines = 1
        rTitleLabel.layer.zPosition = 1
        rTitleLabel.text = rTitle

        lView.addSubviews(lImageView, lCountLabel, lTitleLabel)
        rView.addSubviews(rImageView, rCountLabel, rTitleLabel)
        addSubviews(lView, rView)

        doConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func doConstraints() {
        NSLayoutConstraint.deactivate(internalConstraints)
        internalConstraints.removeAll()

        let lConstraints = [
            lImageView.bottomAnchor.constraint(
                equalTo: lView.bottomAnchor,
                constant: -QwantUX.Spacing.s),
            lImageView.trailingAnchor.constraint(
                equalTo: lView.trailingAnchor,
                constant: -QwantUX.Spacing.m),
            lImageView.widthAnchor.constraint(equalToConstant: 28),
            lImageView.heightAnchor.constraint(equalToConstant: 28),

            lTitleLabel.topAnchor.constraint(
                equalTo: lView.topAnchor,
                constant: QwantUX.Spacing.s),
            lTitleLabel.leadingAnchor.constraint(
                equalTo: lView.leadingAnchor,
                constant: QwantUX.Spacing.m),
            lTitleLabel.trailingAnchor.constraint(
                equalTo: lView.trailingAnchor,
                constant: -QwantUX.Spacing.m),

            lCountLabel.topAnchor.constraint(
                equalTo: lTitleLabel.bottomAnchor,
                constant: QwantUX.Spacing.xs),
            lCountLabel.leadingAnchor.constraint(equalTo: lTitleLabel.leadingAnchor),
            lCountLabel.trailingAnchor.constraint(
                equalTo: lImageView.leadingAnchor,
                constant: -QwantUX.Spacing.xs),
            lCountLabel.bottomAnchor.constraint(
                equalTo: lView.bottomAnchor,
                constant: -QwantUX.Spacing.s),
        ]

        let rConstraints = [
            rImageView.bottomAnchor.constraint(
                equalTo: rView.bottomAnchor,
                constant: -QwantUX.Spacing.s),
            rImageView.trailingAnchor.constraint(
                equalTo: rView.trailingAnchor,
                constant: -QwantUX.Spacing.m),
            rImageView.widthAnchor.constraint(equalToConstant: 28),
            rImageView.heightAnchor.constraint(equalToConstant: 28),

            rTitleLabel.topAnchor.constraint(
                equalTo: rView.topAnchor,
                constant: QwantUX.Spacing.s),
            rTitleLabel.leadingAnchor.constraint(
                equalTo: rView.leadingAnchor,
                constant: QwantUX.Spacing.m),
            rTitleLabel.trailingAnchor.constraint(
                equalTo: rView.trailingAnchor,
                constant: -QwantUX.Spacing.m),

            rCountLabel.topAnchor.constraint(
                equalTo: rTitleLabel.bottomAnchor,
                constant: QwantUX.Spacing.xs),
            rCountLabel.leadingAnchor.constraint(equalTo: rTitleLabel.leadingAnchor),
            rCountLabel.trailingAnchor.constraint(
                equalTo: rImageView.leadingAnchor,
                constant: -QwantUX.Spacing.xs),
            rCountLabel.bottomAnchor.constraint(
                equalTo: rView.bottomAnchor,
                constant: -QwantUX.Spacing.s),
        ]

        let allConstraints = [
            lView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: QwantUX.Spacing.xl),
            lView.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.m),
            lView.trailingAnchor.constraint(
                equalTo: rView.leadingAnchor,
                constant: -QwantUX.Spacing.xs),
            rView.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.m),
            rView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor,
                constant: QwantUX.Spacing.xl),
            lView.widthAnchor.constraint(equalTo: rView.widthAnchor),
            lView.heightAnchor.constraint(equalTo: rView.heightAnchor)
        ]

        internalConstraints.append(contentsOf: lConstraints)
        internalConstraints.append(contentsOf: rConstraints)
        internalConstraints.append(contentsOf: allConstraints)

        NSLayoutConstraint.activate(internalConstraints)
    }

    func applyTheme(theme: Theme) {
        backgroundColor = theme.colors.vip_background

        lView.backgroundColor = theme.colors.vip_sectionColor
        lTitleLabel.textColor = theme.colors.vip_textColor
        lCountLabel.textColor = theme.colors.vip_textColor

        rView.backgroundColor = theme.colors.vip_sectionColor
        rTitleLabel.textColor = theme.colors.vip_textColor
        rCountLabel.textColor = theme.colors.vip_textColor
    }
}
