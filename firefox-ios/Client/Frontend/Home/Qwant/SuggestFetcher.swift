// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

struct SuggestFetcher: AnyFetcher {
    typealias T = String

    let profile: Profile
    let maxCount: Int
    let client: SearchSuggestClient

    func fetch(for query: String, completion: @escaping ([String]) -> Void) {
        client.cancelPendingRequest()

        var result = [query]

        if query.isEmpty || !profile.searchEngines.shouldShowSearchSuggestions || query.looksLikeAURL() {
            return completion(result)
        }

        client.query(query, callback: { suggestions, error in
            if error == nil {
                result = suggestions!
                let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
                // Remove user searching term inside suggestions list
                result.removeAll(where: {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedQuery
                })
                // First suggestion should be what the user is searching
                result.insert(query, at: 0)
            }

            completion(Array((result).prefix(maxCount)))
        })
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
