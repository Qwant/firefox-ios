// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared
import XCTest
import WebKit
@testable import Client

class QwantExtensionsTests: XCTestCase {

    var expectation: XCTestExpectation?
    var mockPrefs: MockProfilePrefs!
    var url: URL!

    override func setUpWithError() throws {
        mockPrefs = MockProfilePrefs()
    }

    override func tearDownWithError() throws {
        expectation = nil
        mockPrefs = nil
    }

    func testMissesQwantContext_failingCases() {
        url = URL(string: "https://www.wikipedia.com")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.maps.qwant.com")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwantmaps.com")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwantjunior.com")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwa.qwant.com")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))
    }

    func testMissesQwantContext_clientCases_qwantbrowser() {
        mockPrefs.setBool(false, forKey: PrefsKeys.QwantHasBeenOpenedViaTheWidget)

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantwidget")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantrandom")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        // &cl cases
        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))
    }

    func testMissesQwantContext_clientCases_qwantwidget() {
        mockPrefs.setBool(true, forKey: PrefsKeys.QwantHasBeenOpenedViaTheWidget)

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantwidget")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantrandom")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        // &cl cases
        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))
    }

    func testMissesQwantContext_firstRun() {
        // first run
        mockPrefs.setBool(true, forKey: PrefsKeys.QwantIsFirstRun)

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm&fs=1")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        // not first run
        mockPrefs.setBool(false, forKey: PrefsKeys.QwantIsFirstRun)
        mockPrefs.setObject(nil, forKey: PrefsKeys.QwantCampaign)

        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=utm&fs=1")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))
    }

    func testMissesQwantContext_clCases() {
        // nil case
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        // empty case
        mockPrefs.setString("", forKey: PrefsKeys.QwantCampaign)
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        // value case
        mockPrefs.setString("random_utm", forKey: PrefsKeys.QwantCampaign)
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))

        // &client=qwantwidget cases
        mockPrefs.setBool(true, forKey: PrefsKeys.QwantHasBeenOpenedViaTheWidget)
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantbrowser&cl=random_utm")!
        XCTAssertTrue(url.missesQwantContext(prefs: mockPrefs))

        url = URL(string: "https://www.qwant.com?client=qwantwidget&cl=random_utm")!
        XCTAssertFalse(url.missesQwantContext(prefs: mockPrefs))
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
        mockPrefs.setString("random_utm", forKey: PrefsKeys.QwantCampaign)
        let webview = createAndLoadWebview(with: "https://www.duckduckgo.com?q=qwant.com")

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl="))
        XCTAssertFalse(webview.url!.absoluteString.contains("client="))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        // No need to wait as nothing is going to be reloaded

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl="))
        XCTAssertFalse(webview.url!.absoluteString.contains("client="))
    }

    func testRelaunchNavigationWithQwantContext_isFirstRun() {
        mockPrefs.setBool(true, forKey: PrefsKeys.QwantIsFirstRun)
        let webview = createAndLoadWebview(with: "https://www.qwant.com")

        XCTAssertTrue(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("fs=1"))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("fs=1"))
    }

    func testRelaunchNavigationWithQwantContext_isFirstRun_savingCl() {
        mockPrefs.setBool(true, forKey: PrefsKeys.QwantIsFirstRun)
        let webview = createAndLoadWebview(with: "https://www.qwant.com?cl=12345&fs=1")

        XCTAssertTrue(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("fs=1"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("fs=1"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))
        XCTAssertEqual("12345", mockPrefs.stringForKey(PrefsKeys.QwantCampaign))
        XCTAssertFalse(mockPrefs.boolForKey(PrefsKeys.QwantIsFirstRun)!)
    }

    func testRelaunchNavigationWithQwantContext_realCl() {
        mockPrefs.setString("12345", forKey: PrefsKeys.QwantCampaign)
        let webview = createAndLoadWebview(with: "https://www.qwant.com?client=qwantbrowser&cl=12345")

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        // No need to wait as nothing is going to be reloaded

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))
    }

    func testRelaunchNavigationWithQwantContext_overriddenCl() {
        mockPrefs.setString("12345", forKey: PrefsKeys.QwantCampaign)
        let webview = createAndLoadWebview(with: "https://www.qwant.com?client=qwantbrowser&cl=67890")

        XCTAssertTrue(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=67890"))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=12345"))
    }

    func testRelaunchNavigationWithQwantContext_addingClient_qwantbrowser() {
        let webview = createAndLoadWebview(with: "https://www.qwant.com")

        XCTAssertTrue(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
    }

    func testRelaunchNavigationWithQwantContext_addingClient_qwantwidget() {
        mockPrefs.setBool(true, forKey: PrefsKeys.QwantHasBeenOpenedViaTheWidget)

        let webview = createAndLoadWebview(with: "https://www.qwant.com?q=wikipedia&cl=random_utm")

        XCTAssertTrue(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantwidget"))
        XCTAssertTrue(webview.url!.absoluteString.contains("q=wikipedia"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=random_utm"))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantwidget"))
        XCTAssertTrue(webview.url!.absoluteString.contains("q=wikipedia"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=random_utm"))
    }

    func testRelaunchNavigationWithQwantContext_addingCl_qwantbrowser() {
        mockPrefs.setString("random_utm", forKey: PrefsKeys.QwantCampaign)

        let webview = createAndLoadWebview(with: "https://www.qwant.com")

        XCTAssertTrue(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl=random_utm"))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertTrue(webview.url!.absoluteString.contains("cl=random_utm"))
    }

    func testRelaunchNavigationWithQwantContext_notAddingCl_qwantwidget() {
        mockPrefs.setString("", forKey: PrefsKeys.QwantCampaign)
        mockPrefs.setBool(true, forKey: PrefsKeys.QwantHasBeenOpenedViaTheWidget)

        let webview = createAndLoadWebview(with: "https://www.qwant.com?q=wikipedia&client=qwantbrowser")

        XCTAssertTrue(webview.url!.missesQwantContext(prefs: mockPrefs))
        XCTAssertTrue(webview.url!.absoluteString.contains("client=qwantbrowser"))
        XCTAssertFalse(webview.url!.absoluteString.contains("client=qwantwidget"))
        XCTAssertFalse(webview.url!.absoluteString.contains("cl="))

        webview.relaunchNavigationWithContext(prefs: mockPrefs)
        expectation = self.expectation(description: "WebView did finish loading, and qwantbrowser query param exist")
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertFalse(webview.url!.missesQwantContext(prefs: mockPrefs))
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

    func testIsQwantMapsUrl() {
        XCTAssertTrue(URL(string: "https://www.qwant.com/maps/")!.isMapsUrl)
        XCTAssertTrue(URL(string: "https://www.qwant.com/maps/maps")!.isMapsUrl)

        XCTAssertFalse(URL(string: "https://www.qwa.qwant.com/maps")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.plive/")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwa.qwant.com/")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwant.com/?q=test&client=qwantbrowser")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwnt.com")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.wikipedia.com")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.help.qwant.com/")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.help.qwant.com/maps/")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.help.qwant.com/?q=test&client=qwantbrowser")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwantjunior.com/")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwantjunior.com/maps/")!.isMapsUrl)
        XCTAssertFalse(URL(string: "https://www.qwantjunior.com/?q=test&client=qwantbrowser")!.isMapsUrl)
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
