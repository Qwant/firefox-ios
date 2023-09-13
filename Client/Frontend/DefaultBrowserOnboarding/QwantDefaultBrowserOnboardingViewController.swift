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
    var didFinishClosure: ((QwantDefaultBrowserOnboardingViewController, FxAPageType?) -> Void)?
    
    // Private view
    private var fxTextThemeColour: UIColor {
        return LegacyThemeManager.instance.userInterfaceStyle == .dark ?
        UIColor(red: 245.0 / 255, green: 245.0 / 255, blue: 247.0 / 255, alpha: 1.0) :
            .black
    }
    private var fxSubTextThemeColour: UIColor {
        return LegacyThemeManager.instance.userInterfaceStyle == .dark ?
        UIColor(red: 217.0 / 255, green: 217.0 / 255, blue: 224.0 / 255, alpha: 1.0) :
        UIColor(red: 89.0 / 255, green: 89.0 / 255, blue: 95.0 / 255, alpha: 1.0)
    }
    private var fxBackgroundThemeColour: UIColor {
        return LegacyThemeManager.instance.userInterfaceStyle == .dark ?
        UIColor(red: 25.0 / 255, green: 25.0 / 255, blue: 27.0 / 255, alpha: 1.0) :
            .white
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = .QwantDefaultBrowser.DefaultBrowserTitle1
        label.textColor = fxTextThemeColour
        label.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    private lazy var titleBoldLabel: UILabel = {
        let label = UILabel()
        label.text = .QwantDefaultBrowser.DefaultBrowserTitle2
        label.textColor = fxTextThemeColour
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = .QwantDefaultBrowser.DefaultBrowserDescription
        label.textColor = fxSubTextThemeColour
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView(image: LegacyThemeManager.instance.userInterfaceStyle == .dark ? #imageLiteral(resourceName: "illustrationOnboardingDark") : #imageLiteral(resourceName: "illustrationOnboardingLight") )
        imgView.contentMode = .center
        return imgView
    }()
    
    private var openSettingsButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.layer.cornerRadius = 23
        button.backgroundColor = UIColor(red: 26.0 / 255, green: 106.0 / 255, blue: 1.0, alpha: 1.0)
        button.setTitle(.QwantDefaultBrowser.DefaultBrowserButtonSettings, for: .normal)
        button.accessibilityIdentifier = "openSettingButtonIntroView"
        return button
    }()
    
    private lazy var ignoreButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.backgroundColor = .clear
        button.setTitleColor(fxTextThemeColour, for: .normal)
        button.setTitle(.QwantDefaultBrowser.DefaultBrowserButtonIgnore, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.accessibilityIdentifier = "ignoreButtonIntroView"
        return button
    }()
    
    private let topContainerView = UIView()
    private let combinedView = UIView()
    
    private let screenSize = DeviceInfo.screenSizeOrientationIndependent()
    
    // MARK: Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
        topContainerViewSetup()
        bottomViewSetup()
    }
    
    // MARK: View setup
    private func initialViewSetup() {
        combinedView.addSubview(titleLabel)
        combinedView.addSubview(titleBoldLabel)
        combinedView.addSubview(subtitleLabel)
        combinedView.addSubview(imageView)
        topContainerView.addSubview(combinedView)
        view.addSubview(topContainerView)
        view.addSubview(openSettingsButton)
        view.addSubview(ignoreButton)
    }
    
    private func topContainerViewSetup() {
        // Background colour setup
        view.backgroundColor = fxBackgroundThemeColour
        // Height constants
        let titleLabelHeight = 35
        let titleBoldLabelHeight = 80
        let subtitleLabelHeight = 50
        let titleImageHeight = screenSize.height > 600 ? 300 : 200
        // Title label constraints
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.height.equalTo(titleLabelHeight)
        }
        titleBoldLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom)
            make.margins.equalTo(0)
            make.height.equalTo(titleBoldLabelHeight)
        }
        // Description label constraints
        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(titleBoldLabel.snp.bottom)
            make.height.equalTo(subtitleLabelHeight)
        }
        // Title image view constraints
        imageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom)
            make.height.equalTo(titleImageHeight)
        }
        // Top container view constraints
        topContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea.top)
            make.bottom.equalTo(openSettingsButton.snp.top)
            make.left.right.equalToSuperview()
        }
        // Combined view constraints
        combinedView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.height.equalTo(titleLabelHeight + subtitleLabelHeight + titleImageHeight)
            make.centerY.equalToSuperview()
            make.bottom.left.right.equalToSuperview()
        }
    }
    
    private func bottomViewSetup() {
        // Sign-up button constraints
        openSettingsButton.snp.makeConstraints { make in
            make.bottom.equalTo(ignoreButton.snp.top).offset(-20)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(46)
            
        }
        // Start browsing button constraints
        ignoreButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(24) // (view.safeArea.bottom)
            make.left.right.equalToSuperview().inset(80)
            make.height.equalTo(46)
        }
        // Sign-up and start browsing button action
        openSettingsButton.addTarget(self, action: #selector(openSettingsAction), for: .touchUpInside)
        ignoreButton.addTarget(self, action: #selector(ignoreAction), for: .touchUpInside)
    }
    
    @objc private func openSettingsAction() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
        self.didFinishClosure?(self, nil)
    }
    
    @objc private func ignoreAction() {
        self.didFinishClosure?(self, nil)
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
