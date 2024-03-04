// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class QwantIntroScreen2: UIView, ThemeApplicable {
    var nextClosure: (() -> Void)?
    var ignoreClosure: (() -> Void)?

    var isShownStandalone = false {
        didSet {
            ignoreButton.isHidden = isShownStandalone
            let title: String = isShownStandalone ? .QwantOnboarding.LetsGoButtonTitle : .QwantOnboarding.NextButtonTitle
            continueButton.setTitle(title, for: .normal)
            setNeedsLayout()
        }
    }

    // MARK: UI components
    private lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "protected")
    }

    private lazy var ignoreButton: UIButton = .build { button in
        button.setTitle(.QwantOnboarding.IgnoreButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(self.ignoreTapped), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    private lazy var titleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Title.l
        label.numberOfLines = 2
        label.text = .QwantOnboarding.QwantVIPTitle
        label.adjustsFontSizeToFitWidth = true
    }

    private lazy var bullet1: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bullet")
    }

    private lazy var bulletContent1: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
        label.attributedText = String.QwantOnboarding.QwantVIPBullet1.makeDoubleStarsTagsBoldAndRemoveThem
    }

    private lazy var bullet2: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bullet")
    }

    private lazy var bulletContent2: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
        label.attributedText = String.QwantOnboarding.QwantVIPBullet2.makeDoubleStarsTagsBoldAndRemoveThem
    }

    private lazy var continueButton: UIButton = .build { button in
        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.addTarget(self, action: #selector(self.continueTapped), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    @objc
    private func continueTapped() {
        nextClosure?()
    }

    @objc
    private func ignoreTapped() {
        ignoreClosure?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialViewSetup()
    }

    private func initialViewSetup() {
        addSubviews(imageView,
                    ignoreButton,
                    titleLabel,
                    bullet1,
                    bullet2,
                    bulletContent1,
                    bulletContent2,
                    continueButton)

        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent1.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent2.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            ignoreButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            ignoreButton.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),

            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: QwantUX.Spacing.l),
            titleLabel.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),
            titleLabel.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),

            bulletContent1.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: QwantUX.Spacing.m),
            bulletContent1.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),
            bulletContent1.leadingAnchor.constraint(
                equalTo: bullet1.trailingAnchor,
                constant: QwantUX.Spacing.m),

            bullet1.centerYAnchor.constraint(
                equalTo: bulletContent1.firstBaselineAnchor,
                constant: -QwantUX.Spacing.xxs),
            bullet1.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),
            bullet1.widthAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),
            bullet1.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),

            bulletContent2.topAnchor.constraint(
                equalTo: bulletContent1.bottomAnchor,
                constant: QwantUX.Spacing.xs),
            bulletContent2.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),
            bulletContent2.leadingAnchor.constraint(
                equalTo: bullet2.trailingAnchor,
                constant: QwantUX.Spacing.m),

            bullet2.centerYAnchor.constraint(
                equalTo: bulletContent2.firstBaselineAnchor,
                constant: -QwantUX.Spacing.xxs),
            bullet2.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),
            bullet2.widthAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),
            bullet2.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),

            continueButton.topAnchor.constraint(
                greaterThanOrEqualTo: bulletContent2.bottomAnchor,
                constant: QwantUX.Spacing.xl),
            continueButton.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),
            continueButton.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),
            continueButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -QwantUX.Spacing.xl),
            continueButton.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.buttonHeight),
        ])
    }

    func applyTheme(theme: Theme) {
        backgroundColor = theme.colors.onboarding_paleBlue
        ignoreButton.setTitleColor(theme.colors.onboarding_blackText, for: .normal)
        titleLabel.textColor = theme.colors.onboarding_blackText
        bulletContent1.textColor = theme.colors.onboarding_blackText
        bulletContent2.textColor = theme.colors.onboarding_blackText
        continueButton.setTitleColor(theme.colors.onboarding_whiteText, for: .normal)
        continueButton.backgroundColor = theme.colors.onboarding_blackText
    }
}
