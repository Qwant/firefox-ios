// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import WebKit
import Shared

protocol EnhancedTrackingProtectionCoordinatorDelegate: AnyObject {
    func didFinishEnhancedTrackingProtection(from coordinator: EnhancedTrackingProtectionCoordinator)
    func settingsOpenPage(settings: Route.SettingsSection)
}

class EnhancedTrackingProtectionCoordinator: BaseCoordinator,
                                             EnhancedTrackingProtectionMenuDelegate {
    private let profile: Profile
    private let tabManager: TabManager
    private let themeManager: ThemeManager
    private let enhancedTrackingProtectionMenuVC: ThemedNavigationController
    weak var parentCoordinator: EnhancedTrackingProtectionCoordinatorDelegate?

    init(router: Router,
         profile: Profile = AppContainer.shared.resolve(),
         tabManager: TabManager,
         themeManager: ThemeManager = AppContainer.shared.resolve()
    ) {
        let tab = tabManager.selectedTab
        let etpViewModel = QwantVIPMenuVM(
            tab: tab ?? Tab(profile: profile, configuration: WKWebViewConfiguration()),
            profile: profile,
            tabManager: tabManager,
            theme: themeManager.currentTheme)
        let controller = QwantVIPMenuVC(viewModel: etpViewModel)
        etpViewModel.mailHelper.mailComposeDelegate = controller

        self.enhancedTrackingProtectionMenuVC = ThemedNavigationController(rootViewController: controller)
        self.profile = profile
        self.tabManager = tabManager
        self.themeManager = themeManager
        super.init(router: router)

        controller.enhancedTrackingProtectionMenuDelegate = self
    }

    func start(sourceView: UIView) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            enhancedTrackingProtectionMenuVC.modalPresentationStyle = .pageSheet
            enhancedTrackingProtectionMenuVC.transitioningDelegate = self
        } else {
            (enhancedTrackingProtectionMenuVC.viewControllers.first as? QwantVIPMenuVC)?.asPopover = true
            enhancedTrackingProtectionMenuVC.modalPresentationStyle = .popover
            enhancedTrackingProtectionMenuVC.popoverPresentationController?.sourceView = sourceView
            enhancedTrackingProtectionMenuVC.popoverPresentationController?.permittedArrowDirections = .up
        }
        router.present(enhancedTrackingProtectionMenuVC, animated: true, completion: nil)
    }

    // MARK: - EnhancedTrackingProtectionMenuDelegate
    func settingsOpenPage(settings: Route.SettingsSection) {
        parentCoordinator?.didFinishEnhancedTrackingProtection(from: self)
        parentCoordinator?.settingsOpenPage(settings: settings)
    }

    func didFinish() {
        parentCoordinator?.didFinishEnhancedTrackingProtection(from: self)
    }
}

extension EnhancedTrackingProtectionCoordinator: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let globalETPStatus = FirefoxTabContentBlocker.isTrackingProtectionEnabled(prefs: profile.prefs)
        let slideOverPresentationController = SlideOverPresentationController(presentedViewController: presented,
                                                                              presenting: presenting,
                                                                              withGlobalETPStatus: globalETPStatus)
        slideOverPresentationController.enhancedTrackingProtectionMenuDelegate = self

        return slideOverPresentationController
    }
}
