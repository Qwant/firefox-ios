// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit

extension QwantTabContentBlocker {
    func clearPageStats() {
        stats = QwantTPPageStats()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard isEnabled,
              let body = message.body as? [String: Any],
              let urls = body["urls"] as? [String],
              let mainDocumentUrl = tab?.currentURL()
        else {
            return
        }
        
        // Reset the pageStats to make sure the trackingprotection shield icon knows that a page was safelisted
        guard !QwantContentBlocker.shared.isSafelisted(url: mainDocumentUrl) else {
            clearPageStats()
            return
        }
        
        // The JS sends the urls in batches for better performance. Iterate the batch and check the urls.
        for urlString in urls {
            guard var components = URLComponents(string: urlString) else { return }
            components.scheme = "http"
            guard let url = components.url else { return }
            
            print("Detected activity for host \(url.host ?? "unknown")")
            
            QwantTPStatsBlocklistChecker.shared.isBlocked(url: url, mainDocumentURL: mainDocumentUrl).uponQueue(.main) { blocked in
                if let domain = url.baseDomain, blocked == true {
                    self.stats = self.stats.create(host: domain)
                    print("Blocked host \(domain)")
                    NotificationCenter.default.post(name: .ContentBlockerDidBlock, object: nil)
                }
            }
        }
    }
}
