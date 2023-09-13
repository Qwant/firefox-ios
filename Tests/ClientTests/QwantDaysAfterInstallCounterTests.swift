// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest

@testable import Client

class QwantDaysAfterInstallCounterTests: XCTestCase {
    
    private var counter: QwantDaysAfterInstallCounter!
    
    override func setUp() {
        super.setUp()
        counter = QwantDaysAfterInstallCounter()
        counter.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        counter = nil
    }
    
    func testByDefaultCounter_isFalse() {
        XCTAssertFalse(counter.hasRequiredDaysAfterInstall)
        XCTAssertNil(counter.installDate)
    }
    
    func testUpdateCounterOnce_isFalse() {
        let currentDate = Date()
        counter.updateInstallDate(currentDate: currentDate)
        XCTAssertFalse(counter.hasRequiredDaysAfterInstall)
        XCTAssertEqual(counter.installDate, currentDate)
    }
    
    func testUpdateCounterBefore21Days_isFalse() {
        let yesterday = Date().dayBefore
        counter.updateInstallDate(currentDate: yesterday)
        XCTAssertFalse(counter.hasRequiredDaysAfterInstall)
        XCTAssertEqual(counter.installDate, yesterday)
    }
    
    func testUpdateCounterThreeTimesBefore21Days_isFalse() {
        counter.updateInstallDate(currentDate: Date().dayBefore) // yesterday
        counter.updateInstallDate(currentDate: Date().lastTwoWeek) // 2 weeks ago
        counter.updateInstallDate(currentDate: Date().older) // 20 days ago
        XCTAssertFalse(counter.hasRequiredDaysAfterInstall)
        XCTAssertEqual(counter.installDate, Date().dayBefore)
    }
    
    func testUpdateCounterAfter21Days_isTrue() {
        let fourtyDaysAgo = Date().older.older // 40 days
        counter.updateInstallDate(currentDate: fourtyDaysAgo)
        XCTAssertTrue(counter.hasRequiredDaysAfterInstall)
        XCTAssertEqual(counter.installDate, fourtyDaysAgo)
    }
    
    func testUpdateCounterOnDay21_isTrue() {
        let twentyOneDaysAgo = Date().older.dayBefore // 21 days
        counter.updateInstallDate(currentDate: twentyOneDaysAgo)
        XCTAssertTrue(counter.hasRequiredDaysAfterInstall)
        XCTAssertEqual(counter.installDate, twentyOneDaysAgo)
    }
    
}
