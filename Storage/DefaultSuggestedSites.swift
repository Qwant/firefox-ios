// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

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
                url: "http://www.qwant.com/?client=qwantbrowser",
                bgColor: "#FFF",
                imageUrl: "asset://suggestedsites_qwant",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 1,
                title: NSLocalizedString("Qwant", comment: "Tile title for Qwant")
            ),
            SuggestedSiteData(
                url: "http://www.qwantjunior.com/?client=qwantbrowser",
                bgColor: "#FFF",
                imageUrl: "asset://suggestedsites_qwantjunior",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 2,
                title: NSLocalizedString("Qwant Junior", comment: "Tile title for Qwant Junior")
            ),
            SuggestedSiteData(
                url: "http://www.qwant.com/music?client=qwantbrowser",
                bgColor: "#FFF",
                imageUrl: "asset://suggestedsites_qwantmusic",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 3,
                title: NSLocalizedString("Qwant Music", comment: "Tile title for Qwant Music")
            ),
            SuggestedSiteData(
                url: "https://boards.qwant.com/?client=qwantbrowser",
                bgColor: "#FFF",
                imageUrl: "asset://suggestedsites_qwantboards",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 4,
                title: NSLocalizedString("Qwant Boards", comment: "Tile title for Qwant Boards")
            ),
            SuggestedSiteData(
                url: "https://help.qwant.com/help/qwant-mobile/?client=qwantbrowser",
                bgColor: "#FFF",
                imageUrl: "asset://suggestedsites_qwanthelp",
                faviconUrl: "asset://defaultFavicon",
                trackingId: 5,
                title: NSLocalizedString("Qwant Help", comment: "Tile title for Qwant Help Center")
            )
        ]
    ]
}
