// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit

struct SafelistedDomains {
    var domainSet = Set<String>() {
        didSet {
            domainRegex = domainSet.compactMap { wildcardContentBlockerDomainToRegex(domain: "*" + $0) }
        }
    }

    private(set) var domainRegex = [String]()
}

extension ContentBlocker {
    private func safelistFileURL() -> URL? {
        guard let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return dir.appendingPathComponent("safelist")
    }

    private func oldSafelistFileURL() -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return dir.appendingPathComponent("safelist")
    }

    // Get the safelist domain array as a JSON fragment that can be inserted at the end of a blocklist.
    func safelistAsJSON() -> String {
        if safelistedDomains.domainSet.isEmpty {
            return qwantSafelist
        }
        // Note that * is added to the front of domains, so foo.com becomes *foo.com
        let list = "\"*" + safelistedDomains.domainSet.joined(separator: "\",\"*") + "\""

        let script =
        """
        , {"action": { "type": "ignore-previous-rules" }, "trigger": { "url-filter": ".*", "if-domain": [\(list)] }}
        """
        return qwantSafelist + script
    }

    func safelist(enable: Bool, url: URL, completion: (() -> Void)?) {
        guard let domain = safelistableDomain(fromUrl: url) else { return }

        if enable {
            safelistedDomains.domainSet.insert(domain)
        } else {
            safelistedDomains.domainSet.remove(domain)
        }

        updateSafelist(completion: completion)
    }

    func clearSafelist(completion: (() -> Void)?) {
        safelistedDomains.domainSet = Set<String>()
        updateSafelist(completion: completion)
    }

    private func updateSafelist(completion: (() -> Void)?) {
        removeAllRulesInStore {
            self.compileListsNotInStore {
                completion?()
                NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
            }
        }

        guard let fileURL = safelistFileURL() else { return }
        if safelistedDomains.domainSet.isEmpty {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }

        let list = safelistedDomains.domainSet.joined(separator: "\n")
        do {
            try list.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {}
    }
    // Ensure domains used for safelisting are standardized by using this function.
    func safelistableDomain(fromUrl url: URL) -> String? {
        guard let domain = url.host, !domain.isEmpty else { return nil }
        return domain
    }

    func isSafelisted(url: URL) -> Bool {
        guard let domain = safelistableDomain(fromUrl: url) else {
            return false
        }
        return safelistedDomains.domainSet.contains(domain)
    }

    func readSafelistFile() -> [String]? {
        guard let fileURL = safelistFileURL() else { return nil }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            return readSafelistFile(fileURL: fileURL)

            // read file data, then move to new location
        } else if let oldFileURL = oldSafelistFileURL(),
                  FileManager.default.fileExists(atPath: oldFileURL.path) {
            let data = readSafelistFile(fileURL: oldFileURL)
            do {
                try FileManager.default.moveItem(at: oldFileURL, to: fileURL)
            } catch {
                logger.log(
                    "Failed to move file from \(oldFileURL) to \(fileURL) for safe list file with error: \(error)",
                    level: .warning,
                    category: .webview
                )
            }
            return data
        }
        return nil
    }

    private func readSafelistFile(fileURL: URL) -> [String]? {
        let text = try? String(contentsOf: fileURL, encoding: .utf8)
        if let text = text, !text.isEmpty {
            return text.components(separatedBy: .newlines)
        }
        return nil
    }

    private var qwantSafelist: String {
        return
#"""
,{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.com\\\/impression\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.app\\\/impression\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.com\\\/action\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.app\\\/action\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.com\\\/apm\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.app\\\/apm\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?api\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?api\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?about\\.qwant\\.com\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?about\\.qwant\\.app\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.com([\\\/:&\\?].*)?$","if-domain":["*about.qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.app([\\\/:&\\?].*)?$","if-domain":["*about.qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.ninja"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.plive"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?api\\.qwant\\.com\\\/v2\\\/api\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?api\\.qwant\\.app\\\/v2\\\/api\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.com\\\/maps\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwant\\.app\\\/maps\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?alpha\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?alpha\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?stats\\.qwant\\.com\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?stats\\.qwant\\.app\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?p\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?p\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?k\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?k\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?f\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?f\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?apm\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?apm\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?mn\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?mn\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?qwantjunior\\.com\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?datadome\\.co\\\/"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?fdn\\.qwant\\.com"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?fdn\\.qwant\\.app"}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?sdk\\.privacy-center\\.org([\\\/:&\\?].*)?$","if-domain":["*qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?sdk\\.privacy-center\\.org([\\\/:&\\?].*)?$","if-domain":["*qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?api\\.privacy-center\\.org([\\\/:&\\?].*)?$","if-domain":["*qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?api\\.privacy-center\\.org([\\\/:&\\?].*)?$","if-domain":["*qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?clarity\\.ms([\\\/:&\\?].*)?$","if-domain":["*qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?clarity\\.ms([\\\/:&\\?].*)?$","if-domain":["*qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?c\\.bing\\.com([\\\/:&\\?].*)?$","if-domain":["*qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?c\\.bing\\.com([\\\/:&\\?].*)?$","if-domain":["*qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?msadsscale\\.azureedge\\.net([\\\/:&\\?].*)?$","if-domain":["*qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?msadsscale\\.azureedge\\.net([\\\/:&\\?].*)?$","if-domain":["*qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?microsoft\\.com([\\\/:&\\?].*)?$","if-domain":["*qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?microsoft\\.com([\\\/:&\\?].*)?$","if-domain":["*qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?int\\.ovh\\.kube\\.qwant\\.ninja([\\\/:&\\?].*)?$","if-domain":["*qwant.com"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?int\\.ovh\\.kube\\.qwant\\.ninja([\\\/:&\\?].*)?$","if-domain":["*qwant.app"]}},
{"action":{"type":"ignore-previous-rules"},"trigger":{"url-filter":"^[htpsw]+:\\\/\\\/([a-z0-9-]+\\.)?sdk\\.privacy-center\\.org"}}
"""#
    }
}
