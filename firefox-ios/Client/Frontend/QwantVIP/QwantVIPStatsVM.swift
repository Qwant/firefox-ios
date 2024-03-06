// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Shared

struct QwantVIPStatsVM {
    // MARK: - Variables
    var stats: QwantVIPGlobalStats
    var prefs: Prefs

    init(stats: QwantVIPGlobalStats, prefs: Prefs) {
        self.stats = stats
        self.prefs = prefs
    }

    var hasJustReactivatedStats = false

    var hasDeactivatedStats: Bool {
        get { return prefs.boolForKey(PrefsKeys.QwantVIPStatisticsDeactivated) ?? false }
        set {
            if !newValue {
                hasJustReactivatedStats = true
            }
            stats.reset()
            prefs.setBool(newValue, forKey: PrefsKeys.QwantVIPStatisticsDeactivated)
        }
    }

    var shouldShowPlaceholder: Bool {
        return !hasBlockedAtLeastOneTracker || hasDeactivatedStats
    }

    var title: String {
        return .QwantVIP.Statistics
    }

    var placeholderButtonTitle: String {
        return .QwantVIP.ReactivateStats
    }

    var deactivateStatsTitle: String {
        return .QwantVIP.DeactivateStats
    }

    var deactivateStatsMessage: String {
        return .QwantVIP.DeactivateStatsDetails
    }

    var deactivateStatsConfirmActionTitle: String {
        return .QwantVIP.DeactivateStatsConfirm
    }

    var deactivateStatsCancelActionTitle: String {
        return .QwantVIP.DeactivateStatsCancel
    }

    var deleteStatsTitle: String {
        return .QwantVIP.DeleteStats
    }

    var statisticsBlockedTrackersTitleString: String {
        return .QwantVIP.ItemsBlocked
    }

    var statisticsSavedTimeTitleString: String {
        return .QwantVIP.TimeSaved
    }

    var statisticsTrackersBlockedFormattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "

        let number = NSNumber(value: stats.blockedTrackersCount)
        return formatter.string(from: number)!
    }

    var statisticsTimeSavedFormattedString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full

        return formatter.string(from: stats.savedTime)!
    }

    var orderedDomains: [(key: String, value: Int)] {
        return stats.blockedTrackers.sorted { (lhs, rhs) in
            if lhs.value == rhs.value {
                return lhs.key < rhs.key
            }

            return lhs.value > rhs.value
        }
    }

    var hasBlockedAtLeastOneTracker: Bool {
        return stats.blockedTrackersCount > 0
    }

    var leftHandSideHeaderTitle: String {
        return hasBlockedAtLeastOneTracker ? .QwantVIP.DomainsTitle.uppercased() : ""
    }

    var rightHandSideHeaderTitle: String {
        return hasBlockedAtLeastOneTracker ? .QwantVIP.TrackersCookiesTitle.uppercased() : ""
    }

    var placeholderTextTitle: String {
        if hasDeactivatedStats {
            return .QwantVIP.DeactivatedForNow
        } else if hasJustReactivatedStats {
            return .QwantVIP.JustActivated
        } else {
            return .QwantVIP.NothingToSee
        }
    }

    var placeholderImage: UIImage {
        if hasDeactivatedStats {
            return UIImage(named: "illustration_stats_disabled")!
        } else {
            return UIImage(named: "illustration_stats")!
        }
    }
}
