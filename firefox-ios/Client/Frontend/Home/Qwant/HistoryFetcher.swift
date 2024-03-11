// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Storage
import MozillaAppServices

struct HistoryFetcher: AnyFetcher {
    typealias T = Site

    let profile: Profile
    var maxCount: Int
    let tabs: [Tab]

    func fetch(for query: String, completion: @escaping ([Site]) -> Void) {
        profile
            .places
            .getSitesWithBound(
                limit: 1000,
                offset: 0,
                excludedTypes: VisitTransitionSet(0))
            .uponQueue(.global()) { result in
                guard let history = result.successValue?.asArray(), !history.isEmpty else {
                    return DispatchQueue.main.async { completion([]) }
                }

                let filterHistory = history.filter { history in
                    let historyUrl = URL(string: history.url)
                    return !tabs.contains { historyUrl == $0.lastKnownUrl }
                    && !(historyUrl?.isQwantUrl == true && historyUrl?.qwantSearchTerm == nil)
                }

                var qwantSearches = [String]()
                let sites = filterHistory.compactMap {
                    var skip = false
                    let historyUrl = URL(string: $0.url)
                    if historyUrl?.isQwantUrl == true, let term = historyUrl?.qwantSearchTerm, !term.isEmptyOrWhitespace() {
                        if qwantSearches.contains(term) {
                            skip = true
                        } else {
                            qwantSearches.append(term)
                        }
                    }

                    var filters: [String] = []
                    if historyUrl?.isQwantUrl == false {
                        filters = [
                            $0.title,
                            $0.url.titleFromHostname
                        ]
                    } else {
                        filters = [historyUrl?.qwantSearchTerm ?? ""]
                    }

                    if !skip && filters.contains(where: { $0.lowercased().contains(query) }) {
                        return Site.createBasicSite(url: $0.url, title: $0.title)
                    }
                    return nil
                }
                DispatchQueue.main.async { completion(Array(sites.prefix(maxCount))) }
            }
    }
}
