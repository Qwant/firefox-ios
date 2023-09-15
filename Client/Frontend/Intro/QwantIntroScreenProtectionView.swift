// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

class QwantIntroScreenProtectionView: UIView {
    
    var startBrowsingClosure: (() -> Void)?
    
    // MARK: UI components
    
    private lazy var imageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "navigation")
    }
    
    private lazy var titleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Title.m
        label.numberOfLines = 2
        label.text = .QwantIntro.ProtectionTitle
        label.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var bullet1: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bullet")
    }
    
    private lazy var bulletContent1: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
        label.text = .QwantIntro.ProtectionBullet1
    }
    
    private lazy var bullet2: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bullet")
    }
    
    private lazy var bulletContent2: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
        label.text = .QwantIntro.ProtectionBullet2
    }
    
    private lazy var subtitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 2
        label.text = .QwantIntro.ProtectionSubtitle
        label.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var startBrowsingButton: UIButton = .build { button in
        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.setTitle(.QwantIntro.ProtectionStartBrowsing, for: .normal)
        button.addTarget(self, action: #selector(self.startBrowsingTapped), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @objc private func startBrowsingTapped() {
        startBrowsingClosure?()
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
        backgroundColor = .Qwant.Theme.PaleGreen
        titleLabel.textColor = .black
        bulletContent1.textColor = .black
        bulletContent2.textColor = .black
        subtitleLabel.textColor = .black
        startBrowsingButton.setTitleColor(.white, for: .normal)
        startBrowsingButton.backgroundColor = .black
        
        addSubviews(imageView, titleLabel, bullet1, bullet2, bulletContent1, bulletContent2, subtitleLabel, startBrowsingButton)
        
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent1.setContentCompressionResistancePriority(.required, for: .vertical)
        bulletContent2.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: QwantUX.Spacing.l),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xxxxl),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: QwantUX.Spacing.l),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            
            bulletContent1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: QwantUX.Spacing.xl),
            bulletContent1.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            bulletContent1.leadingAnchor.constraint(equalTo: bullet1.trailingAnchor, constant: QwantUX.Spacing.m),
            
            bullet1.centerYAnchor.constraint(equalTo: bulletContent1.firstBaselineAnchor, constant: -QwantUX.Spacing.xxs),
            bullet1.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            bullet1.widthAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),
            bullet1.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),
            
            bulletContent2.topAnchor.constraint(equalTo: bulletContent1.bottomAnchor, constant: QwantUX.Spacing.xs),
            bulletContent2.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            bulletContent2.leadingAnchor.constraint(equalTo: bullet2.trailingAnchor, constant: QwantUX.Spacing.m),
            
            bullet2.centerYAnchor.constraint(equalTo: bulletContent2.firstBaselineAnchor, constant: -QwantUX.Spacing.xxs),
            bullet2.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            bullet2.widthAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),
            bullet2.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.bulletHeight),
            
            subtitleLabel.topAnchor.constraint(equalTo: bulletContent2.bottomAnchor, constant: QwantUX.Spacing.xl),
            subtitleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            subtitleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            
            
            startBrowsingButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: QwantUX.Spacing.xxxl),
            startBrowsingButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            startBrowsingButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            startBrowsingButton.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.buttonHeight),
            startBrowsingButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -QwantUX.Spacing.xxxl),
        ])
    }
    
}
