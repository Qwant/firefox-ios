// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

// Accessors for homepage details from the app state.
// These are pure functions, so it's quite ok to have them
// as static.

// This HomePagePref is only used when setting the HomePage on the newTab
// and not setting a custom URL for the Home button.
class NewTabHomePageAccessors: QwantHomePageAccessors {
    static func getHomePage(_ prefs: Prefs) -> URL? {
        let string = prefs.stringForKey(PrefsKeys.NewTabCustomUrlPrefKey) ?? getDefaultHomePageString(prefs)
        guard let urlString = string else { return nil }
        return URL(string: urlString, invalidCharacters: false)
    }
}

class HomeButtonHomePageAccessors: QwantHomePageAccessors {
    static func getHomePage(_ prefs: Prefs) -> URL? {
        let string = prefs.stringForKey(PrefsKeys.HomeButtonHomePageURL) ?? getDefaultHomePageString(prefs)
        guard let urlString = string else { return nil }
        return URL(string: urlString, invalidCharacters: false)
    }
}

class QwantHomePageAccessors {
    static let QwantHome = "https://www.qwant.com/"

    static func getDefaultHomePageString(_ prefs: Prefs) -> String? {
        return prefs.stringForKey(PrefsKeys.KeyDefaultHomePageURL) ?? makeQwantTheHomePageAndSetItAsDefault(prefs)
    }

    static func makeQwantTheHomePageAndSetItAsDefault(_ prefs: Prefs) -> String? {
        prefs.setString(QwantHome, forKey: PrefsKeys.KeyDefaultHomePageURL)
        return QwantHome
    }
}
