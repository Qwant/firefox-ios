// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

public extension URL {
    
    private struct Constants {
        static let QWANT_DOMAIN = "qwant.com"
        static let QWANT_JUNIOR_DOMAIN = "qwantjunior.com"
        static let QWANT_HELP_DOMAIN = "help.qwant.com"
        static let QWANT_MAPS_PATH = "/maps"
        static let CLIENT_CONTEXT_KEY = "client"
        static let CL_CONTEXT_KEY = "cl"
        static let CLIENT_CONTEXT_BROWSER = "qwantbrowser"
        static let CLIENT_CONTEXT_WIDGET = "qwantwidget"
        static let SEARCH_KEY = "q"
    }

    var isQwantHPUrl: Bool {
        return isQwantUrl && !isMapsUrl && (qwantSearchTerm == nil || qwantSearchTerm?.isEmptyOrWhitespace() == true)
    }

    var isQwantSERPUrl: Bool {
        return isQwantUrl && !isMapsUrl && qwantSearchTerm?.isEmptyOrWhitespace() == false
    }
    
    var isQwantUrl: Bool {
        return self.normalizedHost == Constants.QWANT_DOMAIN
    }
    
    var isQwantJuniorUrl: Bool {
        return self.normalizedHost == Constants.QWANT_JUNIOR_DOMAIN
    }
    
    var isQwantHelpUrl: Bool {
        return self.normalizedHost == Constants.QWANT_HELP_DOMAIN
    }
    
    var isMapsUrl: Bool {
        return self.isQwantUrl && self.path.starts(with: Constants.QWANT_MAPS_PATH)
    }
    
    var isAnyQwantUrl: Bool {
        return self.isQwantUrl || self.isQwantJuniorUrl || self.isQwantHelpUrl
    }
    
    /// Determines if the `client` context is missing as a query parameter of the URL.
    ///
    /// There are 2 cases to distinguish, the first one where the client context is actually really missing from the url
    /// as in `https://www.qwant.com?q=wikipedia` for example, but also when we can read through the
    /// user defaults that the app has been opened via the widget, and thus that we must override the default
    /// `qwantbrowser`with the `qwantwidget` in that case.
    func missesQwantContext(prefs: Prefs) -> Bool {
        extractQwantClIfNeeded(prefs: prefs)

        guard self.isQwantUrl && !self.isMapsUrl else { return false }
        
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return true
        }

        // Client
        let clientQueryParam = components.queryItems?.first(where: { $0.name == Constants.CLIENT_CONTEXT_KEY })
        let clientQueryValue = clientQueryParam?.value ?? ""

        // Widget
        let openedViaWidget = prefs.boolForKey(PrefsKeys.QwantHasBeenOpenedViaTheWidget) ?? false
        let clientIsNotWidget = clientQueryValue != Constants.CLIENT_CONTEXT_WIDGET

        // Cl
        let clQueryParam = components.queryItems?.first(where: { $0.name == Constants.CL_CONTEXT_KEY })
        let clPrefsValue = prefs.stringForKey(PrefsKeys.QwantCampaign) ?? ""
        let clDiffersFromPrefs = clQueryParam?.value != clPrefsValue

        // Conditions
        let clientNotThere = clientQueryParam == nil
        let clientIsEmpty = clientQueryValue.isEmpty
        let needsClientContext = clientNotThere || clientIsEmpty
        let needsWidgetContext = openedViaWidget && clientIsNotWidget
        let needsClContext = !clPrefsValue.isEmpty && clDiffersFromPrefs

        return needsClientContext || needsWidgetContext || needsClContext
    }
    
    var qwantSearchTerm: String? {
        guard self.isQwantUrl && !self.isMapsUrl else { return nil }
        
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        
        let nonNilSearchQueryExists: ((URLQueryItem) -> Bool) = { item in
            return item.name == Constants.SEARCH_KEY && item.value != nil
        }
        
        return components.queryItems?.first(where: nonNilSearchQueryExists)?
            .value?
            .replacingOccurrences(of: " ", with: "+")
    }
    
    /// Appends the client context as a query parameter to the URL, ensuring the URL is valid beforehand.
    ///
    /// Determines the context by checking first onto the user defaults to see if the client needs to have the widget context or the browser context.
    /// Then re-applies all query items, and re-write the client one with the correct context
    ///
    /// - Returns: the generated URL out of the re-written components
    fileprivate func appendQwantContext(prefs: Prefs) -> URL? {
        guard self.isQwantUrl else { return self }

        let hasOpenedAppViaTheWidget = prefs.boolForKey(PrefsKeys.QwantHasBeenOpenedViaTheWidget) ?? false
        let context = hasOpenedAppViaTheWidget ? Constants.CLIENT_CONTEXT_WIDGET : Constants.CLIENT_CONTEXT_BROWSER
        prefs.setBool(false, forKey: PrefsKeys.QwantHasBeenOpenedViaTheWidget)

        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        var queryItems = (components?.queryItems ?? [])
            .filter { $0.name != Constants.CLIENT_CONTEXT_KEY }
            + [URLQueryItem(name: Constants.CLIENT_CONTEXT_KEY, value: context)]

        let cl = prefs.stringForKey(PrefsKeys.QwantCampaign)
        if cl?.isEmpty == false {
            queryItems = queryItems
                .filter { $0.name != Constants.CL_CONTEXT_KEY }
            + [URLQueryItem(name: Constants.CL_CONTEXT_KEY, value: cl)]
        }

        components?.queryItems = queryItems
        return components?.url
    }

    fileprivate func extractQwantClIfNeeded(prefs: Prefs) {
        // Ensure there isn't already a cl stored in the prefs
        guard prefs.stringForKey(PrefsKeys.QwantCampaign) == nil else { return }

        // Ensure it's the first run
        guard prefs.boolForKey(PrefsKeys.QwantIsFirstRun) == true else { return }

        // Ensure it's a qwant.com url
        guard self.isQwantUrl && !self.isMapsUrl else { return }

        // Ensure there are query items
        guard let items = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems else { return }

        // Ensure cl query params exists and is not empty
        guard let clParam = items.first(where: { $0.name == Constants.CL_CONTEXT_KEY }),
              let clValue = clParam.value, !clValue.isEmpty else { return }

        // Finally save the value and the associated timestamp onto the prefs
        prefs.setString(clValue, forKey: PrefsKeys.QwantCampaign)
        prefs.setLong(Date().toTimestamp(), forKey: PrefsKeys.QwantCampaignTimestamp)
        prefs.setBool(false, forKey: PrefsKeys.QwantIsFirstRun)
    }
}

public extension WKWebView {
    
    /// Relaunches the navigation in the webview by appending the context as a query parameter to the URL
    ///
    /// Stops the ongoing loading, and re-load an updated URL.
    func relaunchNavigationWithContext(prefs: Prefs) {
        guard let url = self.url, let urlWithContext = url.appendQwantContext(prefs: prefs) else {
            return
        }

        print("[QWANT] reloading with \(urlWithContext)")
        
        self.stopLoading()
        self.load(URLRequest(url: urlWithContext))
    }

    func setQwantCookies() {

        let omnibarCookie = HTTPCookie(properties: [
            .domain: "www.qwant.com",
            .path: "/",
            .name: "omnibar",
            .value: "1",
            .secure: "FALSE",
            .expires: NSDate(timeIntervalSinceNow: 31_556_926)
        ])!

        configuration.websiteDataStore.httpCookieStore.setCookie(omnibarCookie)
    }
}

extension Date {
    
    public func isWithinLast30Days() -> Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -29, to: Date().noon) ?? Date()
        return (thirtyDaysAgo ... Date().noon).contains(self)
    }
}

public extension UIView {
    
    func increaseAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.1
        animation.values = [3.0, 0.0]
        layer.add(animation, forKey: "increaseAnimation")
    }

    func shouldUseiPadSetup(traitCollection: UITraitCollection? = nil) -> Bool {
        let trait = traitCollection == nil ? self.traitCollection : traitCollection
        if UIDevice.current.userInterfaceIdiom == .pad {
            return trait!.horizontalSizeClass != .compact
        }

        return false
    }
}
    
public extension String {

    var makeDoubleStarsTagsBoldAndRemoveThem: NSAttributedString? {
        let regex = try! NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
        let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        
        let cleanedString = self.replacingOccurrences(of: "**", with: "")
        let attributedStr = NSMutableAttributedString(string: cleanedString)
        for i in 0 ..< results.count {
            let result = results[i]
            let cleanedRange = NSRange(location: result.range.location - (4 * i), length: result.range.length - 4)
            attributedStr.addAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .bold)], range: cleanedRange)
        }
        return attributedStr
    }
}
