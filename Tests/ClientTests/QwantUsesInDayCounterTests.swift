// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest

@testable import Client

class QwantUsesInDayCounterTests: XCTestCase {

    private var counter: QwantUsesInDayCounter!
    private var date: Date!
    
    override func setUp() {
        super.setUp()
        date = Date().noon
        counter = QwantUsesInDayCounter()
        counter.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        date = nil
        counter = nil
    }
    
    func testByDefaultCounter_isFalse() {
        XCTAssertFalse(counter.hasRequiredUsesInDay)
        XCTAssertNil(counter.usesOfDay)
    }
    
    func testUpdateCounterOnce_isFalse() {
        counter.updateCounter(currentDate: date)
        XCTAssertFalse(counter.hasRequiredUsesInDay)
        XCTAssertEqual(counter.usesOfDay?.first, date)
    }
    
    func testUpdateCounterLessThan6TimesTheSameDay_isFalse() {
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date.addingTimeInterval(1000))
        counter.updateCounter(currentDate: date.addingTimeInterval(2000))
        counter.updateCounter(currentDate: date.addingTimeInterval(3000))
        counter.updateCounter(currentDate: date.addingTimeInterval(4000))
        
        XCTAssertFalse(counter.hasRequiredUsesInDay)
        XCTAssertEqual(counter.usesOfDay?.first, date)
    }
    
    func testUpdateCounterMoreThan6TimesWithinSameWeek_isFalse() {
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        
        counter.updateCounter(currentDate: date.dayBefore)
        counter.updateCounter(currentDate: date.dayBefore)
        counter.updateCounter(currentDate: date.dayBefore)
        counter.updateCounter(currentDate: date.dayBefore)
        counter.updateCounter(currentDate: date.dayBefore)
        
        XCTAssertFalse(counter.hasRequiredUsesInDay)
        XCTAssertEqual(counter.usesOfDay?.first, date.dayBefore)
    }
    
    func testUpdateCounter6TimesSameDay_isTrue() {
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        
        XCTAssertTrue(counter.hasRequiredUsesInDay)
        XCTAssertEqual(counter.usesOfDay?.first, date)
    }
    
    func testUpdateCounterMoreThan6TimesSameDay_isTrue() {
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date)
        
        XCTAssertTrue(counter.hasRequiredUsesInDay)
        XCTAssertNil(counter.usesOfDay)
    }
    
    func testUpdateCounterMoreThan6TimesOncePerDay_isFalse() {
        counter.updateCounter(currentDate: date)
        counter.updateCounter(currentDate: date.dayAfter)
        counter.updateCounter(currentDate: date.dayAfter.dayAfter)
        counter.updateCounter(currentDate: date.dayAfter.dayAfter.dayAfter)
        counter.updateCounter(currentDate: date.dayAfter.dayAfter.dayAfter.dayAfter)
        counter.updateCounter(currentDate: date.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter)
        counter.updateCounter(currentDate: date.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter)
        counter.updateCounter(currentDate: date.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter)
        counter.updateCounter(currentDate: date.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter)
        
        XCTAssertFalse(counter.hasRequiredUsesInDay)
        XCTAssertEqual(counter.usesOfDay?.first, date.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter.dayAfter)
    }
}
