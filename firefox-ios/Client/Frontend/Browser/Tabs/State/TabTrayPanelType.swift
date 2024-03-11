// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import Shared

enum TabTrayPanelType: Int, CaseIterable {
    case tabs
    case privateTabs
    case syncedTabs

    var navTitle: String {
        switch self {
        case .tabs:
            return .TabTrayV2Title
        case .privateTabs:
            return .TabTrayPrivateBrowsingTitle
        case .syncedTabs:
            return .LegacyAppMenu.AppMenuSyncedTabsTitleString
        }
    }

    func buttonsColor(for theme: Theme) -> UIColor {
        switch self {
        case .tabs, .syncedTabs:
            return theme.colors.omnibar_blue
        case .privateTabs:
            return theme.colors.omnibar_purple
        }
    }

    var label: String {
        switch self {
        case .tabs:
            return String.TabTraySegmentedControlTitlesTabs
        case .privateTabs:
            return String.TabTraySegmentedControlTitlesPrivateTabs
        case .syncedTabs:
            return String.Settings.Notifications.SyncNotificationsTitle
        }
    }

    var image: UIImage? {
        switch self {
        case .tabs:
            return UIImage(named: StandardImageIdentifiers.Large.tab)
        case .privateTabs:
            return UIImage(named: "qwant_private")?.createScaled(CGSize(width: 24, height: 24))
        case .syncedTabs:
            return UIImage(named: StandardImageIdentifiers.Large.syncTabs)
        }
    }

    var modeForTelemetry: TabsPanelTelemetry.Mode {
        switch self {
        case .tabs:
            return .normal
        case .privateTabs:
            return .private
        case .syncedTabs:
            return .sync
        }
    }

    static func getExperimentConvert(index: Int) -> TabTrayPanelType {
        var panelType: TabTrayPanelType = .tabs
        switch index {
        case 0: panelType = .privateTabs
        case 1: panelType = .tabs
        case 2: panelType = .syncedTabs
        default: break
        }
        return panelType
    }
}
