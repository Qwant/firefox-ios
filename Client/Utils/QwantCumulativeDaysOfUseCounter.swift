// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// Counter to know if a user has used the app a certain number of days in a row, used for `QwantRatingPromptManager` requirements.
class QwantCumulativeDaysOfUseCounter {
    
    private let calendar = Calendar.current
#if MOZ_CHANNEL_BETA
    private let requiredCumulativeDaysOfUseCount = 1
#else
    private let requiredCumulativeDaysOfUseCount = 3
#endif
    
    private enum UserDefaultsKey: String {
        case keyArrayDaysOfUse = "com.qwant.arrayDaysOfUse.key"
        case keyRequiredCumulativeDaysOfUseCount = "com.qwant.hasRequiredCumulativeDaysOfUseCount.key"
    }
    
    private(set) var hasRequiredCumulativeDaysOfUse: Bool {
        get { UserDefaults.standard.object(forKey: UserDefaultsKey.keyRequiredCumulativeDaysOfUseCount.rawValue) as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyRequiredCumulativeDaysOfUseCount.rawValue) }
    }
    
    var daysOfUse: [Date]? {
        get { UserDefaults.standard.array(forKey: UserDefaultsKey.keyArrayDaysOfUse.rawValue) as? [Date] }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyArrayDaysOfUse.rawValue) }
    }
    
    var debugMessage: String {
        if hasRequiredCumulativeDaysOfUse {
            return "[\(requiredCumulativeDaysOfUseCount) out of \(requiredCumulativeDaysOfUseCount)] → \(hasRequiredCumulativeDaysOfUse)"
        }
        let uses = self.daysOfUse ?? []
        return "[\(uses.count) out of \(requiredCumulativeDaysOfUseCount)] → \(hasRequiredCumulativeDaysOfUse(daysOfUse: uses))"
    }
    
    func updateCounter(currentDate: Date = Date()) {
        // Do some cleanup in case we've reached the threshold already
        guard !hasRequiredCumulativeDaysOfUse else {
            cleanDaysOfUseData()
            return
        }
        
        // If there's no data, add current day of usage
        guard var daysOfUse = daysOfUse, let lastDayOfUse = daysOfUse.last else {
            daysOfUse = [currentDate]
            self.daysOfUse = daysOfUse
            return
        }
        
        let delta = calendar.numberOfDaysBetween(lastDayOfUse, and: currentDate)
        
        // Ensure delta of elapsed days is greater than 0
        guard delta > 0 else {
            return
        }
        
        // Reset the counter in case of a usage more than a day ago
        guard delta == 1 else {
            daysOfUse = [currentDate]
            self.daysOfUse = daysOfUse
            return
        }
        
        // Append usage days that are not already saved
        daysOfUse.append(currentDate)
        self.daysOfUse = daysOfUse
        
        // Check if we have 3 consecutive days of usage
        hasRequiredCumulativeDaysOfUse = hasRequiredCumulativeDaysOfUse(daysOfUse: daysOfUse)
    }
    
    private func hasRequiredCumulativeDaysOfUse(daysOfUse: [Date]) -> Bool {
        return daysOfUse.count >= requiredCumulativeDaysOfUseCount
    }
    
    private func cleanDaysOfUseData() {
        daysOfUse = nil
    }
    
    func reset() {
        hasRequiredCumulativeDaysOfUse = false
        daysOfUse = nil
    }
}
