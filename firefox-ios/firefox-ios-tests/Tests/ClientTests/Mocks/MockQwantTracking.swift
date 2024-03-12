// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
@testable import Client

class MockQwantTracking: QwantTracking {
    var trackedScreenViews = 0
    var trackedEvents = 0

    override func track(_ screenView: QwantTrackingScreenView) {
        trackedScreenViews += 1
    }

    override func track(_ event: QwantTrackingEvent) {
        trackedEvents += 1
    }
}
