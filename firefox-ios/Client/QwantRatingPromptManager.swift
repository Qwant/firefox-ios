// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import StoreKit
import Shared
import Storage
import Common

/// The `QwantRatingPromptManager` handles app store review requests and the internal
/// logic of when they can be presented to a user.
final class QwantRatingPromptManager {
    private let daysOfUseCounter: QwantCumulativeDaysOfUseCounter
    private let usesInDayCounter: QwantUsesInDayCounter
    private let daysAfterInstallCounter: QwantDaysAfterInstallCounter

    private let logger: Logger

    enum UserDefaultsKey: String {
        case keyRatingPromptLastRequestDate = "com.qwant.ratingPromptLastRequestDate.key"
        case keyRatingPromptRequestCount = "com.qwant.ratingPromptRequestCount.key"
    }

    /// Initializes the `QwantRatingPromptManager`
    ///
    /// - Parameters:
    ///   - daysOfUseCounter: Counter for the cumulative days of use of the application by the user
    ///   - usesInDayCounter: Counter for the uses in day of the application by the user
    ///   - daysAfterInstallCounter: Counter for the days that has passed after the installation 
    ///         of the application by the user
    ///   - logger: Logger protocol to override in Unit test
    init(daysOfUseCounter: QwantCumulativeDaysOfUseCounter = QwantCumulativeDaysOfUseCounter(),
         usesInDayCounter: QwantUsesInDayCounter = QwantUsesInDayCounter(),
         daysAfterInstallCounter: QwantDaysAfterInstallCounter = QwantDaysAfterInstallCounter(),
         logger: Logger = DefaultLogger.shared) {
        self.daysOfUseCounter = daysOfUseCounter
        self.usesInDayCounter = usesInDayCounter
        self.daysAfterInstallCounter = daysAfterInstallCounter
        self.logger = logger
    }

    /// Show the in-app rating prompt if needed
    /// - Parameter date: Request at a certain date - Useful for unit tests
    func showRatingPromptIfNeeded(at date: Date = Date()) {
        if shouldShowPrompt {
            requestRatingPrompt(at: date)
        }
    }

    /// Conformance to existing codebase
    /// No usage of the parameter
    func updateData(dataLoadingCompletion: (() -> Void)? = nil) {
        daysAfterInstallCounter.updateInstallDate()
        usesInDayCounter.updateCounter()
        daysOfUseCounter.updateCounter()
    }

    /// Go to the App Store review page of this application
    /// - Parameter urlOpener: Opens the App Store url
    static func goToAppStoreReview(with urlOpener: URLOpenerProtocol = UIApplication.shared) {
        guard let url = URL(string: "https://itunes.apple.com/app/id\(AppInfo.qwantAppStoreId)?action=write-review") else { return }
        urlOpener.open(url)
    }

    // MARK: UserDefaults

    private var lastRequestDate: Date? {
        get { return UserDefaults.standard.object(forKey: UserDefaultsKey.keyRatingPromptLastRequestDate.rawValue) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyRatingPromptLastRequestDate.rawValue) }
    }

    private var requestCount: Int {
        get { UserDefaults.standard.object(forKey: UserDefaultsKey.keyRatingPromptRequestCount.rawValue) as? Int ?? 0 }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.keyRatingPromptRequestCount.rawValue) }
    }

    func reset() {
        lastRequestDate = nil
        requestCount = 0
    }

    var debugMessage: String {
        return """
3 consecutive days of use: \(daysOfUseCounter.debugMessage)
6 uses in a single day: \(usesInDayCounter.debugMessage)
3 weeks of usage: \(daysAfterInstallCounter.debugMessage)
has not crashed in the last session: \(!logger.crashedLastLaunch)
one year has passed: \(!hasRequestedInTheLastYear)

When hitting OK, the user rating \(shouldShowPrompt ? "should" : "should't") be shown \(shouldShowPrompt ? "!!!! YAAYY!" : "yet...")
"""
    }

    // MARK: Private

    private var shouldShowPrompt: Bool {
        // Required: 3 consecutive days of use
        guard daysOfUseCounter.hasRequiredCumulativeDaysOfUse else { return false }

        // Required: 6 uses in a single day
        guard usesInDayCounter.hasRequiredUsesInDay else { return false }

        // Required: 3 weeks of usage
        guard daysAfterInstallCounter.hasRequiredDaysAfterInstall else { return false }

        // Required: has not crashed in the last session
        guard !logger.crashedLastLaunch else { return false }

        // Ensure we ask again only if one year has passed
        guard !hasRequestedInTheLastYear else { return false }

        return true
    }

    private func requestRatingPrompt(at date: Date) {
        lastRequestDate = date
        requestCount += 1

        guard let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene else { return }

        DispatchQueue.main.async {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private var hasRequestedInTheLastYear: Bool {
        guard let lastRequestDate = lastRequestDate else { return false }

        let currentDate = Date()
        let numberOfDays = Calendar.current.numberOfDaysBetween(lastRequestDate, and: currentDate)

        return numberOfDays <= 365
    }
}
