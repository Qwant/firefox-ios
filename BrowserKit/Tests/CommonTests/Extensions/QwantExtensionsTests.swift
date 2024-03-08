// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
import WebKit
@testable import Common

class QwantExtensionsTests: XCTestCase {
    var expectation: XCTestExpectation?
    var hasOpenedAppViaTheWidget: Bool?
    var campaign: String?
    var isFirstRun: Bool?
    var completion: ((String) -> Void)?
    var url: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        hasOpenedAppViaTheWidget = false
        campaign = nil
        isFirstRun = false
        completion = { [weak self] clValue in
            self?.campaign = clValue
            self?.isFirstRun = false
        }
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        expectation = nil
        hasOpenedAppViaTheWidget = nil
        campaign = nil
        isFirstRun = nil
        completion = nil
    }

    func testMissesQwantContext_failingCases() {
        url = URL(string: "https://www.wikipedia.com")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.maps.qwant.com")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwantmaps.com")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwantjunior.com")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwa.qwant.com")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))
    }

    func testMissesQwantContext_clientCases_qwantbrowser() {
        hasOpenedAppViaTheWidget = false
        campaign = nil
        isFirstRun = false

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantwidget")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantrandom")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        // &cl cases
        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))
    }

    func testMissesQwantContext_clientCases_qwantwidget() {
        hasOpenedAppViaTheWidget = true

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantwidget")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantrandom")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        // &cl cases
        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))
    }

    func testMissesQwantContext_firstRun() {
        // first run
        isFirstRun = true

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm&fs=1")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        // not first run
        campaign = nil
        isFirstRun = false

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm&fs=1")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))
    }

    func testMissesQwantContext_clCases() {
        // nil case
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        // empty case
        campaign = ""
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        // value case
        campaign = "random_utm"
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))

        // &client=qwantwidget cases
        hasOpenedAppViaTheWidget = true
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertTrue(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                             campaign: campaign,
                                             isFirstRun: isFirstRun,
                                             completion: completion))

        url = URL(string: "https://www.qwant.com?client=qwantwidget&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign,
                                              isFirstRun: isFirstRun,
                                              completion: completion))
    }

    private func createAndLoadWebview(with urlString: String) -> WKWebView {
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.navigationDelegate = self
        webview.load(request)
        return webview
    }

    func testRelaunchNavigationWithQwantContext_failingCase() {
        campaign = "random_utm"
        let webview = createAndLoadWebview(with: "https://www.duckduckgo.com?q=qwant.com")

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl="))
        XCTAssertFalse(webview.url!.absoluteString.contains("client="))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        // No need to wait as nothing is going to be reloaded

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl="))
        XCTAssertFalse(webview.url!.absoluteString.contains("client="))
    }

    func testRelaunchNavigationWithQwantContext_isFirstRun() {
        isFirstRun = true
        let webview = createAndLoadWebview(with: "https://www.qwant.com")

        XCTAssertTrue(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                      campaign: campaign,
                                                      isFirstRun: isFirstRun,
                                                      completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("fs=1"))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("fs=1"))
    }

    func testRelaunchNavigationWithQwantContext_isFirstRun_savingCl() {
        isFirstRun = true
        let webview = createAndLoadWebview(with: "https://www.qwant.com?cl=12345&fs=1")

        XCTAssertTrue(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                      campaign: campaign,
                                                      isFirstRun: isFirstRun,
                                                      completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("fs=1"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("fs=1"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))
    }

    func testRelaunchNavigationWithQwantContext_realCl() {
        campaign = "12345"
        let webview = createAndLoadWebview(with: "https://www.qwant.com?client=qwantbrowser&cl=12345")

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        // No need to wait as nothing is going to be reloaded

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))
    }

    func testRelaunchNavigationWithQwantContext_overriddenCl() {
        campaign = "12345"
        let webview = createAndLoadWebview(with: "https://www.qwant.com?client=qwantbrowser&cl=67890")

        XCTAssertTrue(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                      campaign: campaign,
                                                      isFirstRun: isFirstRun,
                                                      completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=67890"))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))
    }

    func testRelaunchNavigationWithQwantContext_addingClient_qwantbrowser() {
        let webview = createAndLoadWebview(with: "https://www.qwant.com")

        XCTAssertTrue(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                      campaign: campaign,
                                                      isFirstRun: isFirstRun,
                                                      completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
    }

    func testRelaunchNavigationWithQwantContext_addingClient_qwantwidget() {
        hasOpenedAppViaTheWidget = true

        let webview = createAndLoadWebview(with: "https://www.qwant.com?q=wikipedia&cl=random_utm")

        XCTAssertTrue(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                      campaign: campaign,
                                                      isFirstRun: isFirstRun,
                                                      completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantwidget"))
        XCTAssertTrue(webview.url!.absoluteString.contains("q=wikipedia"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=random_utm"))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantwidget"))
        XCTAssertTrue(webview.url!.absoluteString.contains("q=wikipedia"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=random_utm"))
    }

    func testRelaunchNavigationWithQwantContext_addingCl_qwantbrowser() {
        campaign = "random_utm"

        let webview = createAndLoadWebview(with: "https://www.qwant.com")

        XCTAssertTrue(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                      campaign: campaign,
                                                      isFirstRun: isFirstRun,
                                                      completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl=random_utm"))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=random_utm"))
    }

    func testRelaunchNavigationWithQwantContext_notAddingCl_qwantwidget() {
        hasOpenedAppViaTheWidget = true
        campaign = ""

        let webview = createAndLoadWebview(with: "https://www.qwant.com?q=wikipedia&client=qwantbrowser")

        XCTAssertTrue(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                      campaign: campaign,
                                                      isFirstRun: isFirstRun,
                                                      completion: completion))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantwidget"))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl="))

        webview.relaunchNavigationWithContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                              campaign: campaign)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                                                       campaign: campaign,
                                                       isFirstRun: isFirstRun,
                                                       completion: completion))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantwidget"))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl="))
    }

    func testIsQwantUrl() {
        XCTAssertTrue(URL(string: "https://www.qwant.com/")!.isQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwant.com/maps/")!.isQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwant.com/?q=test&client=qwantbrowser")!.isQwantUrl)

        XCTAssertFalse(URL(string: "https://www.qwa.qwant.com/")!.isQwantUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.plive/")!.isQwantUrl)
        XCTAssertFalse(URL(string: "https://www.qwnt.com")!.isQwantUrl)
        XCTAssertFalse(URL(string: "https://www.wikipedia.com")!.isQwantUrl)
    }

    func testIsQwantJuniorUrl() {
        XCTAssertTrue(URL(string: "https://www.qwantjunior.com/")!.isQwantJuniorUrl)
        XCTAssertTrue(URL(string: "https://www.qwantjunior.com/maps/")!.isQwantJuniorUrl)
        XCTAssertTrue(URL(string: "https://www.qwantjunior.com/?q=test&client=qwantbrowser")!.isQwantJuniorUrl)

        XCTAssertFalse(URL(string: "https://www.qwa.qwant.com/")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.plive/")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/maps/")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/?q=test&client=qwantbrowser")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwnt.com")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.wikipedia.com")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.help.qwant.com/")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.help.qwant.com/maps/")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.help.qwant.com/?q=test&client=qwantbrowser")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/maps/")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/maps/maps")!.isQwantJuniorUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/MAPS")!.isQwantJuniorUrl)
    }

    func testIsQwantHelpUrl() {
        XCTAssertTrue(URL(string: "https://www.help.qwant.com/")!.isQwantHelpUrl)
        XCTAssertTrue(URL(string: "https://www.help.qwant.com/maps/")!.isQwantHelpUrl)
        XCTAssertTrue(URL(string: "https://www.help.qwant.com/?q=test&client=qwantbrowser")!.isQwantHelpUrl)

        XCTAssertFalse(URL(string: "https://www.qwa.qwant.com/")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.plive/")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/maps/")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/?q=test&client=qwantbrowser")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwnt.com")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.wikipedia.com")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwantjunior.com/")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwantjunior.com/maps/")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwantjunior.com/?q=test&client=qwantbrowser")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/maps/")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/maps/maps")!.isQwantHelpUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/MAPS")!.isQwantHelpUrl)
    }

    func testIsAnyQwantUrl() {
        XCTAssertTrue(URL(string: "https://www.qwant.com/maps/")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwant.com/maps/maps")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwant.com/MAPS")!.isAnyQwantUrl)
        XCTAssertFalse(URL(string: "https://www.qwa.qwant.com/maps")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwant.com/")!.isAnyQwantUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.plive/")!.isAnyQwantUrl)
        XCTAssertFalse(URL(string: "https://www.qwa.qwant.com/")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwant.com/?q=test&client=qwantbrowser")!.isAnyQwantUrl)
        XCTAssertFalse(URL(string: "https://www.qwnt.com")!.isAnyQwantUrl)
        XCTAssertFalse(URL(string: "https://www.wikipedia.com")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.help.qwant.com/")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.help.qwant.com/maps/")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.help.qwant.com/?q=test&client=qwantbrowser")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwantjunior.com/")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwantjunior.com/maps/")!.isAnyQwantUrl)
        XCTAssertTrue(URL(string: "https://www.qwantjunior.com/?q=test&client=qwantbrowser")!.isAnyQwantUrl)
    }

    func testQwantSearchTerm() {
        // Correct domain
        XCTAssertNil(URL(string: "https://www.qwant.com")!.qwantSearchTerm)
        XCTAssertEqual(URL(string: "https://www.qwant.com/?q=search")!.qwantSearchTerm, "search")
        XCTAssertEqual(URL(string: "https://www.qwant.com/?q=search+1")!.qwantSearchTerm, "search+1")
        XCTAssertEqual(URL(string: "https://www.qwant.com/?q=search%201")!.qwantSearchTerm, "search+1")
        XCTAssertEqual(URL(string: "https://www.qwant.com/?q=&client=qwantbrowser")!.qwantSearchTerm, "")

        XCTAssertNil(URL(string: "https://www.qwant.com/maps/")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwant.com/maps/?q=search")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwant.com/maps/?q=search+1")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwant.com/maps/?q=search%201")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwant.com/maps/?q=&client=qwantbrowser")!.qwantSearchTerm)

        // Incorrect domain
        XCTAssertNil(URL(string: "https://www.qwa.qwant.com/")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwantjunior.com/")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwnt.com/")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.wikipedia.com/")!.qwantSearchTerm)

        XCTAssertNil(URL(string: "https://www.qwa.qwant.com/?q=search")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwantjunior.com/?q=search")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwnt.com/?q=search")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.wikipedia.com/?q=search")!.qwantSearchTerm)

        XCTAssertNil(URL(string: "https://www.qwa.qwant.com/?q=&client=qwantbrowser")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwantjunior.com/?q=&client=qwantbrowser")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.qwnt.com/?q=&client=qwantbrowser")!.qwantSearchTerm)
        XCTAssertNil(URL(string: "https://www.wikipedia.com/?q=&client=qwantbrowser")!.qwantSearchTerm)
    }
}

extension QwantExtensionsTests: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        expectation?.fulfill()
    }
}
