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
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwantmaps.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwantjunior.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwa.qwant.com")!
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
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwantmaps.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwantjunior.com")!
        XCTAssertFalse(url.missesClientContext)
        
        url = URL(string: "https://www.qwa.qwant.com")!
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
        let url = URL(string: "https://www.qwant.com?q=wikipedia")!
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.load(request)
        
        XCTAssertTrue(webview.url!.missesClientContext)
        webview.relaunchNavigationWithContext()
        XCTAssertFalse(webview.url!.missesClientContext)
        XCTAssertTrue(webview.url!.absoluteString.contains("qwantwidget"))
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
