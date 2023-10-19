// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared

class SendQwantTrackingSetting: BoolSetting {
    private weak var settingsDelegate: SupportSettingsDelegate?

    init(prefs: Prefs,
         delegate: SettingsDelegate?,
         theme: Theme,
         settingsDelegate: SupportSettingsDelegate?) {

        self.settingsDelegate = settingsDelegate
        super.init(
            prefs: prefs,
            prefKey: AppConstants.prefQwantTracking,
            defaultValue: true,
            attributedTitleText: NSAttributedString(string: .QwantTracking.SettingsTitle),
            attributedStatusText: NSAttributedString(string: .QwantTracking.SettingsSubtitle),
            settingDidChange: {
                QwantTracking.setEnabled($0)
            }
        )
    }
}
