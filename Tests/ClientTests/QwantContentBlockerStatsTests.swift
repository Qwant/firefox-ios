// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
import Shared

@testable import Client

class QwantContentBlockerStatsTests: XCTestCase {
    
    let stats = QwantContentBlockerStats()
    
    override func setUp() {
        super.setUp()
        stats.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        stats.reset()
    }
    
    func testOnly30DaysOfStatsAreSaved() {
        (0...40).forEach { addDummyStat(minus: $0) }
        
        XCTAssertEqual(stats.rawStats.count, 30)
    }
    
    func testCountsAreCorrect() {
        // Today
        addDummyStat(domain: "domain-1.com", occurences: 10)
        addDummyStat(domain: "domain-2.com", occurences: 10)
        addDummyStat(domain: "domain-3.com", occurences: 10)
        // Yesterday
        addDummyStat(domain: "domain-99.com", occurences: 10, minus: 1)
        addDummyStat(domain: "domain-99.com", occurences: 10, minus: 1)
        // 2 days ago
        addDummyStat(domain: "domain-4.com", occurences: 10, minus: 2)
        // 3 days ago
        addDummyStat(domain: "domain-99.com", occurences: 10, minus: 3)
        // a long time ago
        addDummyStat(domain: "domain-00.com", occurences: 10, minus: 100)
        
        XCTAssertEqual(stats.rawStats.count, 4)
        XCTAssertEqual(stats.blockedTrackers.count, 5)
        XCTAssertEqual(stats.blockedTrackers["domain-1.com"], 10)
        XCTAssertEqual(stats.blockedTrackers["domain-2.com"], 10)
        XCTAssertEqual(stats.blockedTrackers["domain-3.com"], 10)
        XCTAssertEqual(stats.blockedTrackers["domain-4.com"], 10)
        XCTAssertEqual(stats.blockedTrackers["domain-99.com"], 30)
        XCTAssertEqual(stats.blockedTrackersCount, 70)
        
        XCTAssertEqual(stats.savedTime, 70*0.05)
    }
}

// MARK: Helpers
private extension QwantContentBlockerStatsTests {
    func addDummyStat(domain: String? = nil, occurences: Int = 1, for date: Date = Date(), minus days: Int = 0) {
        let domain = domain ?? "random-\(Int.random(in: 0...10)).com"
        let occurences = occurences <= 0 ? 1 : occurences
        let date = days <= 0 ? date : Calendar.current.add(numberOfDays: -days, to: date)!
        
        for _ in 0 ..< occurences {
            stats.appendStat(for: domain, at: date)
        }
    }
}
