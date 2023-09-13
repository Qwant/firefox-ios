// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class QwantIntroViewController: UIViewController, OnViewDismissable {
    
    var onViewDismissed: (() -> Void)? = nil
    
    private lazy var welcomeCard: QwantIntroScreenWelcomeView = .build { view in
        view.clipsToBounds = true
    }
    
    private lazy var protectionCard: QwantIntroScreenProtectionView = .build { view in
        view.clipsToBounds = true
    }
    // Closure delegate
    var didFinishClosure: ((QwantIntroViewController, FxAPageType?) -> Void)?

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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDismissed?()
        onViewDismissed = nil
    }
    
    // MARK: View setup
    private func initialViewSetup() {
        setupIntroView()
    }
    
    //onboarding intro view
    private func setupIntroView() {
        // Initialize
        view.addSubview(protectionCard)
        view.addSubview(welcomeCard)
        
        // Constraints
        setupWelcomeCard()
        setupProtectionCard()
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
        
        // Sign in button closure
        welcomeCard.defaultBrowserClosure = {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { _ in
                self.dismissWelcomeCard()
            }
        }
    }
    
    private func dismissWelcomeCard() {
        UIView.animate(withDuration: 0.3, animations: {
            self.welcomeCard.alpha = 0
        }) { _ in
            self.welcomeCard.isHidden = true
        }
    }
    
    private func setupProtectionCard() {
        NSLayoutConstraint.activate([
            protectionCard.topAnchor.constraint(equalTo: view.topAnchor),
            protectionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            protectionCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            protectionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        // Start browsing button action
        protectionCard.startBrowsingClosure = {
            self.didFinishClosure?(self, nil)
        }
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
