// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import PiwikPROSDK

private typealias Event = (category: Category, action: Action, name: Name?)

enum QwantTrackingEvent {
    case zap_toolbar(isIntention: Bool)
    case zap_settings(isIntention: Bool)

    case app_open

    case tracking(isOn: Bool)

    case closeTab(isPrivate: Bool)
    case closeAllTabs(isIntention: Bool, isPrivate: Bool)

    fileprivate var rawValue: Event {
        switch self {
            case .zap_toolbar(let isIntention):
                return (.zap, .action(isIntention: isIntention), .toolbar)
            case .zap_settings(let isIntention):
                return (.zap, .action(isIntention: isIntention), .settings)
            case .app_open: 
                return (.app, .open, nil)
            case .tracking(let isOn):
                return (.tracking, .toggle(isOn: isOn), nil)
            case .closeTab(let isPrivate): 
                return (.tab, .action(isIntention: false), .closeOne(isPrivate: isPrivate))
            case .closeAllTabs(let isIntention, let isPrivate):
                return (.tab, .action(isIntention: isIntention), .closeAll(isPrivate: isPrivate))
        }
    }

    func canSend() -> Bool {
        switch self {
            case .closeTab(let isPrivate): return isPrivate
            case .closeAllTabs(let _, let isPrivate): return isPrivate
            default: return true
        }
    }
}

private enum Category {
    case zap
    case app
    case tracking
    case tab

    var rawValue: String {
        switch self {
            case .zap: return "Zap"
            case .app: return "App"
            case .tracking: return "Tracking"
            case .tab: return "Tab"
        }
    }
}

private enum Action {
    case action(isIntention: Bool)
    case open
    case toggle(isOn: Bool)

    var rawValue: String {
        switch self {
            case .action(let isIntention): return isIntention ? "Intention" : "Confirmation"
            case .toggle(let isOn): return isOn ? "On" : "Off"
            case .open: return "Open"
        }
    }
}

private enum Name {
    case toolbar
    case settings
    case closeAll(isPrivate: Bool)
    case closeOne(isPrivate: Bool)

    var rawValue: String {
        switch self {
            case .toolbar: return "Toolbar"
            case .settings: return "Settings"
            case .closeAll(let isPrivate): return "Close all - \(isPrivate ? "Private" : "Standard")"
            case .closeOne(let isPrivate): return "Close one - \(isPrivate ? "Private" : "Standard")"
        }
    }
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
        track(.app_open)
    }

    static func setEnabled(_ value: Bool) {
        track(.tracking(isOn: value))
        PiwikTracker.sharedInstance()?.dispatch()
        PiwikTracker.sharedInstance()?.optOut = !value && !DeviceInfo.isSimulator()
        let tabManager: TabManager = AppContainer.shared.resolve()
        for tab in tabManager.tabs {
            tab.webView?.setQwantCookies(tracking: value)
        }
    }

    static func track(_ event: QwantTrackingEvent) {
        guard event.canSend() else { return }
        let event = event.rawValue
        print("[QWANT] Tracking \([event.category.rawValue, event.action.rawValue, event.name?.rawValue].compactMap { $0 }.joined(separator: " - "))")
        PiwikTracker.sharedInstance()?.sendEvent(category: event.category.rawValue,
                                                 action: event.action.rawValue,
                                                 name: event.name?.rawValue,
                                                 value: nil,
                                                 path: nil)
    }
}
