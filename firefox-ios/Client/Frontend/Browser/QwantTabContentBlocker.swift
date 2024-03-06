// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit
import Shared
import Common

enum QwantBlockingStrength: String, CaseIterable {
    case basic
    case strict
    case deactivated

    var settingTitle: String {
        switch self {
        case .basic: return .QwantVIP.StandardTitle
        case .strict: return .QwantVIP.StrictTitle
        case .deactivated: return .QwantVIP.DisabledTitle
        }
    }

    var settingSubtitle: String {
        switch self {
        case .basic: return .QwantVIP.StandardDescription
        case .strict: return .QwantVIP.StrictDescription
        case .deactivated: return .QwantVIP.DisabledDescription
        }
    }

    static func accessibilityId(for strength: QwantBlockingStrength) -> String {
        switch strength {
        case .basic: return "Settings.TrackingProtectionOption.BlockListBasic"
        case .strict: return "Settings.TrackingProtectionOption.BlockListStrict"
        case .deactivated: return "Settings.TrackingProtectionOption.BlockListDeactivated"
        }
    }

    var toBlockingStrength: BlockingStrength? {
        switch self {
        case .basic: return .basic
        case .strict: return .strict
        case .deactivated: return nil
        }
    }

    static func currentStrength(from prefs: Prefs) -> QwantBlockingStrength {
        let isEnabled = prefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) ?? true
        let currentStrength = prefs.stringForKey(ContentBlockingConfig.Prefs.StrengthKey)
            .flatMap({ QwantBlockingStrength(rawValue: $0) }) ?? .basic
        return isEnabled ? currentStrength : .deactivated
    }
}

/**
 Qwant-specific implementation of tab content blocking.
 */
class QwantTabContentBlocker: QwantVIPTab, TabContentScript {
    class func name() -> String {
        return "TrackingProtectionStats"
    }

    var isUserEnabled: Bool? {
        didSet {
            guard let tab = tab as? Tab else { return }
            setupForTab()
            TabEvent.post(.didChangeContentBlocking, for: tab)
            tab.reload()
        }
    }

    override var isEnabled: Bool {
        if let enabled = isUserEnabled {
            return enabled
        }

        return isEnabledInPref
    }

    var isEnabledInPref: Bool {
        return prefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    var blockingStrengthPref: BlockingStrength {
        return prefs.stringForKey(ContentBlockingConfig.Prefs.StrengthKey).flatMap(BlockingStrength.init) ?? .basic
    }

    override init(tab: ContentBlockerTab, prefs: Prefs) {
        super.init(tab: tab, prefs: prefs)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        let rules = QwantBlocklistFileName.listsForMode(strict: blockingStrengthPref == .strict)
        QwantVIP.shared.setupTrackingProtection(forTab: tab, isEnabled: isEnabled, rules: rules)
    }

    @objc
    override func notifiedTabSetupRequired() {
        setupForTab()
        if let tab = tab as? Tab {
            TabEvent.post(.didChangeContentBlocking, for: tab)
        }
    }

    override func currentlyEnabledLists() -> [QwantBlocklistFileName] {
        return QwantBlocklistFileName.listsForMode(strict: blockingStrengthPref == .strict)
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }

    func noImageMode(enabled: Bool) {
        guard let tab = tab else { return }
        QwantVIP.shared.noImageMode(enabled: enabled, forTab: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension QwantTabContentBlocker {
    static func setTrackingProtection(enabled: Bool, prefs: Prefs) {
        let key = ContentBlockingConfig.Prefs.EnabledKey
        prefs.setBool(enabled, forKey: key)
        QwantVIP.shared.prefsChanged()
    }

    static func isTrackingProtectionEnabled(prefs: Prefs) -> Bool {
        return prefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    static func toggleTrackingProtectionEnabled(prefs: Prefs) {
        let isEnabled = QwantTabContentBlocker.isTrackingProtectionEnabled(prefs: prefs)
        setTrackingProtection(enabled: !isEnabled, prefs: prefs)
    }
}
