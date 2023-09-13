// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared

class QwantDailyContentBlockerStats: Codable {
    let date: Date
    var stats: [String: Int]
    
    init() {
        self.date = Date().noon
        self.stats = [:]
    }
    
    init(domain: String, date: Date = Date()) {
        self.date = date.noon
        self.stats = [domain : 1]
    }
    
    var blockedTrackersCount: Int {
        return self.stats.reduce(0) { $0 + $1.value }
    }
    
    var savedTime: TimeInterval {
        return Double(self.blockedTrackersCount) * 0.05
    }
}

class QwantContentBlockerStats {
    
    private let statsUserDefaultsKey = "QwantContentBlockerStats.RawStats"
    
    private(set) var rawStats: [QwantDailyContentBlockerStats] {
        get {
            return (UserDefaults.standard.object(forKey: statsUserDefaultsKey) as? [Data])?
                .compactMap { try? JSONDecoder().decode(QwantDailyContentBlockerStats.self, from: $0) } ?? []
        }
        
        set {
            UserDefaults.standard.set(newValue.compactMap { try? JSONEncoder().encode($0) }, forKey: statsUserDefaultsKey)
        }
    }
    
    func appendStat(for domain: String, at date: Date = Date()) {
        if let idx = rawStats.firstIndex(where: { $0.date == date.noon }) {
            let stat = rawStats[idx]
            if let count = stat.stats[domain] {
                stat.stats[domain] = count + 1
            } else {
                stat.stats[domain] = 1
            }
            rawStats[idx] = stat
        } else {
            rawStats.append(QwantDailyContentBlockerStats(domain: domain, date: date))
        }
        rawStats = rawStats.filter { $0.date.isWithinLast30Days() }
    }
    
    func reset() {
        rawStats = []
    }
    
    var blockedTrackers: [String: Int] {
        var totalBlockedTrackers: [String: Int] = [:]
        rawStats.compactMap { $0.stats }.forEach { stat in
            stat.forEach {
                if totalBlockedTrackers[$0.key] != nil {
                    totalBlockedTrackers[$0.key]! += $0.value
                } else {
                    totalBlockedTrackers[$0.key] = $0.value
                }
            }
        }
        return totalBlockedTrackers
    }
    
    var blockedTrackersCount: Int {
        return rawStats.compactMap { $0.blockedTrackersCount }.reduce(0, +)
    }
    
    var savedTime: TimeInterval {
        return rawStats.compactMap { $0.savedTime }.reduce(0, +)
    }
}
