// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared
import XCTest
import WebKit

class QwantExtensionsTests: XCTestCase {
    
    override func tearDownWithError() throws {
        UserDefaults.standard.setHasOpenedAppViaTheWidget(false)
    }
    
    func testMissesClientContext_defaultCase() {
        var url = URL(string: "https://www.wikipedia.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.duckduckgo.com?q=qwant.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesClientContext)
        
        url = URL(string: "https://www.maps.qwant.com")!
        XCTAssertTrue(url.missesClientContext)
        
        url = URL(string: "https://www.qwantmaps.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com?q=wikipedia")!
        XCTAssertTrue(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com?q=wikipedia&client=qwantbrowser")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com?client=qwantwidget")!
        XCTAssertFalse(url.missesClientContext)
    }
    
    func testMissesClientContext_whenOpeningTheAppViaTheWidget() {
        UserDefaults.standard.setHasOpenedAppViaTheWidget(true)
        
        var url = URL(string: "https://www.wikipedia.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.duckduckgo.com?q=qwant.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com")!
        XCTAssertTrue(url.missesClientContext)
        
        url = URL(string: "https://www.maps.qwant.com")!
        XCTAssertTrue(url.missesClientContext)
        
        url = URL(string: "https://www.qwantmaps.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com?q=wikipedia")!
        XCTAssertTrue(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com?q=wikipedia&client=qwantbrowser")!
        XCTAssertTrue(url.missesClientContext)
        
        url = URL(string: "https://www.qwant.com?client=qwantwidget")!
        XCTAssertTrue(url.missesClientContext)
    }
    
    func testRelaunchNavigationWithClientContext_failingCase() {
        let url = URL(string: "https://www.duckduckgo.com?q=qwant.com")!
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.load(request)
        
        XCTAssertFalse(webview.url!.missesClientContext)
        webview.relaunchNavigationWithContext()
        XCTAssertFalse(webview.url!.missesClientContext)
        XCTAssertFalse(webview.url!.absoluteString.contains("qwantbrowser"))
    }
    
    func testRelaunchNavigationWithClientContext_defaultCase() {
        let url = URL(string: "https://www.qwant.com?q=wikipedia")!
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.load(request)
        
        XCTAssertTrue(webview.url!.missesClientContext)
        webview.relaunchNavigationWithContext()
        XCTAssertFalse(webview.url!.missesClientContext)
        XCTAssertTrue(webview.url!.absoluteString.contains("qwantbrowser"))
    }
    
    func testRelaunchNavigationWithClientContext_whenOpeningTheAppViaTheWidget() {
        UserDefaults.standard.setHasOpenedAppViaTheWidget(true)
        let url = URL(string: "https://www.maps.qwant.com?q=wikipedia")!
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.load(request)
        
        XCTAssertTrue(webview.url!.missesClientContext)
        webview.relaunchNavigationWithContext()
        XCTAssertFalse(webview.url!.missesClientContext)
        XCTAssertTrue(webview.url!.absoluteString.contains("qwantwidget"))
    }
}
