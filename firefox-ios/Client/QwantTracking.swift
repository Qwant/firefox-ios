// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared
import Common
import PiwikPROSDK

class QwantTracking {
    var prefs: Prefs
    private var timer: DispatchSourceTimer?

    init(prefs: Prefs) {
        self.prefs = prefs
    }

    func setup() {
#if targetEnvironment(simulator)
        PiwikTracker.sharedInstance(siteID: "9d3ebf38-ba38-4d72-9847-d412b59ebcd6",
                                    baseURL: URL(string: "https://k.qwant.com")!)
#else
        PiwikTracker.sharedInstance(siteID: "8904633f-a958-45ca-b540-df5248159519",
                                    baseURL: URL(string: "https://k.qwant.com")!)
#endif
        PiwikTracker.sharedInstance()?.applicationInstall()
        PiwikTracker.sharedInstance()?.isPrefixingEnabled = false
        PiwikTracker.sharedInstance()?.isAnonymizationEnabled = false
        PiwikTracker.sharedInstance()?.visitorIDLifetime = ((365.25 / 12) * 13) * (24 * 60 * 60.0)
        let consent = prefs.boolForKey(AppConstants.prefQwantTracking) ?? true
        PiwikTracker.sharedInstance()?.optOut = !consent
        track(.app_open)
    }

    func setEnabled(_ value: Bool) {
        track(.tracking(isOn: value))
        PiwikTracker.sharedInstance()?.optOut = !value
        PiwikTracker.sharedInstance()?.dispatch()
    }

    func track(_ screenView: QwantTrackingScreenView) {
        scheduleScreenViewEvent(screenView)
    }

    func track(_ event: QwantTrackingEvent) {
        guard event.canSend() else { return }
        let event = event.rawValue

        print("[QWANT TRACKING] \([event.category.rawValue, event.action.rawValue, event.name?.rawValue].compactMap { $0 }.joined(separator: " - "))")
        PiwikTracker.sharedInstance()?.sendEvent(category: event.category.rawValue,
                                                 action: event.action.rawValue,
                                                 name: event.name?.rawValue,
                                                 value: nil,
                                                 path: nil)
    }

    private func scheduleScreenViewEvent(_ screenView: QwantTrackingScreenView) {
        timer?.cancel()
        let newTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        newTimer.schedule(deadline: .now() + 1)
        newTimer.setEventHandler { [weak self] in
            self?.sendScreenView(screenView)
        }
        newTimer.resume()
        timer = newTimer
    }

    private func sendScreenView(_ screenView: QwantTrackingScreenView) {
        print("[QWANT TRACKING] \(screenView.fullname)")
        PiwikTracker.sharedInstance()?.sendView(view: screenView.fullname)
    }
}

struct QwantTrackingScreenView {
    var name: String

    var fullname: String {
        return [name, "navigation"].joined(separator: " ")
    }
}

private typealias Event = (category: Category, action: Action, name: Name?)
enum QwantTrackingEvent {
    case zap_toolbar(isIntention: Bool)
    case zap_settings(isIntention: Bool)

    case app_open

    case tracking(isOn: Bool)

    case closeTab(isPrivate: Bool)
    case closeAllTabs(isIntention: Bool, isPrivate: Bool)

    case tap_tabTray
    case tap_settings

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
            return (.tab, .tap, .closeOne(isPrivate: isPrivate))
        case .closeAllTabs(let isIntention, let isPrivate):
            return (.tab, .action(isIntention: isIntention), .closeAll(isPrivate: isPrivate))
        case .tap_tabTray:
            return (.tab, .tap, .openTray)
        case .tap_settings:
            return (.settings, .tap, .toolbar)
        }
    }

    func canSend() -> Bool {
        switch self {
        default: return true
        }
    }
}

private enum Category {
    case zap
    case app
    case tracking
    case tab
    case settings

    var rawValue: String {
        switch self {
        case .zap: return "Zap"
        case .app: return "App"
        case .tracking: return "Tracking"
        case .tab: return "Tab"
        case .settings: return "Settings"
        }
    }
}

private enum Action {
    case action(isIntention: Bool)
    case open
    case toggle(isOn: Bool)
    case tap

    var rawValue: String {
        switch self {
        case .action(let isIntention): return isIntention ? "Intention" : "Confirmation"
        case .open: return "Open"
        case .toggle(let isOn): return isOn ? "On" : "Off"
        case .tap: return "Tap"
        }
    }
}

private enum Name {
    case toolbar
    case settings
    case closeAll(isPrivate: Bool)
    case closeOne(isPrivate: Bool)
    case openTray

    var rawValue: String {
        switch self {
        case .toolbar: return "Toolbar"
        case .settings: return "Settings"
        case .closeAll(let isPrivate): return "Close all - \(isPrivate ? "Private" : "Normal")"
        case .closeOne(let isPrivate): return "Close one - \(isPrivate ? "Private" : "Normal")"
        case .openTray: return "Open tray"
        }
    }
}
