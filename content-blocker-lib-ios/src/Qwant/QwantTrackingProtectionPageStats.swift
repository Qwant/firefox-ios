// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared
import Foundation

struct QwantTPPageStats {
    var domains: [String]
    
    var total: Int {
        return domains.count
    }
    
    init() {
        domains = [String]();
    }
    
    private init(domains: [String], host: String) {
        self.domains = domains + [host]
        QwantContentBlockerStats().appendStat(for: host)
    }
    
    func create(host: String) -> QwantTPPageStats {
        return QwantTPPageStats(domains: domains, host: host)
    }
}

class QwantTPStatsBlocklistChecker {
    static let shared = QwantTPStatsBlocklistChecker()
    
    // Initialized async, is non-nil when ready to be used.
    private var blockLists: QwantTPStatsBlocklists?
    
    func isBlocked(url: URL, mainDocumentURL: URL) -> Deferred<Bool> {
        let deferred = Deferred<Bool>()
        
        guard let blockLists = blockLists, let host = url.host, !host.isEmpty else {
            // TP Stats init isn't complete yet
            deferred.fill(false)
            return deferred
        }
        
        guard let domain = url.baseDomain, let docDomain = mainDocumentURL.baseDomain, domain != docDomain else {
            deferred.fill(false)
            return deferred
        }
        
        // Make a copy on the main thread
        let safelistRegex = QwantContentBlocker.shared.safelistedDomains.domainRegex
        
        DispatchQueue.global().async {
            // Return true in the Deferred if the domain could potentially be blocked
            deferred.fill(blockLists.urlIsInList(url, mainDocumentURL: mainDocumentURL, safelistedDomains: safelistRegex))
        }
        return deferred
    }
    
    var loading = false
    
    func reload(blocklists: [QwantBlocklistFileName]) {
        guard !self.loading else { return }
        DispatchQueue.global().async {
            self.loading = true
            let parser = QwantTPStatsBlocklists(blockListFiles: blocklists)
            parser.load()
            DispatchQueue.main.async {
                self.blockLists = parser
                self.loading = false
            }
        }
    }
    
    func startup() {
        DispatchQueue.global().async {
            self.loading = true
            let parser = QwantTPStatsBlocklists()
            parser.load()
            DispatchQueue.main.async {
                self.blockLists = parser
                self.loading = false
            }
        }
    }
}

class QwantTPStatsBlocklists {
    let blockListFiles: [QwantBlocklistFileName]
    
    init(blockListFiles: [QwantBlocklistFileName]? = nil) {
        self.blockListFiles = blockListFiles ?? QwantBlocklistFileName.allCases
    }
    
    class QwantRule {
        let regex: String
        let domainExceptions: [String]?
        
        init(regex: String, domainExceptions: [String]?) {
            self.regex = regex
            self.domainExceptions = domainExceptions
        }
    }
    
    var blockRules = [String: [QwantRule]]()
    
    func load() {
        let start = Date()
        // Use the strict list of files, as it is the complete list of rules,
        // keeping in mind the stats can't distinguish block vs cookie-block,
        // only that an url did or didn't match.
        for blockListFile in blockListFiles {
            let list: [[String: AnyObject]]
            do {
                guard let path = Bundle.main.path(forResource: blockListFile.filename, ofType: "json") else {
                    assertionFailure("Blocklists: bad file path.")
                    return
                }
                
                let json = try Data(contentsOf: URL(fileURLWithPath: path))
                guard let data = try JSONSerialization.jsonObject(with: json, options: []) as? [[String: AnyObject]] else {
                    assertionFailure("Blocklists: bad JSON cast.")
                    return
                }
                list = data
            } catch {
                assertionFailure("Blocklists: \(error.localizedDescription)")
                return
            }
            
            for rule in list {
                guard let trigger = rule["trigger"] as? [String: AnyObject],
                      let filter = trigger["url-filter"] as? String,
                      let action = rule["action"] as? [String: AnyObject],
                      let type = action["type"] as? String else {
                    assertionFailure("Blocklists error: Rule has unexpected format.")
                    continue
                }
                
                guard type == "block" else {
                    continue
                }
                
                guard let baseDomain = associatedDomainForFilter(filter) else {
                    assert(false, "url-filter code needs updating for new list format")
                    continue
                }
                
#if DEBUG
                // Sanity check for the lists.
                ["*", "?", "+"].forEach { x in
                    // This will only happen on debug
                    assert(!baseDomain.contains(x), "No wildcards allowed in baseDomain")
                }
#endif
                
                let domainExceptionsRegex = (trigger["unless-domain"] as? [String])?.compactMap { domain in
                    return wildcardContentBlockerDomainToRegex(domain: domain)
                }
                
                let rule = QwantRule(regex: filter, domainExceptions: domainExceptionsRegex)
                blockRules[baseDomain] = (blockRules[baseDomain] ?? []) + [rule]
            }
        }
        
        print("Elapsed time : \(Date().timeIntervalSince1970 - start.timeIntervalSince1970)s")
    }
    
    func urlIsInList(_ url: URL, mainDocumentURL: URL, safelistedDomains: [String]) -> Bool {
        let resourceString = url.absoluteString
        
        guard let firstPartyDomain = mainDocumentURL.baseDomain, let baseDomain = url.baseDomain, let rules = blockRules[baseDomain] else {
            return false
        }
        
        for rule in rules {
            // First, test the top-level filters to see if this URL might be blocked.
            if resourceString.range(of: rule.regex, options: .regularExpression) != nil {
                // Check the domain exceptions. If a domain exception matches, this filter does not apply.
                for domainRegex in (rule.domainExceptions ?? []) {
                    if firstPartyDomain.range(of: domainRegex, options: .regularExpression) != nil {
                        continue
                    }
                }
                
                // Check the safelist.
                if let baseDomain = url.baseDomain, !safelistedDomains.isEmpty {
                    for ignoreDomain in safelistedDomains {
                        if baseDomain.range(of: ignoreDomain, options: .regularExpression) != nil {
                            return false
                        }
                    }
                }
                return true
            }
        }
        
        guard let baseDomain = url.host, let rules = blockRules[baseDomain] else {
            return false
        }
        
        for rule in rules {
            // First, test the top-level filters to see if this URL might be blocked.
            if resourceString.range(of: rule.regex, options: .regularExpression) != nil {
                // Check the domain exceptions. If a domain exception matches, this filter does not apply.
                for domainRegex in (rule.domainExceptions ?? []) {
                    if firstPartyDomain.range(of: domainRegex, options: .regularExpression) != nil {
                        continue
                    }
                }
                return true
            }
        }
        return false
    }
    
    private func associatedDomainForFilter(_ filter: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: #"[-a-zA-Z0-9]+(\\+\.[-a-zA-Z0-9]{2,})+"#)
            guard let result = regex.firstMatch(in: filter, range: NSRange(filter.startIndex..., in: filter)) else { return nil }
            return String(filter[Range(result.range, in: filter)!]).replacingOccurrences(of: "\\.", with: ".")
        } catch _ {
            return nil
        }
    }
}
