// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared
import XCTest

class SupportUtilsTests: XCTestCase {
    func testURLForTopic() {
        XCTAssertEqual(SupportUtils.URLForTopic("Bacon")?.absoluteString, "https://0.0.0.0/ShouldBeReplaced/Bacon")
        XCTAssertEqual(SupportUtils.URLForTopic("Cheese & Crackers")?.absoluteString, "https://0.0.0.0/ShouldBeReplaced/Cheese%20&%20Crackers")
        XCTAssertEqual(SupportUtils.URLForTopic("Möbelträgerfüße")?.absoluteString, "https://0.0.0.0/ShouldBeReplaced/M%C3%B6beltr%C3%A4gerf%C3%BC%C3%9Fe")
    }

    func testURLForWhatsNew() {
        XCTAssertEqual(SupportUtils.URLForWhatsNew?.absoluteString, "https://www.mozilla.org/en-US/firefox/ios/notes/")
    }
}
