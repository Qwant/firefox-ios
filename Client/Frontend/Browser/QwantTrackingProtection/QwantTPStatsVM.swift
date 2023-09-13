// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared

struct QwantTPStatsVM {
    
    // MARK: - Variables
    var stats: QwantContentBlockerStats
    
    init(stats: QwantContentBlockerStats) {
        self.stats = stats
    }
    
    var title: String {
        return .QwantTrackingProtection.Statistics
    }
    
    var statisticsBlockedTrackersTitleString: String {
        return .QwantTrackingProtection.ItemsBlocked
    }
    
    var statisticsSavedTimeTitleString: String {
        return .QwantTrackingProtection.TimeSaved
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
    
    var orderedDomains: Array<(key: String, value: Int)> {
        return stats.blockedTrackers.sorted { (lhs, rhs) in
            if lhs.value == rhs.value {
                return lhs.key < rhs.key
            }
            
            return lhs.value > rhs.value
        }
    }
}
