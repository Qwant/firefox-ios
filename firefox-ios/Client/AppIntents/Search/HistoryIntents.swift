// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.clearHistory)
struct ClearHistoryIntent: AppIntent {
    @Dependency(key: "TabManager")
    var tabManager: TabManager
    @Parameter
    var timeFrame: ClearHistoryTimeFrame

    func perform() async throws -> some IntentResult {
        enum ClearHistoryError: Error {
            case failedToClearHistory
        }

        let success = try await withCheckedThrowingContinuation { continuation in
            let profile = BrowserProfile(localName: "profile")
            profile.reopen()
            QwantZap(profile: profile, tabManager: tabManager).zap {
                continuation.resume(returning: true)
                profile.shutdown()
            }
        }

        if success {
            return .result()
        } else {
            throw ClearHistoryError.failedToClearHistory
        }
    }
}

@available(iOS 18.0, *)
@AssistantEnum(schema: .browser.clearHistoryTimeFrame)
enum ClearHistoryTimeFrame: AppEnum {
    typealias RawValue = Int
    var rawValue: Int { return 0 }
    init?(rawValue: Int) { self = .allTime }

    case allTime

    static var caseDisplayRepresentations: [ClearHistoryTimeFrame: DisplayRepresentation] = [
        .allTime: "All time",
    ]

//    static var typeDisplayName: LocalizedStringResource = "Clear History Timeframe"
}
