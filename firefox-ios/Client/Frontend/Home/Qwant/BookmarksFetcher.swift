// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Storage

struct BookmarksFetcher: AnyFetcher {
    typealias T = Site

    let profile: Profile
    var maxCount: Int

    func fetch(for query: String, completion: @escaping ([Site]) -> Void) {
        profile
            .places
            .searchBookmarks(query: query, limit: UInt(maxCount))
            .uponQueue(.global()) { result in
                guard let bookmarkItems = result.successValue else {
                    return DispatchQueue.main.async { completion([]) }
                }

                let sites = bookmarkItems.map { Site(url: $0.url, title: $0.title, bookmarked: true, guid: $0.guid) }
                DispatchQueue.main.async { completion(sites) }
            }
    }
}
