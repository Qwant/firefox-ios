// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest

@testable import Client

class QwantCumulativeDaysOfUseCounterTests: XCTestCase {
    
    private let calendar = Calendar.current
    private var counter: QwantCumulativeDaysOfUseCounter!
    
    override func setUp() {
        super.setUp()
        counter = QwantCumulativeDaysOfUseCounter()
        counter.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        counter = nil
    }
    
    func testByDefaultCounter_isFalse() {
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertNil(counter.daysOfUse)
    }
    
    func testUpdateCounterOnce_isFalse() {
        counter.updateCounter()
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 1)
    }
    
    func testUpdateCounter5TimesSameDay_isFalse() {
        for _ in 0...5 {
            counter.updateCounter()
        }
        
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 1)
    }
    
    func testUpdateCounterMoreThan5TimesSameDay_isFalse() {
        for _ in 0...10 {
            counter.updateCounter()
        }
        
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 1)
    }
    
    func testUpdateCounterFourTimeDifferentDaysWithOneDayBetween_isFalse() {
        let currentDate = Date()
        addUsageDays(from: 0, to: 1, currentDate: currentDate)
        addUsageDays(from: 3, to: 4, currentDate: currentDate)
        
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 2)
    }
    
    func testUpdateCounterFourTimeDifferentDaysWithDaysBetween_isFalse() {
        let currentDate = Date()
        addUsageDays(from: 1, to: 2, currentDate: currentDate)
        addUsageDays(from: 7, to: 8, currentDate: currentDate)
        
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 2)
    }
    
    func testUpdateCounterThreeTimeDifferentDaysInARow_isTrue() {
        let currentDate = Date()
        addUsageDays(from: 0, to: 2, currentDate: currentDate)
        
        XCTAssertTrue(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 3)
    }
    
    func testUpdateCounterMultipleTimesDailyForMultipleDaysExceptDay2_isFalse() {
        // Day 1: Opens the app 3 times
        let currentDate = Date()
        counter.updateCounter(currentDate: currentDate)
        counter.updateCounter(currentDate: currentDate)
        counter.updateCounter(currentDate: currentDate)
        
        // Day 2: Nothing
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 1)
        
        // Day 3: Opens the app 2 times
        updateCounter(numberOfDays: 2, currentDate: currentDate)
        updateCounter(numberOfDays: 2, currentDate: currentDate)
        
        // Day 4: Opens the app 1 time
        updateCounter(numberOfDays: 3, currentDate: currentDate)
        
        // Day 5: Nothing
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 2)
    }
    
    func testUpdateCounterMultipleTimesDailyForMultipleDays_isTrue() {
        // Day 1: Opens the app 3 times
        let currentDate = Date()
        counter.updateCounter(currentDate: currentDate)
        counter.updateCounter(currentDate: currentDate)
        counter.updateCounter(currentDate: currentDate)
        
        // Day 2: Opens the app 2 times
        updateCounter(numberOfDays: 1, currentDate: currentDate)
        updateCounter(numberOfDays: 1, currentDate: currentDate)
        XCTAssertFalse(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertEqual(counter.daysOfUse?.count, 2)
        
        // Day 3: Opens the app 1 time
        updateCounter(numberOfDays: 2, currentDate: currentDate)
        
        // Day 4: Opens the app 3 times
        updateCounter(numberOfDays: 3, currentDate: currentDate)
        updateCounter(numberOfDays: 3, currentDate: currentDate)
        updateCounter(numberOfDays: 3, currentDate: currentDate)
        
        // Day 5: Opens the app 1 time
        updateCounter(numberOfDays: 4, currentDate: currentDate)
        XCTAssertTrue(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertNil(counter.daysOfUse)
        
        // Day 6: Opens the app 2 times
        updateCounter(numberOfDays: 5, currentDate: currentDate)
        updateCounter(numberOfDays: 5, currentDate: currentDate)
        XCTAssertTrue(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertNil(counter.daysOfUse)
        
        // Day 9: Opens the app 2 times
        updateCounter(numberOfDays: 8, currentDate: currentDate)
        updateCounter(numberOfDays: 8, currentDate: currentDate)
        XCTAssertTrue(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertNil(counter.daysOfUse)
    }
    
    func testHadFiveCumulativeDaysInPastCanBeTrueAgain() {
        // Day 1 to 5: daily usage
        let currentDate = Date()
        addUsageDays(from: 0, to: 4, currentDate: currentDate)
        XCTAssertTrue(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertNil(counter.daysOfUse)
        
        // 4 days break then day 9 to 13: daily usage
        addUsageDays(from: 9, to: 13, currentDate: currentDate)
        XCTAssertTrue(counter.hasRequiredCumulativeDaysOfUse)
        XCTAssertNil(counter.daysOfUse)
    }
}

// MARK: Helpers
private extension QwantCumulativeDaysOfUseCounterTests {
    func addUsageDays(from: Int, to: Int, currentDate: Date) {
        for numberOfDay in from...to {
            updateCounter(numberOfDays: numberOfDay, currentDate: currentDate)
        }
    }
    
    func updateCounter(numberOfDays: Int, currentDate: Date) {
        let date = calendar.add(numberOfDays: numberOfDays, to: currentDate)!
        counter.updateCounter(currentDate: date)
    }
}
