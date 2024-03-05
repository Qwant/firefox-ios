// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared

protocol LaunchCoordinatorDelegate: AnyObject {
    func didFinishLaunch(from coordinator: LaunchCoordinator)
    func reloadIfPossible()
}

// Manages different types of onboarding that gets shown at the launch of the application
class LaunchCoordinator: BaseCoordinator,
                         SurveySurfaceViewControllerDelegate,
                         QRCodeNavigationHandler,
                         ParentCoordinatorDelegate {
    private let profile: Profile
    private let isIphone: Bool
    weak var parentCoordinator: LaunchCoordinatorDelegate?

    init(router: Router,
         profile: Profile = AppContainer.shared.resolve(),
         isIphone: Bool = UIDevice.current.userInterfaceIdiom == .phone) {
        self.profile = profile
        self.isIphone = isIphone
        super.init(router: router)
    }

    func start(with launchType: LaunchType) {
        let isFullScreen = launchType.isFullScreenAvailable(isIphone: isIphone)
        switch launchType {
        case .intro(let manager):
            presentIntroOnboarding(with: manager, isFullScreen: isFullScreen)
        case .update(let viewModel):
            presentUpdateOnboarding(with: viewModel, isFullScreen: isFullScreen)
        case .defaultBrowser:
            presentDefaultBrowserOnboarding(isFullScreen: isFullScreen)
        case .survey(let manager):
            presentSurvey(with: manager)
        }
    }

    // MARK: - Intro
    private func presentIntroOnboarding(with manager: IntroScreenManager,
                                        isFullScreen: Bool) {
        let introViewController = QwantIntroViewController(.full)
        introViewController.didFinishFlow = { [weak self] in
            guard let self = self else { return }
            IntroScreenManager(prefs: self.profile.prefs).didSeeIntroScreen()
            self.profile.prefs.setInt(1, forKey: PrefsKeys.SecondaryIntroSeen)
            self.parentCoordinator?.didFinishLaunch(from: self)
            self.parentCoordinator?.reloadIfPossible()
        }

        if isFullScreen {
            introViewController.modalPresentationStyle = .fullScreen
            router.present(introViewController, animated: false)
        } else {
            introViewController.preferredContentSize = CGSize(
                width: ViewControllerConsts.PreferredSize.IntroViewController.width,
                height: ViewControllerConsts.PreferredSize.IntroViewController.height)
            introViewController.modalPresentationStyle = .formSheet
            introViewController.isModalInPresentation = true
            router.present(introViewController, animated: true)
        }
    }

    // MARK: - Update
    private func presentUpdateOnboarding(with updateViewModel: UpdateViewModel,
                                         isFullScreen: Bool) {
        let updateViewController = UpdateViewController(viewModel: updateViewModel)
        updateViewController.qrCodeNavigationHandler = self
        updateViewController.didFinishFlow = { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.didFinishLaunch(from: self)
        }

        if isFullScreen {
            updateViewController.modalPresentationStyle = .fullScreen
            router.present(updateViewController, animated: false)
        } else {
            updateViewController.preferredContentSize = CGSize(
                width: ViewControllerConsts.PreferredSize.UpdateViewController.width,
                height: ViewControllerConsts.PreferredSize.UpdateViewController.height)
            updateViewController.modalPresentationStyle = .formSheet
            // Nimbus's configuration
            if !updateViewModel.isDismissable {
                updateViewController.isModalInPresentation = true
            }
            router.present(updateViewController)
        }
    }

    // MARK: - Default Browser
    func presentDefaultBrowserOnboarding(isFullScreen: Bool) {
        let defaultOnboardingViewController = QwantDefaultBrowserOnboardingViewController()
        defaultOnboardingViewController.goToSettings = { [weak self] in
            guard let self = self else { return }
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
            self.parentCoordinator?.didFinishLaunch(from: self)
            self.parentCoordinator?.reloadIfPossible()
        }

        if isFullScreen {
            defaultOnboardingViewController.modalPresentationStyle = .popover
            router.present(defaultOnboardingViewController, animated: false)
        } else {
            defaultOnboardingViewController.preferredContentSize = CGSize(
                width: ViewControllerConsts.PreferredSize.DBOnboardingViewController.width,
                height: ViewControllerConsts.PreferredSize.DBOnboardingViewController.height)
            defaultOnboardingViewController.modalPresentationStyle = .formSheet
            router.present(defaultOnboardingViewController, animated: true)
        }
    }

    // MARK: - Survey
    func presentSurvey(with manager: SurveySurfaceManager) {
        guard let surveySurface = manager.getSurveySurface() else {
            logger.log("Tried presenting survey but no surface was found", level: .warning, category: .lifecycle)
            parentCoordinator?.didFinishLaunch(from: self)
            return
        }
        surveySurface.modalPresentationStyle = .fullScreen
        surveySurface.delegate = self
        router.present(surveySurface, animated: false)
    }

    // MARK: - QRCodeNavigationHandler

    func showQRCode(delegate: QRCodeViewControllerDelegate, rootNavigationController: UINavigationController?) {
        var coordinator: QRCodeCoordinator
        if let qrCodeCoordinator = childCoordinators.first(where: { $0 is QRCodeCoordinator }) as? QRCodeCoordinator {
            coordinator = qrCodeCoordinator
        } else {
            if rootNavigationController != nil {
                coordinator = QRCodeCoordinator(
                    parentCoordinator: self,
                    router: DefaultRouter(navigationController: rootNavigationController!)
                )
            } else {
                coordinator = QRCodeCoordinator(
                    parentCoordinator: self,
                    router: router
                )
            }
            add(child: coordinator)
        }
        coordinator.showQRCode(delegate: delegate)
    }

    // MARK: - ParentCoordinatorDelegate

    func didFinish(from childCoordinator: Coordinator) {
        remove(child: childCoordinator)
    }

    // MARK: - SurveySurfaceViewControllerDelegate
    func didFinish() {
        parentCoordinator?.didFinishLaunch(from: self)
    }
}
