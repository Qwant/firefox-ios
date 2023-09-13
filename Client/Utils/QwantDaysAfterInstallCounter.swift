// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// Counter to know if a user has the app installed for a certain number of days, used for `QwantRatingPromptManager` requirements.
class QwantDaysAfterInstallCounter {
    
    private let calendar = Calendar.current
#if MOZ_CHANNEL_BETA
    private let requiredDaysAfterInstall = 1
#else
    private let requiredDaysAfterInstall = 21
#endif
    
    private enum UserDefaultsKey: String {
        case keyInstallDate = "com.qwant.installDate.key"
        case keyRequiredDaysAfterInstall = "com.qwant.hasRequiredDaysAfterInstall.key"
    }
    
    private(set) var hasRequiredDaysAfterInstall: Bool {
        get { UserDefaults.standard.object(forKey: UserDefaultsKey.keyRequiredDaysAfterInstall.rawValue) as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyRequiredDaysAfterInstall.rawValue) }
    }
    
    var installDate: Date? {
        get { UserDefaults.standard.object(forKey: UserDefaultsKey.keyInstallDate.rawValue) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyInstallDate.rawValue) }
    }
    
    var debugMessage: String {
        if hasRequiredDaysAfterInstall {
            return "[\(requiredDaysAfterInstall) out of \(requiredDaysAfterInstall)] → \(hasRequiredDaysAfterInstall)"
        }
        let install = self.installDate ?? Date()
        return "[\(calendar.numberOfDaysBetween(install, and: Date())) out of \(requiredDaysAfterInstall)] → \(hasRequiredDaysAfterInstall(installDate: install))"
    }
    
    func updateInstallDate(currentDate: Date = Date()) {
        if installDate == nil {
            installDate = currentDate
        }

        hasRequiredDaysAfterInstall = hasRequiredDaysAfterInstall(installDate: installDate!)
    }
    
    private func hasRequiredDaysAfterInstall(installDate: Date) -> Bool {
        return calendar.numberOfDaysBetween(installDate, and: Date()) >= requiredDaysAfterInstall
    }
    
    func reset() {
        hasRequiredDaysAfterInstall = false
        installDate = nil
    }
}
