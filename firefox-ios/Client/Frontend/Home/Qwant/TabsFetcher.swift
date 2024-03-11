// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Shared

struct TabsFetcher: AnyFetcher {
    typealias T = Tab

    let profile: Profile
    let tabManager: TabManager
    var maxCount: Int
    let isPrivate: Bool

    func fetch(for query: String, completion: @escaping ([Tab]) -> Void) {
        let currentTabs = isPrivate ? tabManager.privateTabs : tabManager.normalTabs

        // We split the search query by spaces so we can simulate full text search.
        let searchTerms = query.split(separator: " ")

        let filteredOpenedTabs = currentTabs.filter { tab in
            guard let url = tab.url, !InternalURL.isValid(url: url) else {
                return false
            }

            if url.isQwantUrl && (url.qwantSearchTerm ?? "").isEmptyOrWhitespace() {
                return false
            }

            let lines = [
                tab.title ?? tab.lastTitle,
                url.absoluteString.titleFromHostname
            ]
                .compactMap { $0 }

            let text = lines.joined(separator: "\n")
            return find(for: searchTerms, in: text)
        }

        completion(Array((filteredOpenedTabs).prefix(maxCount)))
    }

    private func find(for searchTerms: [String.SubSequence], in content: String?) -> Bool {
        guard let content = content else {
            return false
        }
        return searchTerms.reduce(true) {
            $0 && content.range(of: $1, options: .caseInsensitive) != nil
        }
    }
}
