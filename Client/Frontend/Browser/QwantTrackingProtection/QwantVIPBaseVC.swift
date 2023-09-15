// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Common

protocol QwantVIPBase: Themeable, Notifiable {
    func setupView()
    func setupConstraints()
    func updateViewDetails()
}

class QwantVIPBaseVC: UIViewController, QwantVIPBase {
    var themeManager: ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: NotificationProtocol
    weak var enhancedTrackingProtectionMenuDelegate: EnhancedTrackingProtectionMenuDelegate?
    
    internal lazy var closeButton = {
        return UIBarButtonItem(barButtonSystemItem: .close) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }()
    
    internal var constraints = [NSLayoutConstraint]()

    // MARK: - View lifecycle
    
    init(themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        listenForThemeChange(view)
        setupNotifications(forObserver: self, observing: [.ContentBlockerDidBlock])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewDetails()
        applyTheme()
    }
    
    func setupView() {
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        
        setupConstraints()
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupConstraints() {
        // Empty implementation
    }
    
    func updateViewDetails() {
        self.navigationItem.setRightBarButton(closeButton, animated: false)
    }
    
    func handleNotifications(_ notification: Notification) {
        switch notification.name {
            case .ContentBlockerDidBlock:
                updateViewDetails()
            default: break
        }
    }

    func applyTheme() {
        let theme = themeManager.currentTheme
        overrideUserInterfaceStyle = theme.type.getInterfaceStyle()
        view.backgroundColor = theme.colors.vip_background
        setNeedsStatusBarAppearanceUpdate()
    }
}
