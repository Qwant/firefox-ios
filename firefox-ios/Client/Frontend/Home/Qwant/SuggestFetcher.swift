// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

struct SuggestFetcher: AnyFetcher {
    typealias T = QwantSuggest

    let profile: Profile
    let maxCount: Int
    let brandClient: QwantBrandSuggestClient
    let openSearchClient: SearchSuggestClient

    private func doBrandClientQuery(for query: String, completion: @escaping ([QwantSuggest], Int) -> Void) {
        var result = [QwantSuggest(title: query)]

        brandClient.query(query) { suggestions, error in
            if error != nil {
                doOpenSearchClientQuery(for: query, completion: completion)
            } else {
                result = suggestions!
                let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                // Remove user searching term inside suggestions list
                result.removeAll(where: { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedQuery })
                // First suggestions should be the brand suggest, and next what the user is searching
                var lastBrandSuggestion = 0
                if let idx = result.lastIndex(where: { $0.isBrand }) {
                    lastBrandSuggestion = idx + 1
                }
                result.insert(QwantSuggest(title: query), at: lastBrandSuggestion)
                completion(result, lastBrandSuggestion)
            }
        }
    }

    private func doOpenSearchClientQuery(for query: String, completion: @escaping ([QwantSuggest], Int) -> Void) {
        var result = [QwantSuggest(title: query)]

        openSearchClient.query(query) { suggestions, error in
            if error == nil {
                result = suggestions!.map { QwantSuggest(title: $0) }
                let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                // Remove user searching term inside suggestions list
                result.removeAll(where: { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedQuery })
                // First suggestion should be what the user is searching
                result.insert(QwantSuggest(title: query), at: 0)
            }

            completion(result, 0)
        }
    }

    func fetch(for query: String, completion: @escaping ([QwantSuggest]) -> Void) {
        brandClient.cancelPendingRequest()
        openSearchClient.cancelPendingRequest()

        if query.isEmpty || !profile.searchEngines.shouldShowSearchSuggestions || query.looksLikeAURL() {
            return completion([QwantSuggest(title: query)])
        }

        doBrandClientQuery(for: query) { suggestions, brandSuggestionsCount in
            completion(Array(suggestions.prefix(maxCount + brandSuggestionsCount)))
        }
    }
}

/**
 * Private extension containing string operations specific to this view controller
 */
fileprivate extension String {
    func looksLikeAURL() -> Bool {
        // The assumption here is that if the user is typing in a forward slash and there are no spaces
        // involved, it's going to be a URL. If we type a space, any url would be invalid.
        // See https://bugzilla.mozilla.org/show_bug.cgi?id=1192155 for additional details.
        return self.contains("/") && !self.contains(" ")
    }
}
