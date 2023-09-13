// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
import StoreKit
import Shared
import Sentry
import Storage

@testable import Client

class QwantRatingPromptManagerTests: XCTestCase {
    
    var urlOpenerSpy: URLOpenerSpy!
    var promptManager: QwantRatingPromptManager!
    var createdGuids: [String] = []
    var sentry: CrashingMockSentryClient!
    
    override func setUp() {
        super.setUp()
        
        urlOpenerSpy = URLOpenerSpy()
    }
    
    override func tearDown() {
        super.tearDown()
        
        createdGuids = []
        promptManager?.reset()
        promptManager = nil
        sentry = nil
        urlOpenerSpy = nil
    }
    
    func testShouldShowPrompt_requiredAreFalse_returnsFalse() {
        setupEnvironment(hasCumulativeDaysOfUse: false,
                         hasUsesInDay: false,
                         hasDaysAfterInstall: false)
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 0)
    }
    
    func testShouldShowPrompt_requiredAreTrue_returnsTrue() {
        setupEnvironment()
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 1)
    }
    
    func testShouldShowPrompt_cumulativeDaysOfUseFalse_returnsFalse() {
        setupEnvironment(hasCumulativeDaysOfUse: false)
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 0)
    }
    
    func testShouldShowPrompt_UsesInDayFalse_returnsFalse() {
        setupEnvironment(hasUsesInDay: false)
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 0)
    }
    
    func testShouldShowPrompt_daysAfterInstallFalse_returnsFalse() {
        setupEnvironment(hasDaysAfterInstall: false)
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 0)
    }
    
    func testShouldShowPrompt_sentryHasCrashedInLastSession_returnsFalse() {
        setupEnvironment()
        sentry?.enableCrashOnLastLaunch = true
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 0)
    }
    
    func testShouldShowPrompt_hasRequestedTwoYearsAgo_returnsTrue() {
        setupEnvironment()
        let moreThanAYearAgo = Calendar.current.date(byAdding: .day, value: -400, to: Date().noon) ?? Date()
        promptManager.showRatingPromptIfNeeded(at: moreThanAYearAgo)
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 2)
    }
    
    func testShouldShowPrompt_hasRequestedInTheLastYear_returnsFalse() {
        setupEnvironment()
        promptManager.showRatingPromptIfNeeded(at: Date().lastWeek)
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 1)
    }
    
    // MARK: Number of times asked
    
    func testShouldShowPrompt_requestCountTwiceCountIsAtOne() {
        setupEnvironment()
        promptManager.showRatingPromptIfNeeded()
        promptManager.showRatingPromptIfNeeded()
        XCTAssertEqual(ratingPromptOpenCount, 1)
    }
    
    // MARK: App Store
    
    func testGoToAppStoreReview() {
        QwantRatingPromptManager.goToAppStoreReview(with: urlOpenerSpy)
        XCTAssertEqual(urlOpenerSpy.openURLCount, 1)
        XCTAssertEqual(urlOpenerSpy.capturedURL?.absoluteString, "https://itunes.apple.com/app/id\(AppInfo.qwantAppStoreId)?action=write-review")
    }
}

// MARK: - Setup helpers

private extension QwantRatingPromptManagerTests {
    
    func setupEnvironment(hasCumulativeDaysOfUse: Bool = true,
                          hasUsesInDay: Bool = true,
                          hasDaysAfterInstall: Bool = true) {
        setupPromptManager(hasCumulativeDaysOfUse: hasCumulativeDaysOfUse, hasUsesInDay: hasUsesInDay, hasDaysAfterInstall: hasDaysAfterInstall)
    }
    
    func setupPromptManager(hasCumulativeDaysOfUse: Bool, hasUsesInDay: Bool, hasDaysAfterInstall: Bool) {
        let mockCumulativeDaysOfUseCounter = QwantCumulativeDaysOfUseCounterMock(hasCumulativeDaysOfUse)
        let mockUsesInDayCounter = QwantUsesInDayCounterMock(hasUsesInDay)
        let mockDaysAfterInstallCounter = QwantDaysAfterInstallCounterMock(hasDaysAfterInstall)
        sentry = CrashingMockSentryClient()
        promptManager = QwantRatingPromptManager(daysOfUseCounter: mockCumulativeDaysOfUseCounter,
                                                 usesInDayCounter: mockUsesInDayCounter,
                                                 daysAfterInstallCounter: mockDaysAfterInstallCounter,
                                                 sentry: sentry)
    }
    
    var ratingPromptOpenCount: Int {
        UserDefaults.standard.object(forKey: QwantRatingPromptManager.UserDefaultsKey.keyRatingPromptRequestCount.rawValue) as? Int ?? 0
    }
}

// MARK: - QwantCumulativeDaysOfUseCounterMock
class QwantCumulativeDaysOfUseCounterMock: QwantCumulativeDaysOfUseCounter {
    
    private let hasMockRequiredDaysOfUse: Bool
    init(_ hasRequiredCumulativeDaysOfUse: Bool) {
        self.hasMockRequiredDaysOfUse = hasRequiredCumulativeDaysOfUse
    }
    
    override var hasRequiredCumulativeDaysOfUse: Bool {
        return hasMockRequiredDaysOfUse
    }
}

// MARK: - QwantUsesInDayCounterMock
class QwantUsesInDayCounterMock: QwantUsesInDayCounter {
    
    private let hasMockRequiredUsesInDay: Bool
    init(_ hasMockRequiredUsesInDay: Bool) {
        self.hasMockRequiredUsesInDay = hasMockRequiredUsesInDay
    }
    
    override var hasRequiredUsesInDay: Bool {
        return hasMockRequiredUsesInDay
    }
}

// MARK: - QwantDaysAfterInstallCounterMock
class QwantDaysAfterInstallCounterMock: QwantDaysAfterInstallCounter {
    
    private let hasMockRequiredDaysAfterInstall: Bool
    init(_ hasRequiredDaysAfterInstall: Bool) {
        self.hasMockRequiredDaysAfterInstall = hasRequiredDaysAfterInstall
    }
    
    override var hasRequiredDaysAfterInstall: Bool {
        return hasMockRequiredDaysAfterInstall
    }
}
