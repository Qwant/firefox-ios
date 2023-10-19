// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import PiwikPROSDK

enum QwantTrackingAction: String {
    case icon = "Icon"
    case cta = "CTA"
    case open = "Opening"
}

enum QwantTrackingName: String {
    case browser = "Browser"
    case settings = "Browser deletion settings"
}

enum QwantTrackingEvent: String {
    case app = "App"
    case zap = "Zap"
}

struct QwantTracking {
    static func setup() {
        #if DEBUG
        PiwikTracker.sharedInstance(siteID: "9d3ebf38-ba38-4d72-9847-d412b59ebcd6",
                                    baseURL: URL(string: "https://qwant-prod.piwik.pro")!)
        #else
        PiwikTracker.sharedInstance(siteID: "8904633f-a958-45ca-b540-df5248159519",
                                    baseURL: URL(string: "https://qwant-prod.piwik.pro")!)
        #endif
        PiwikTracker.sharedInstance()?.sendApplicationDownload()
        track(.app, action: .open)
    }

    static func setEnabled(_ value: Bool) {
        PiwikTracker.sharedInstance()?.optOut = !value && !DeviceInfo.isSimulator()
        let tabManager: TabManager = AppContainer.shared.resolve()
        for tab in tabManager.tabs {
            tab.webView?.setQwantCookies(tracking: value)
        }
    }

    static func track(_ event: QwantTrackingEvent,
                      action: QwantTrackingAction,
                      name: QwantTrackingName? = nil) {
        track(event: event, action: action, name: name, value: nil, path: nil)
    }

    private static func track(event: QwantTrackingEvent,
                      action: QwantTrackingAction,
                      name: QwantTrackingName?,
                      value: NSNumber?,
                      path: String?) {
        PiwikTracker.sharedInstance()?.sendEvent(category: event.rawValue,
                                                 action: action.rawValue,
                                                 name: name?.rawValue,
                                                 value: value,
                                                 path: path)
    }
}
