// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Shared

class QwantTPMenuVM {
    
    // MARK: - Variables
    var tab: Tab
    var tabManager: TabManager
    var profile: Profile
    var stats: QwantContentBlockerStats
    
    var websiteTitle: String {
        return tab.url?.baseDomain ?? ""
    }
    
    var protectionStatusString: String {
        if isSiteETPEnabling {
            return isSiteETPEnabled ? .QwantTrackingProtection.LocalProtectionEnablingTitle : .QwantTrackingProtection.LocalProtectionDisablingTitle
        }
        return isSiteETPEnabled ? .QwantTrackingProtection.LocalProtectionEnabledTitle : .QwantTrackingProtection.LocalProtectionDisabledTitle
    }
    
    var isLoadingForMoreThan5Seconds = false
    
    var protectionStatusDetailString: String {
        if isSiteETPEnabling {
            return isLoadingForMoreThan5Seconds ? .QwantTrackingProtection.LocalProtectionLongerLoadingSubtitle : .QwantTrackingProtection.LocalProtectionLoadingSubtitle
        }
        return isSiteETPEnabled ? .QwantTrackingProtection.LocalProtectionEnabledSubtitle : .QwantTrackingProtection.LocalProtectionDisabledSubtitle
    }
    
    var protectionStatusColor: UIColor {
        let color = isSiteETPEnabled ? UIColor.Qwant.Theme.Green60 : UIColor.Qwant.Theme.Red60
        return isSiteETPEnabling ? color.withAlphaComponent(0.5) : color
    }
    
    var blockedTrackersTitleString: String {
        return .QwantTrackingProtection.BlockedItems
    }
    
    var trackingProtectionTitleString: String {
        return .QwantTrackingProtection.ProtectionLevel
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
        return .QwantTrackingProtection.LastThirtyDays
    }
    
    var statisticsBlockedTrackersTitleString: String {
        return .QwantTrackingProtection.ItemsBlocked
    }
    
    var statisticsSavedTimeTitleString: String {
        return .QwantTrackingProtection.TimeSaved
    }
    
    var statisticsSeeDetails: String {
        return .QwantTrackingProtection.SeeDetails
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
        formatter.unitsStyle = .full
        
        return formatter.string(from: stats.savedTime)!
    }
    
    var isSiteETPEnabling: Bool = false
    
    var isSiteETPEnabled: Bool {
        guard let blocker = tab.contentBlocker else { return true }
        
        switch blocker.status {
            case .noBlockedURLs, .blocking, .disabled: return true
            case .safelisted: return false
        }
    }
    
    var globalETPIsEnabled: Bool {
        return QwantSpecificTabContentBlocker.isTrackingProtectionEnabled(prefs: profile.prefs)
    }
    
    var connectionSecure: Bool {
        return tab.webView?.hasOnlySecureContent ?? false
    }
    
    var connectionStatusString: String {
        return connectionSecure ? .QwantTrackingProtection.ConnectionSecure : .QwantTrackingProtection.ConnectionNotSecure
    }
    
    var connectionStatusImage: UIImage {
//        let insecureImageString = LegacyThemeManager.instance.currentName == .dark ? "lock_blocked_dark" : "lock_blocked"
//        let image = connectionSecure ? UIImage(imageLiteralResourceName: "lock_verified").withRenderingMode(.alwaysTemplate) : UIImage(imageLiteralResourceName: insecureImageString)
        if connectionSecure {
            return UIImage(imageLiteralResourceName: StandardImageIdentifiers.Large.lock).withRenderingMode(.alwaysTemplate)
        } else {
            return UIImage(imageLiteralResourceName: StandardImageIdentifiers.Large.lockSlash)
        }
//        return image
    }
    
    // MARK: - Initializers
    
    init(tab: Tab, profile: Profile, tabManager: TabManager, stats: QwantContentBlockerStats = QwantContentBlockerStats()) {
        self.tab = tab
        self.profile = profile
        self.tabManager = tabManager
        self.stats = stats
    }
    
    // MARK: - Functions
    func getDetailsViewController() -> QwantTPDetailsVC? {
        guard blockedTrackersCount > 0 else { return nil }
        let viewModel = QwantTPDetailsVM(tab: tab)
        return QwantTPDetailsVC(viewModel: viewModel)
    }
    
    func getStatsViewController() -> QwantTPStatsVC? {
        guard stats.blockedTrackersCount > 0 else { return nil }
        let viewModel = QwantTPStatsVM(stats: stats)
        return QwantTPStatsVC(viewModel: viewModel)
    }
    
    func getProtectionSettingsViewController() -> QwantContentBlockerSettingViewController {
        let contentBlocker = QwantContentBlockerSettingViewController(prefs: profile.prefs, isShownFromSettings: false)
        contentBlocker.tabManager = tabManager
        return contentBlocker
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
        
        QwantContentBlocker.shared.safelist(enable: tab.contentBlocker?.status != .safelisted, url: currentURL) {
            let deadline: Double = exceedingTime == nil ? 0 : 2 - (Date().timeIntervalSince1970 - exceedingTime!.timeIntervalSince1970)
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
