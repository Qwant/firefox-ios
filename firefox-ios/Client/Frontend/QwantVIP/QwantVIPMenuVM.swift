// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Shared

class QwantVIPMenuVM {
    // MARK: - Variables
    var tab: Tab
    var tabManager: TabManager
    var profile: Profile
    var theme: Theme
    var stats: QwantVIPGlobalStats
    let mailHelper: MailHelper

    var shieldImage: UIImage {
        if globalETPIsEnabled {
            let enabledImage = UIImage(imageLiteralResourceName: "image_shield")
            let safelistedImage = UIImage(imageLiteralResourceName: "image_shield_safelisted")
            return isSiteETPEnabled ? enabledImage : safelistedImage
        }
        return UIImage(imageLiteralResourceName: "image_shield_deactivated")
    }

    var protectionTitleString: String {
        if globalETPIsEnabled {
            return isSiteETPEnabled ? .QwantVIP.BlockedItems : .QwantVIP.Inactive
        }
        return .QwantVIP.LocalProtectionDisabledTitle
    }

    var reactivateProtectionTitleString: String {
        return .QwantVIP.ReactivateProtection
    }

    var websiteTitle: String {
        return String(format: .QwantVIP.OnDomain, tab.url?.baseDomain ?? "")
    }

    var informationTitle: String {
        return .QwantVIP.Information
    }

    var mailTitle: String {
        return .QwantVIP.Feedback
    }

    var protectionStatusString: String {
        if isSiteETPEnabling {
            return isSiteETPEnabled ?
                .QwantVIP.LocalProtectionEnablingTitle : .QwantVIP.LocalProtectionDisablingTitle
        }
        return isSiteETPEnabled ?
            .QwantVIP.LocalProtectionEnabledTitle : .QwantVIP.LocalProtectionDisabledTitle
    }

    var isLoadingForMoreThan5Seconds = false

    var protectionStatusDetailString: String {
        if isSiteETPEnabling {
            return isLoadingForMoreThan5Seconds ?
                .QwantVIP.LocalProtectionLongerLoadingSubtitle : .QwantVIP.LocalProtectionLoadingSubtitle
        }
        return isSiteETPEnabled ?
            .QwantVIP.LocalProtectionEnabledSubtitle : .QwantVIP.LocalProtectionDisabledSubtitle
    }

    var protectionStatusColor: UIColor {
        let color = isSiteETPEnabled ? UIColor(rgb: 0x2ac3a2) : UIColor(rgb: 0xe22850)
        return isSiteETPEnabling ? color.withAlphaComponent(0.5) : color
    }

    var blockedTrackersTitleString: String {
        return .QwantVIP.BlockedItems
    }

    var trackingProtectionTitleString: String {
        return .QwantVIP.ProtectionLevel
    }

    var trackingProtectionSubtitleString: String {
        return QwantBlockingStrength.currentStrength(from: profile.prefs).settingSubtitle
    }

    var trackingProtectionValueString: String {
        return QwantBlockingStrength.currentStrength(from: profile.prefs).settingTitle
    }

    var blockedTrackersCount: Int {
        return tab.contentBlocker?.stats.total ?? 0
    }

    var statisticsHeaderString: String {
        return .QwantVIP.LastThirtyDays
    }

    var statisticsBlockedTrackersTitleString: String {
        return .QwantVIP.ItemsBlocked
    }

    var statisticsSavedTimeTitleString: String {
        return .QwantVIP.TimeSaved
    }

    var statisticsSeeDetails: String {
        return .QwantVIP.SeeDetails
    }

    var statisticsTrackersBlockedFormattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "

        let number = NSNumber(value: stats.blockedTrackersCount)
        return formatter.string(from: number)!
    }

    var statisticsTimeSavedFormattedString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated

        return formatter.string(from: stats.savedTime)!
    }

    var isSiteETPEnabling = false

    var isSiteETPEnabled: Bool {
        guard let blocker = tab.contentBlocker else { return true }

        switch blocker.status {
        case .noBlockedURLs, .blocking, .disabled: return true
        case .safelisted: return false
        }
    }

    var globalETPIsEnabled: Bool {
        return QwantTabContentBlocker.isTrackingProtectionEnabled(prefs: profile.prefs)
    }

    var connectionSecure: Bool {
        return tab.webView?.hasOnlySecureContent ?? false
    }

    var connectionStatusString: String {
        return connectionSecure ? .QwantVIP.ConnectionSecure : .QwantVIP.ConnectionNotSecure
    }

    var connectionStatusImage: UIImage {
        let imageName = connectionSecure ? "qwant_lock_on" : "qwant_lock_off"
        let color = connectionSecure ? UIColor(rgb: 0x8E8E93) : theme.colors.vip_redIcon
        return UIImage(named: imageName)!
            .withRenderingMode(.alwaysTemplate)
            .tinted(withColor: color)
    }

    // MARK: - Initializers

    init(tab: Tab,
         profile: Profile,
         tabManager: TabManager,
         theme: Theme,
         stats: QwantVIPGlobalStats = QwantVIPGlobalStats()) {
        self.tab = tab
        self.profile = profile
        self.tabManager = tabManager
        self.theme = theme
        self.stats = stats
        let metadata = MailMetadata(
            to: "extensions@qwant.com",
            subject: "[Qwant VIPrivacy] [iOS - \(AppInfo.appVersion)]",
            body: "\(AppName.longName) \(AppInfo.appVersion) (\(AppInfo.buildNumber))")
        self.mailHelper = MailHelper(prefs: profile.prefs,
                                     metadata: metadata)
    }

    // MARK: - Functions
    func getDetailsViewController() -> QwantVIPDetailsVC? {
        let viewModel = QwantVIPDetailsVM(tab: tab)
        return QwantVIPDetailsVC(viewModel: viewModel)
    }

    func getStatsViewController() -> QwantVIPStatsVC? {
        let viewModel = QwantVIPStatsVM(stats: stats, prefs: profile.prefs)
        return QwantVIPStatsVC(viewModel: viewModel)
    }

    func getProtectionSettingsViewController() -> QwantVIPSettingsViewController {
        let contentBlocker = QwantVIPSettingsViewController(prefs: profile.prefs, isShownFromSettings: false)
        contentBlocker.tabManager = tabManager
        return contentBlocker
    }

    func getInformationViewController() -> QwantVIPInformationVC {
        let viewModel = QwantVIPInformationVM()
        return QwantVIPInformationVC(viewModel: viewModel)
    }

    func activateTrackingProtection() {
        profile.prefs.setString(BlockingStrength.basic.rawValue, forKey: ContentBlockingConfig.Prefs.StrengthKey)
        profile.prefs.setBool(true, forKey: ContentBlockingConfig.Prefs.EnabledKey)
        QwantTabContentBlocker.prefsChanged()
    }

    func toggleSiteSafelistStatus(completion: (() -> Void)?) {
        guard let currentURL = tab.url else { return }
        isSiteETPEnabling = true

        var exceedingTime: Date?
        let timer = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: false) { _ in
            self.isLoadingForMoreThan5Seconds = true
            exceedingTime = Date()
            completion?()
        }

        QwantVIP.shared.safelist(enable: tab.contentBlocker?.status != .safelisted, url: currentURL) {
            let exceeding = exceedingTime == nil
            let deadline: Double = exceeding ? 0 : 2 - (Date().timeIntervalSince1970 - exceedingTime!.timeIntervalSince1970)
            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                timer.invalidate()
                self.isSiteETPEnabling = false
                self.isLoadingForMoreThan5Seconds = false
                self.tab.reload()
                completion?()
            }
        }
    }
}
