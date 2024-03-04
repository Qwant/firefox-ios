// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class QwantIntroScreen3: UIView, ThemeApplicable {
    var openSettingsClosure: (() -> Void)?
    var ignoreClosure: (() -> Void)?

    // MARK: UI components
    private lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "default_browser")
    }

    private lazy var ignoreButton: UIButton = .build { button in
        button.setTitle(.QwantOnboarding.LaterButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(self.ignoreTapped), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    private lazy var titleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Title.l
        label.numberOfLines = 3
        label.text = .QwantOnboarding.DefaultBrowserTitle
        label.adjustsFontSizeToFitWidth = true
    }

    private lazy var subtitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 2
        label.text = .QwantOnboarding.DefaultBrowserSubtitle
        label.adjustsFontSizeToFitWidth = true
    }

    private lazy var bulletContent1: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
        label.attributedText = String.QwantOnboarding.DefaultBrowserBullet1.makeDoubleStarsTagsBoldAndRemoveThem
    }

    private lazy var bulletContent2: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
        label.attributedText = String.QwantOnboarding.DefaultBrowserBullet2.makeDoubleStarsTagsBoldAndRemoveThem
    }

    private lazy var bulletContent3: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
        label.attributedText = String.QwantOnboarding.DefaultBrowserBullet3.makeDoubleStarsTagsBoldAndRemoveThem
    }

    private lazy var openSettingsButton: UIButton = .build { button in
        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.setTitle(.QwantOnboarding.SettingsButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(self.openSettingsTapped), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    @objc
    private func openSettingsTapped() {
        openSettingsClosure?()
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
                    subtitleLabel,
                    bulletContent1,
                    bulletContent2,
                    bulletContent3,
                    openSettingsButton)

        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent1.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent2.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent3.setContentCompressionResistancePriority(.required, for: .vertical)

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

            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: QwantUX.Spacing.m),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),

            bulletContent1.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: QwantUX.Spacing.s),
            bulletContent1.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),
            bulletContent1.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),

            bulletContent2.topAnchor.constraint(
                equalTo: bulletContent1.bottomAnchor,
                constant: QwantUX.Spacing.xs),
            bulletContent2.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),
            bulletContent2.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),

            bulletContent3.topAnchor.constraint(
                equalTo: bulletContent2.bottomAnchor,
                constant: QwantUX.Spacing.xs),
            bulletContent3.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),
            bulletContent3.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),

            openSettingsButton.topAnchor.constraint(
                greaterThanOrEqualTo: bulletContent3.bottomAnchor,
                constant: QwantUX.Spacing.xl),
            openSettingsButton.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: QwantUX.Spacing.xl),
            openSettingsButton.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -QwantUX.Spacing.xl),
            openSettingsButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -QwantUX.Spacing.xl),
            openSettingsButton.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.buttonHeight),
        ])
    }

    func applyTheme(theme: Theme) {
        backgroundColor = theme.colors.onboarding_paleGreen
        ignoreButton.setTitleColor(theme.colors.onboarding_blackText, for: .normal)
        titleLabel.textColor = theme.colors.onboarding_blackText
        subtitleLabel.textColor = theme.colors.onboarding_blackText
        bulletContent1.textColor = theme.colors.onboarding_blackText
        bulletContent2.textColor = theme.colors.onboarding_blackText
        bulletContent3.textColor = theme.colors.onboarding_blackText
        openSettingsButton.setTitleColor(theme.colors.onboarding_whiteText, for: .normal)
        openSettingsButton.backgroundColor = theme.colors.onboarding_blackText
    }
}
