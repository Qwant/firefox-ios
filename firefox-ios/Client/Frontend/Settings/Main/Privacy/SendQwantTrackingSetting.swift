// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared

class SendQwantTrackingSetting: BoolSetting {
    private weak var settingsDelegate: SupportSettingsDelegate?
    var tabManager: TabManager!

    init(settings: SettingsTableViewController,
         delegate: SettingsDelegate?,
         theme: Theme,
         settingsDelegate: SupportSettingsDelegate?,
         qwantTracking: QwantTracking) {
        self.settingsDelegate = settingsDelegate
        super.init(
            prefs: settings.profile.prefs,
            prefKey: AppConstants.prefQwantTracking,
            defaultValue: true,
            attributedTitleText: NSAttributedString(string: .QwantTracking.SettingsTitle),
            attributedStatusText: NSAttributedString(string: .QwantTracking.SettingsSubtitle),
            settingDidChange: {
                qwantTracking.setEnabled($0)
                guard settings.tabManager != nil else { return }
                for tab in settings.tabManager.tabs {
                    tab.webView?.setQwantCookies(tracking: $0)
                }
            }
        )
    }
}
