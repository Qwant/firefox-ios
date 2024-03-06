// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit
import Shared

extension QwantVIPTab {
    func clearPageStats() {
        stats = QwantVIPPageStats()
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage
    ) {
        guard isEnabled,
              let body = message.body as? [String: Any],
              let urls = body["urls"] as? [String],
              let mainDocumentUrl = tab?.currentURL()
        else {
            return
        }

        // Reset the pageStats to make sure the trackingprotection shield icon knows that a page was safelisted
        guard !QwantVIP.shared.isSafelisted(url: mainDocumentUrl) else {
            clearPageStats()
            return
        }

        // The JS sends the urls in batches for better performance. Iterate the batch and check the urls.
        for urlString in urls {
            guard var components = URLComponents(string: urlString) else { return }
            components.scheme = "http"
            guard let url = components.url else { return }

            print("[QWANT VIP] Detected activity at \(url.host ?? "unknown")")

            QwantVIPStatsBlocklistChecker.shared.isBlocked(url: url, mainDocumentURL: mainDocumentUrl) { blocked in
                DispatchQueue.main.async {
                    guard blocked == true, let domain = url.baseDomain else { return }

                    let canRecordStat = !(self.prefs.boolForKey(PrefsKeys.QwantVIPStatisticsDeactivated) ?? false)
                    self.stats = self.stats.create(host: domain, recordStat: canRecordStat)
                    print("[QWANT VIP] Blocked activity at \(domain)")
                    NotificationCenter.default.post(name: .ContentBlockerDidBlock, object: nil)
                }
            }
        }
    }
}
