// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import UIKit
import SnapKit
import Shared
import Common

class QwantDefaultBrowserOnboardingViewController: UIViewController {
    // Closure delegate
    var didFinishClosure: ((QwantDefaultBrowserOnboardingViewController) -> Void)?
    
    private lazy var titleLabel: UILabel = .build { label in
        label.text = .QwantDefaultBrowser.DefaultBrowserTitle
        label.textColor = .black
        label.font = QwantUX.Font.Title.m
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 3
    }
    
    private lazy var subtitleLabel: UILabel = .build { label in
        label.text = .QwantDefaultBrowser.DefaultBrowserDescription
        label.textColor = .black
        label.font = QwantUX.Font.Text.m
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
    }
    
    private lazy var imageView: UIImageView = .build { imageView in
        imageView.image = UIImage(named: "default_browser")
        imageView.contentMode = .scaleAspectFit
    }
    
    private lazy var openSettingsButton: UIButton = .build { button in
        button.titleLabel?.font = QwantUX.Font.Text.l
        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.backgroundColor = .black
        button.setTitle(.QwantDefaultBrowser.DefaultBrowserButtonSettings, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.accessibilityIdentifier = "openSettingButtonIntroView"
        button.addTarget(self, action: #selector(self.openSettingsAction), for: .touchUpInside)
    }
    
    private lazy var ignoreButton: UIButton = .build { button in
        button.titleLabel?.font = QwantUX.Font.Text.l
        button.backgroundColor = .clear
        button.setTitle(.QwantDefaultBrowser.DefaultBrowserButtonIgnore, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.accessibilityIdentifier = "ignoreButtonIntroView"
        button.addTarget(self, action: #selector(self.ignoreAction), for: .touchUpInside)
    }
    
    // MARK: Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .Qwant.Theme.PaleViolet
        view.addSubviews(imageView, titleLabel, subtitleLabel, openSettingsButton, ignoreButton)
        
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: QwantUX.Spacing.xl),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xxxxl),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: QwantUX.Spacing.xl),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: QwantUX.Spacing.m),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            
            openSettingsButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: QwantUX.Spacing.xxxl),
            openSettingsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            openSettingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            openSettingsButton.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.buttonHeight),
            
            ignoreButton.topAnchor.constraint(equalTo: openSettingsButton.bottomAnchor, constant: QwantUX.Spacing.xs),
            ignoreButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xl),
            ignoreButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xl),
            ignoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -QwantUX.Spacing.xl),
            ignoreButton.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.buttonHeight)
        ])
    }
    
    @objc private func openSettingsAction() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
        self.didFinishClosure?(self)
    }
    
    @objc private func ignoreAction() {
        self.didFinishClosure?(self)
    }
}

// MARK: UIViewController setup
extension QwantDefaultBrowserOnboardingViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}
