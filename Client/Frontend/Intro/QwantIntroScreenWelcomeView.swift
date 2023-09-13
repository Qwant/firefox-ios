// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

class QwantIntroScreenWelcomeView: UIView {
    
    var nextClosure: (() -> Void)?
    var defaultBrowserClosure: (() -> Void)?
    
    // MARK: UI components
    private lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "anonymous")
    }
    
    private lazy var titleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.title
        label.numberOfLines = 2
        label.text = .QwantIntro.WelcomeTitle
        label.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var subtitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.text
        label.numberOfLines = 2
        label.text = .QwantIntro.WelcomeSubtitle
        label.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var bullet1: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bullet")
    }
    
    private lazy var bulletContent1: UILabel = .build { label in
        label.font = QwantUX.Font.text
        label.numberOfLines = 0
        label.text = .QwantIntro.WelcomeBullet1
    }
    
    private lazy var bullet2: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bullet")
    }
    
    private lazy var bulletContent2: UILabel = .build { label in
        label.font = QwantUX.Font.text
        label.numberOfLines = 0
        label.text = .QwantIntro.WelcomeBullet2
    }
    
    private lazy var bullet3: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bullet")
    }
    
    private lazy var bulletContent3: UILabel = .build { label in
        label.font = QwantUX.Font.text
        label.numberOfLines = 0
        label.text = .QwantIntro.WelcomeBullet3
    }
    
    private lazy var defaultBrowserButton: UIButton = .build { button in
        button.layer.cornerRadius = 8
        button.setTitle(.QwantIntro.WelcomeDefaultBrowser, for: .normal)
        button.addTarget(self, action: #selector(self.defaultBrowserTapped), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var skipButton: UIButton = .build { button in
        button.layer.cornerRadius = 8
        button.setTitle(.QwantIntro.WelcomeIgnore, for: .normal)
        button.addTarget(self, action: #selector(self.skipTapped), for: .touchUpInside)
    }
    
    @objc private func defaultBrowserTapped() {
        defaultBrowserClosure?()
    }
    
    @objc private func skipTapped() {
        nextClosure?()
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
        backgroundColor = .Qwant.Theme.PaleViolet
        titleLabel.textColor = .black
        subtitleLabel.textColor = .black
        bulletContent1.textColor = .black
        bulletContent2.textColor = .black
        bulletContent3.textColor = .black
        defaultBrowserButton.setTitleColor(.white, for: .normal)
        defaultBrowserButton.backgroundColor = .black
        skipButton.setTitleColor(.black, for: .normal)
        
        addSubviews(imageView, titleLabel, subtitleLabel, bullet1, bullet2, bullet3, bulletContent1, bulletContent2, bulletContent3, defaultBrowserButton, skipButton)
        
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent1.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent2.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent3.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterL),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: QwantUX.Spacing.l),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterM),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.gutterM),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: QwantUX.Spacing.m),
            subtitleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterM),
            subtitleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.gutterM),
            
            bulletContent1.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: QwantUX.Spacing.s),
            bulletContent1.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.gutterM),
            bulletContent1.leadingAnchor.constraint(equalTo: bullet1.trailingAnchor, constant: QwantUX.Spacing.m),
            
            bullet1.centerYAnchor.constraint(equalTo: bulletContent1.firstBaselineAnchor, constant: -QwantUX.Spacing.xxs),
            bullet1.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterM),
            bullet1.widthAnchor.constraint(equalToConstant: QwantUX.Spacing.bulletHeight),
            bullet1.heightAnchor.constraint(equalToConstant: QwantUX.Spacing.bulletHeight),
            
            bulletContent2.topAnchor.constraint(equalTo: bulletContent1.bottomAnchor, constant: QwantUX.Spacing.xs),
            bulletContent2.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.gutterM),
            bulletContent2.leadingAnchor.constraint(equalTo: bullet2.trailingAnchor, constant: QwantUX.Spacing.m),
            
            bullet2.centerYAnchor.constraint(equalTo: bulletContent2.firstBaselineAnchor, constant: -QwantUX.Spacing.xxs),
            bullet2.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterM),
            bullet2.widthAnchor.constraint(equalToConstant: QwantUX.Spacing.bulletHeight),
            bullet2.heightAnchor.constraint(equalToConstant: QwantUX.Spacing.bulletHeight),
            
            bulletContent3.topAnchor.constraint(equalTo: bulletContent2.bottomAnchor, constant: QwantUX.Spacing.xs),
            bulletContent3.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.gutterM),
            bulletContent3.leadingAnchor.constraint(equalTo: bullet3.trailingAnchor, constant: QwantUX.Spacing.m),
            
            bullet3.centerYAnchor.constraint(equalTo: bulletContent3.firstBaselineAnchor, constant: -QwantUX.Spacing.xxs),
            bullet3.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterM),
            bullet3.widthAnchor.constraint(equalToConstant: QwantUX.Spacing.bulletHeight),
            bullet3.heightAnchor.constraint(equalToConstant: QwantUX.Spacing.bulletHeight),
            
            defaultBrowserButton.topAnchor.constraint(equalTo: bulletContent3.bottomAnchor, constant: QwantUX.Spacing.xl),
            defaultBrowserButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterM),
            defaultBrowserButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.gutterM),
            defaultBrowserButton.heightAnchor.constraint(equalToConstant: QwantUX.Spacing.buttonHeight),
            
            skipButton.topAnchor.constraint(equalTo: defaultBrowserButton.bottomAnchor, constant: QwantUX.Spacing.xs),
            skipButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.gutterM),
            skipButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.gutterM),
            skipButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -QwantUX.Spacing.xs),
            skipButton.heightAnchor.constraint(equalToConstant: QwantUX.Spacing.buttonHeight),
        ])
    }
}
