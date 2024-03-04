// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

enum QwantIntroContent {
    case full
    case onlyVIP
}

class QwantIntroViewController: UIViewController, Themeable {
    var themeManager: ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: NotificationProtocol

    var didFinishFlow: (() -> Void)?

    private lazy var welcomeCard: QwantIntroScreen1 = .build { view in
        view.clipsToBounds = true
    }

    private lazy var qwantVIPCard: QwantIntroScreen2 = .build { view in
        view.clipsToBounds = true
        view.isShownStandalone = self.contentDisplayed == .onlyVIP
    }

    private lazy var defaultBrowserCard: QwantIntroScreen3 = .build { view in
        view.clipsToBounds = true
    }

    var contentDisplayed: QwantIntroContent

    // MARK: Initializer
    init(_ content: QwantIntroContent,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.contentDisplayed = content
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViewSetup()
    }

    // MARK: View setup
    private func initialViewSetup() {
        setupIntroView()
    }

    // Onboarding intro view
    private func setupIntroView() {
        if contentDisplayed == .onlyVIP {
            view.addSubview(qwantVIPCard)
            setupQwantVIPCard()
            return
        }

        // Initialize
        view.addSubview(defaultBrowserCard)
        view.addSubview(qwantVIPCard)
        view.addSubview(welcomeCard)

        // Constraints
        setupWelcomeCard()
        setupQwantVIPCard()
        setupDefaultBrowserCard()
    }

    private func setupWelcomeCard() {
        NSLayoutConstraint.activate([
            welcomeCard.topAnchor.constraint(equalTo: view.topAnchor),
            welcomeCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            welcomeCard.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        welcomeCard.nextClosure = {
            self.dismissWelcomeCard()
        }

        welcomeCard.ignoreClosure = {
            self.didFinishFlow?()
        }

        welcomeCard.applyTheme(theme: themeManager.currentTheme)
    }

    private func dismissWelcomeCard() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.welcomeCard.alpha = 0
            }
        ) { _ in
            self.welcomeCard.isHidden = true
        }
    }

    private func setupQwantVIPCard() {
        NSLayoutConstraint.activate([
            qwantVIPCard.topAnchor.constraint(equalTo: view.topAnchor),
            qwantVIPCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qwantVIPCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            qwantVIPCard.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        qwantVIPCard.nextClosure = {
            if self.contentDisplayed == .onlyVIP {
                self.didFinishFlow?()
            } else {
                self.dismissQwantVIPCard()
            }
        }

        qwantVIPCard.ignoreClosure = {
            self.didFinishFlow?()
        }

        qwantVIPCard.applyTheme(theme: themeManager.currentTheme)
    }

    private func dismissQwantVIPCard() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.qwantVIPCard.alpha = 0
            }
        ) { _ in
            self.qwantVIPCard.isHidden = true
        }
    }

    private func setupDefaultBrowserCard() {
        NSLayoutConstraint.activate([
            defaultBrowserCard.topAnchor.constraint(equalTo: view.topAnchor),
            defaultBrowserCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            defaultBrowserCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            defaultBrowserCard.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        defaultBrowserCard.ignoreClosure = {
            self.didFinishFlow?()
        }

        defaultBrowserCard.openSettingsClosure = {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { _ in
                self.didFinishFlow?()
            }
        }

        defaultBrowserCard.applyTheme(theme: themeManager.currentTheme)
    }

    func applyTheme() {
        let theme = themeManager.currentTheme
        welcomeCard.applyTheme(theme: theme)
        qwantVIPCard.applyTheme(theme: theme)
        defaultBrowserCard.applyTheme(theme: theme)
    }
}

// MARK: UIViewController setup
extension QwantIntroViewController {
    override var prefersStatusBarHidden: Bool {
        return false
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
