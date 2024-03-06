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
        static let CLIENT_CONTEXT_BROWSER = "qwantbrowser"
        static let CLIENT_CONTEXT_WIDGET = "qwantwidget"
        static let SEARCH_KEY = "q"
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
    var missesClientContext: Bool {
        guard self.isQwantUrl && !self.isMapsUrl else { return false }

        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return true
        }

        let hasOpenedAppViaTheWidget = UserDefaults.standard.hasOpenedAppViaTheWidget
        let contextExists = components.queryItems?.contains(where: { $0.name == Constants.CLIENT_CONTEXT_KEY }) ?? false

        return hasOpenedAppViaTheWidget || !contextExists
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
    /// Determines the context by checking first onto the user defaults to see if the client needs to have 
    /// the widget context or the browser context.
    /// Then re-applies all query items, and re-write the client one with the correct context
    ///
    /// - Returns: the generated URL out of the re-written components
    fileprivate func appendClientContext() -> URL? {
        guard self.isQwantUrl else { return self }

        let browserContext = Constants.CLIENT_CONTEXT_BROWSER
        let widgetContext = Constants.CLIENT_CONTEXT_WIDGET
        let context = UserDefaults.standard.hasOpenedAppViaTheWidget ? widgetContext : browserContext
        UserDefaults.standard.setHasOpenedAppViaTheWidget(false)

        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let queryItems = (components?.percentEncodedQueryItems ?? [])
            .filter { $0.name != Constants.CLIENT_CONTEXT_KEY }
        + [URLQueryItem(name: Constants.CLIENT_CONTEXT_KEY, value: context)]

        components?.queryItems = queryItems
        return components?.url
    }
}

public extension WKWebView {
    /// Relaunches the navigation in the webview by appending the context as a query parameter to the URL
    ///
    /// Stops the ongoing loading, and re-load an updated URL.
    func relaunchNavigationWithContext() {
        guard let url = self.url, let urlWithContext = url.appendClientContext() else {
            return
        }

        self.stopLoading()
        self.load(URLRequest(url: urlWithContext))
    }
}

public extension UserDefaults {
    private struct Constants {
        static let HAS_OPENED_APP_VIA_THE_WIDGET = "hasOpenedAppViaTheWidget"
    }

    var hasOpenedAppViaTheWidget: Bool {
        return bool(forKey: Constants.HAS_OPENED_APP_VIA_THE_WIDGET)
    }

    func setHasOpenedAppViaTheWidget(_ value: Bool) {
        setValue(value, forKey: Constants.HAS_OPENED_APP_VIA_THE_WIDGET)
    }
}

public extension String {
    var makeDoubleStarsTagsBoldAndRemoveThem: NSAttributedString? {
        // swiftlint:disable force_try
        let regex = try! NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
        // swiftlint:enable force_try
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

public extension Date {
    private var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? Date()
    }

    func isWithinLast30Days() -> Bool {
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
}
