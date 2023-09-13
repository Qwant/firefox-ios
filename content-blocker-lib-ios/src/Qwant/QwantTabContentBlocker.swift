// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit

class QwantTabContentBlocker {
    weak var tab: ContentBlockerTab?
    
    var statsForPage = [URL: QwantTPPageStats]()

    var isEnabled: Bool {
        return false
    }

    @objc func notifiedTabSetupRequired() {}

    func currentlyEnabledLists() -> [QwantBlocklistFileName] {
        return []
    }

    func notifyContentBlockingChanged() {}

    var status: BlockerStatus {
        guard isEnabled else {
            return .disabled
        }
        guard let url = tab?.currentURL() else {
            return .noBlockedURLs
        }

        if QwantContentBlocker.shared.isSafelisted(url: url) {
            return .safelisted
        }
        if stats.total == 0 {
            return .noBlockedURLs
        } else {
            return .blocking
        }
    }

    var stats: QwantTPPageStats = QwantTPPageStats() {
        didSet {
            guard let tab = self.tab else { return }
            if let url = tab.currentURL(), stats.total > 0 {
                statsForPage[url] = stats
            }
            if stats.total <= 1 {
                notifyContentBlockingChanged()
            }
        }
    }

    init(tab: ContentBlockerTab) {
        self.tab = tab
        NotificationCenter.default.addObserver(self, selector: #selector(notifiedTabSetupRequired), name: .contentBlockerTabSetupRequired, object: nil)
    }
    
    func scriptMessageHandlerName() -> String? {
        return "trackingProtectionStats"
    }

    class func prefsChanged() {
        // This class func needs to notify all the active instances of ContentBlocker to update.
        NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func restoreStats(for page: URL) {
        if let stats = statsForPage[page] {
            self.stats = stats
        }
    }
}
