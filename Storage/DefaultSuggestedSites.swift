// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

open class DefaultSuggestedSites {
    public static let urlMap = [
        "https://www.amazon.com/": [
            "as": "https://www.amazon.in",
            "cy": "https://www.amazon.co.uk",
            "da": "https://www.amazon.co.uk",
            "de": "https://www.amazon.de",
            "dsb": "https://www.amazon.de",
            "en_GB": "https://www.amazon.co.uk",
            "et": "https://www.amazon.co.uk",
            "ff": "https://www.amazon.fr",
            "ga_IE": "https://www.amazon.co.uk",
            "gu_IN": "https://www.amazon.in",
            "hi_IN": "https://www.amazon.in",
            "hr": "https://www.amazon.co.uk",
            "hsb": "https://www.amazon.de",
            "ja": "https://www.amazon.co.jp",
            "kn": "https://www.amazon.in",
            "mr": "https://www.amazon.in",
            "or": "https://www.amazon.in",
            "sq": "https://www.amazon.co.uk",
            "ta": "https://www.amazon.in",
            "te": "https://www.amazon.in",
            "ur": "https://www.amazon.in",
            "en_CA": "https://www.amazon.ca",
            "fr_CA": "https://www.amazon.ca"
        ]
    ]

    public static let sites = [
        "default": [
            SuggestedSiteData(
                url: "https://www.qwant.com/maps",
                bgColor: "",
                imageUrl: "",
                faviconUrl: "",
                trackingId: 1,
                title: "Qwant Maps"
            ),
            SuggestedSiteData(
                url: "http://www.qwantjunior.com",
                bgColor: "",
                imageUrl: "",
                faviconUrl: "",
                trackingId: 2,
                title: "Qwant Junior"
            ),
            SuggestedSiteData(
                url: "https://help.qwant.com/en/docs/qwant-mobile",
                bgColor: "",
                imageUrl: "",
                faviconUrl: "",
                trackingId: 3,
                title: "Qwant Help"
            )
        ]
    ]
}
