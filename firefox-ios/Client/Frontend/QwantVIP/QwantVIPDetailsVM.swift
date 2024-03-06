// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Shared

struct QwantVIPDetailsVM {
    // MARK: - Variables
    var tab: Tab

    var stats: QwantVIPPageStats {
        return tab.contentBlocker?.stats ?? QwantVIPPageStats()
    }

    var websiteTitle: String {
        return tab.url?.baseDomain ?? ""
    }

    var blockedTrackersCount: Int {
        return stats.total
    }

    var blockedTrackersTitleString: String {
        return .QwantVIP.TrackersTitle
    }

    var blockedDomainsCount: Int {
        return stats.domains.count
    }

    var blockedDomainsTitleString: String {
        return .QwantVIP.DomainsTitle
    }

    var orderedDomains: [(key: String, value: Int)] {
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
        return .QwantVIP.LocalProtection
    }

    var hasBlockedAtLeastOneTracker: Bool {
        return blockedTrackersCount > 0
    }

    var leftHandSideHeaderTitle: String {
        return hasBlockedAtLeastOneTracker ? .QwantVIP.DomainsTitle.uppercased() : ""
    }

    var rightHandSideHeaderTitle: String {
        return hasBlockedAtLeastOneTracker ? .QwantVIP.TrackersCookiesTitle.uppercased() : ""
    }

    var placeholderTextTitle: String {
        return .QwantVIP.EmptyListTrackersBlocked
    }
}
