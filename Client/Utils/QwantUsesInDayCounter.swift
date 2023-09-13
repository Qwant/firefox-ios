// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// Counter to know if a user has used the app a certain number of days in a row, used for `QwantRatingPromptManager` requirements.
class QwantUsesInDayCounter {
    
    private let calendar = Calendar.current
    private let requiredUsesInDayCount = 6
    
    private enum UserDefaultsKey: String {
        case keyArrayUsesOfDay = "com.qwant.arrayUsesOfDay.key"
        case keyRequiredUsesInDayCount = "com.qwant.keyRequiredUsesInDayCount.key"
    }
    
    private(set) var hasRequiredUsesInDay: Bool {
        get { UserDefaults.standard.object(forKey: UserDefaultsKey.keyRequiredUsesInDayCount.rawValue) as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyRequiredUsesInDayCount.rawValue) }
    }
    
    var usesOfDay: [Date]? {
        get { UserDefaults.standard.array(forKey: UserDefaultsKey.keyArrayUsesOfDay.rawValue) as? [Date] }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyArrayUsesOfDay.rawValue) }
    }
    
    var debugMessage: String {
        if hasRequiredUsesInDay {
            return "[\(requiredUsesInDayCount) out of \(requiredUsesInDayCount)] → \(hasRequiredUsesInDay)"
        }
        let uses = self.usesOfDay ?? []
        return "[\(uses.count) out of \(requiredUsesInDayCount)] → \(hasRequiredUsesInDay(usesOfDay: uses))"
    }
    
    func updateCounter(currentDate: Date = Date()) {
        // Do some cleanup in case we've reached the threshold already
        guard !hasRequiredUsesInDay else {
            cleanUsesInDayData()
            return
        }
        
        // If there's no data, or the new date is not in the same day as the previous one
        // set the firstUseOfDay to be the currentDate
        guard var usesOfDay = usesOfDay, usesOfDay.first?.isSameDay(of: currentDate) == true else {
            usesOfDay = [currentDate]
            return
        }
        
        usesOfDay.append(currentDate)
        self.usesOfDay = usesOfDay
        
        // Check if we have 6 uses in the same day
        hasRequiredUsesInDay = hasRequiredUsesInDay(usesOfDay: usesOfDay)
    }
    
    private func hasRequiredUsesInDay(usesOfDay: [Date]) -> Bool {
        return usesOfDay.count >= requiredUsesInDayCount
    }
    
    private func cleanUsesInDayData() {
        usesOfDay = nil
    }
    
    func reset() {
        hasRequiredUsesInDay = false
        usesOfDay = nil
    }
}
