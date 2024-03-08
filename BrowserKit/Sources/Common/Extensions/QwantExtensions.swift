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
        static let QWANT_ANTISCRAP_PATH = "/antiscrap"
        static let CLIENT_CONTEXT_KEY = "client"
        static let CLIENT_CONTEXT_BROWSER = "qwantbrowser"
        static let CLIENT_CONTEXT_WIDGET = "qwantwidget"
        static let CL_CONTEXT_KEY = "cl"
        static let SEARCH_KEY = "q"
    }

    var isQwantUrl: Bool {
        return self.normalizedHost == Constants.QWANT_DOMAIN
    }

    var isAntiscrapUrl: Bool {
        return self.isQwantUrl && self.path.starts(with: Constants.QWANT_ANTISCRAP_PATH)
    }

    var isQwantJuniorUrl: Bool {
        return self.normalizedHost == Constants.QWANT_JUNIOR_DOMAIN
    }

    var isQwantHelpUrl: Bool {
        return self.normalizedHost == Constants.QWANT_HELP_DOMAIN
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
    func missesQwantContext(hasOpenedAppViaTheWidget: Bool?,
                            campaign: String?,
                            isFirstRun: Bool?,
                            completion: ((String) -> Void)?) -> Bool {
        extractQwantClIfNeeded(campaign: campaign,
                               isFirstRun: isFirstRun,
                               completion: completion)

        guard self.isQwantUrl && !self.isAntiscrapUrl else { return false }

        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return true
        }

        // Client
        let clientQueryParam = components.queryItems?.first(where: { $0.name == Constants.CLIENT_CONTEXT_KEY })
        let clientQueryValue = clientQueryParam?.value ?? ""

        // Widget
        let openedViaWidget = hasOpenedAppViaTheWidget ?? false
        let clientIsNotWidget = clientQueryValue != Constants.CLIENT_CONTEXT_WIDGET

        // Cl
        let clQueryParam = components.queryItems?.first(where: { $0.name == Constants.CL_CONTEXT_KEY })
        let clPrefsValue = campaign ?? ""
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
        guard self.isQwantUrl && !self.isAntiscrapUrl else { return nil }

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
    fileprivate func appendQwantContext(hasOpenedAppViaTheWidget: Bool?,
                                        campaign: String?) -> URL? {
        guard self.isQwantUrl else { return self }

        let browserContext = Constants.CLIENT_CONTEXT_BROWSER
        let widgetContext = Constants.CLIENT_CONTEXT_WIDGET
        let context = hasOpenedAppViaTheWidget == true ? widgetContext : browserContext

        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        var queryItems = (components?.queryItems ?? [])
            .filter { $0.name != Constants.CLIENT_CONTEXT_KEY }
        + [URLQueryItem(name: Constants.CLIENT_CONTEXT_KEY, value: context)]

        if campaign?.isEmpty == false {
            queryItems = queryItems
                .filter { $0.name != Constants.CL_CONTEXT_KEY }
            + [URLQueryItem(name: Constants.CL_CONTEXT_KEY, value: campaign)]
        }

        components?.queryItems = queryItems
        return components?.url
    }

    fileprivate func extractQwantClIfNeeded(campaign: String?,
                                            isFirstRun: Bool?,
                                            completion: ((String) -> Void)?) {
        // Ensure there isn't already a cl stored in the prefs
        guard campaign == nil else { return }

        // Ensure it's the first run
        guard isFirstRun == true else { return }

        // Ensure it's a qwant.com url
        guard self.isQwantUrl && !self.isAntiscrapUrl else { return }

        // Ensure there are query items
        guard let items = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems else { return }

        // Ensure cl query params exists and is not empty
        guard let clParam = items.first(where: { $0.name == Constants.CL_CONTEXT_KEY }),
              let clValue = clParam.value, !clValue.isEmpty else { return }

        // Finally save the value and the associated timestamp onto the prefs
        completion?(clValue)
    }
}

public extension WKWebView {
    /// Relaunches the navigation in the webview by appending the context as a query parameter to the URL
    ///
    /// Stops the ongoing loading, and re-load an updated URL.
    func relaunchNavigationWithContext(hasOpenedAppViaTheWidget: Bool?,
                                       campaign: String?) {
        guard let url = self.url,
                let urlWithContext = url.appendQwantContext(
                    hasOpenedAppViaTheWidget: hasOpenedAppViaTheWidget,
                    campaign: campaign)
        else { return }

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
