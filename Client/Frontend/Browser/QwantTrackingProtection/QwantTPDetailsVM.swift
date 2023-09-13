// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared

struct QwantTPDetailsVM {
    
    // MARK: - Variables
    var tab: Tab
    
    var stats: QwantTPPageStats {
        return tab.contentBlocker?.stats ?? QwantTPPageStats()
    }
    
    var websiteTitle: String {
        return tab.url?.baseDomain ?? ""
    }
    
    var blockedTrackersCount: Int {
        return stats.total
    }
    
    var blockedTrackersTitleString: String {
        return .QwantTrackingProtection.TrackersTitle
    }
    
    var blockedDomainsCount: Int {
        return stats.domains.count
    }
    
    var blockedDomainsTitleString: String {
        return .QwantTrackingProtection.DomainsTitle
    }
    
    var orderedDomains: Array<(key: String, value: Int)> {
        var domains: [String: Int] = [:]
        
        for domain in stats.domains {
            domains[domain] = (domains[domain] != nil) ? domains[domain]! + 1 : 1
        }
        return domains.sorted { (lhs, rhs) in
            if lhs.value == rhs.value {
                return lhs.key < rhs.key
            }
            
            return lhs.value > rhs.value
        }
    }
    
    var title: String {
        return .QwantTrackingProtection.LocalProtection
    }
}
