// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

private let TogglesPrefKey = "zap.clearables.toggles"

class QwantZap {
    var profile: Profile
    var tabManager: TabManager

    init(profile: Profile, tabManager: TabManager) {
        self.profile = profile
        self.tabManager = tabManager
    }

    var clearables: [(clearable: Clearable, defaultValue: Bool)] {
        return [
            (AllTabsAndThenHistoryClearable(profile: profile, tabManager: tabManager), true),
            (CacheClearable(), true),
            (CookiesClearable(), true),
            (SiteDataClearable(), true),
            (TrackingProtectionClearable(), true),
            (DownloadedFilesClearable(), true)
        ]
    }

    var toggles: [Bool] {
        get {
            if let savedToggles = self.profile.prefs.arrayForKey(TogglesPrefKey) as? [Bool],
                savedToggles.count == self.clearables.count {
                return savedToggles
            }
            return self.clearables.map { $0.defaultValue }
        }

        set {
            self.profile.prefs.setObject(newValue, forKey: TogglesPrefKey)
        }
    }

    var enabledClearables: [Clearable] {
        guard toggles.count == clearables.count else {
            fatalError("Arrays must have the same size.")
        }
        return zip(toggles, clearables).compactMap { $0 ? $1 : nil }.map { $0.clearable }
    }

    func zap(completion: @escaping (() -> Void)) {
        enabledClearables
            .map { $0.clear() }
            .allSucceed()
            .uponQueue(.main) { _ in
                completion()
            }
    }
}
