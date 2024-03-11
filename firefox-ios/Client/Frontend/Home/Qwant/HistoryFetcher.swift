// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Storage

struct HistoryFetcher: AnyFetcher {
    typealias T = Site

    let profile: Profile
    var maxCount: Int
    let tabs: [Tab]

    func fetch(for query: String, completion: @escaping ([Site]) -> Void) {
        profile
            .places
            .getHighlights(weights: HistoryHighlightWeights(viewTime: 10.0, frequency: 4.0), limit: Int32(1000))
            .uponQueue(.global()) { result in
                guard let history = result.successValue, !history.isEmpty else {
                    return DispatchQueue.main.async { completion([]) }
                }

                var filterHistory = history.filter { history in
                    !tabs.contains { history.urlFromString == $0.lastKnownUrl }
                    && !(history.siteUrl?.isQwantUrl == true && history.siteUrl?.qwantSearchTerm == nil)
                }

                filterHistory = SponsoredContentFilterUtility().filterSponsoredHighlights(from: filterHistory)

                var qwantSearches = [String]()
                let sites = filterHistory.compactMap {
                    var skip = false
                    if $0.siteUrl?.isQwantUrl == true, let term = $0.siteUrl?.qwantSearchTerm, !term.isEmptyOrWhitespace() {
                        if qwantSearches.contains(term) {
                            skip = true
                        } else {
                            qwantSearches.append(term)
                        }
                    }

                    var filters: [String] = []
                    if $0.siteUrl?.isQwantUrl == false {
                        filters = [
                            $0.displayTitle,
                            $0.url.titleFromHostname
                        ]
                    } else {
                        filters = [$0.siteUrl?.qwantSearchTerm ?? ""]
                    }

                    if !skip && filters.contains(where: { $0.lowercased().contains(query) }) {
                        return Site(url: $0.url, title: $0.displayTitle)
                    }
                    return nil
                }
                DispatchQueue.main.async { completion(Array(sites.prefix(maxCount))) }
            }
    }
}
