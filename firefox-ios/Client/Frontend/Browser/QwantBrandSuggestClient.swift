// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

struct QwantSuggest {
    let title: String
    let url: URL?
    let faviconUrl: URL?
    let domain: String
    let brand: String
    let suggestType: Int?
    let query: String
    let adPosition: Int

    var isBrand: Bool {
        return self.suggestType != nil && self.suggestType == 18 // ¯\_(ツ)_/¯
    }

    func toRequestBody(locale: String, abTestGroup: Int) -> [String: Any]? {
        guard let suggestType,
              let url,
              let language = locale.split(separator: "_").first
        else { return nil }

        return [
            "client": "qwantbrowser",
            "data": [
                "ad_type": "brand-suggest",
                "ad_version": "customadserver",
                "brand": brand,
                "count": query.count,
                "device": "smartphone",
                "locale": locale,
                "position": adPosition,
                "query": query,
                "suggest_type": suggestType,
                "tgp": abTestGroup,
                "type": "ad",
                "url": url.absoluteString
            ],
            "interface_language": language,
            "tgp": abTestGroup,
            "uri": ""
        ]
    }
}

extension QwantSuggest {
    init(title: String) {
        self.init(title: title,
                  url: nil,
                  faviconUrl: nil,
                  domain: "",
                  brand: "",
                  suggestType: 0,
                  query: "",
                  adPosition: 0)
    }
}

class QwantBrandSuggestClient {
    private let suggestTemplate = "https://api.qwant.com/v3/suggest?q={query}&locale={locale}&version=2"
    private let queryComponent = "{query}"
    private let localeComponent = "{locale}"
    private let maxBrandSuggestCount = 2

    private var task: URLSessionTask?

    fileprivate lazy var urlSession: URLSession = makeURLSession(
        userAgent: UserAgent.getUserAgent(),
        configuration: .ephemeral
    )

    func query(_ query: String, callback: @escaping (_ response: [QwantSuggest]?, _ error: NSError?) -> Void) {
        let url = getURLFromTemplate(suggestTemplate, query: query)
        if url == nil {
            let error = NSError(
                domain: SearchSuggestClientErrorDomain,
                code: SearchSuggestClientErrorInvalidEngine,
                userInfo: nil
            )
            callback(nil, error)
            return
        }

        task = urlSession.dataTask(with: url!) { [weak self] (data, response, error) in
            guard let self else {
                let error = NSError(domain: SearchSuggestClientErrorDomain, code: -1, userInfo: nil)
                callback(nil, error)
                return
            }

            if let error = error {
                callback(nil, error as NSError?)
                return
            }

            guard let data = data,
                  validatedHTTPResponse(response, statusCode: 200..<300) != nil
            else {
                let error = NSError(
                    domain: SearchSuggestClientErrorDomain,
                    code: SearchSuggestClientErrorInvalidResponse,
                    userInfo: nil
                )
                callback(nil, error as NSError?)
                return
            }

            let decoder = JSONDecoder()
            // swiftlint: disable force_try
            let suggest = try! decoder.decode(Suggest.self, from: data)
            // swiftlint: enable force_try

            var suggestions = [QwantSuggest]()
            var adPosition = 0
            for brandSuggest in suggest.data.special.prefix(self.maxBrandSuggestCount) {
                guard
                    let brandUrl = brandSuggest.url,
                    let url = URL(string: brandUrl),
                    let brandFaviconUrl = brandSuggest.faviconURL,
                        let faviconUrl = URL(string: brandFaviconUrl)
                else { continue }
                adPosition += 1
                suggestions.append(QwantSuggest(title: brandSuggest.name,
                                                url: url,
                                                faviconUrl: faviconUrl,
                                                domain: brandSuggest.domain,
                                                brand: brandSuggest.brand,
                                                suggestType: brandSuggest.suggestType,
                                                query: query,
                                                adPosition: adPosition))
            }

            for regularSuggest in suggest.data.items {
                suggestions.append(QwantSuggest(title: regularSuggest.value))
            }

            if suggestions.isEmpty {
                let error = NSError(
                    domain: SearchSuggestClientErrorDomain,
                    code: SearchSuggestClientErrorInvalidResponse,
                    userInfo: nil
                )
                callback(nil, error)
                return
            }
            callback(suggestions, nil)
        }
        task?.resume()
    }

    func cancelPendingRequest() {
        task?.cancel()
    }

    private func getURLFromTemplate(_ searchTemplate: String, query: String) -> URL? {
        if let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .SearchTermsAllowed) {
            // Escape the search template as well in case it contains not-safe characters like symbols
            let templateAllowedSet = NSMutableCharacterSet()
            templateAllowedSet.formUnion(with: .URLAllowed)

            // Allow brackets since we use them in our template as our insertion point
            templateAllowedSet.formUnion(with: CharacterSet(charactersIn: "{}"))

            if let encodedSearchTemplate = searchTemplate
                .addingPercentEncoding(withAllowedCharacters: templateAllowedSet as CharacterSet) {
                let localeString = Locale.current.identifier
                let urlString = encodedSearchTemplate
                    .replacingOccurrences(of: queryComponent, with: escapedQuery, options: .literal, range: nil)
                    .replacingOccurrences(of: localeComponent, with: localeString, options: .literal, range: nil)
                return URL(string: urlString)
            }
        }

        return nil
    }
}

// MARK: - Suggest
private struct Suggest: Codable {
    let status: String
    let data: DataClass
}

// MARK: - DataClass
private struct DataClass: Codable {
    let items: [Item]
    let special: [Special]
}

// MARK: - Item
private struct Item: Codable {
    let value: String
    let suggestType: Int
}

// MARK: - Special
private struct Special: Codable {
    let type: String
    let suggestType: Int
    let name, domain: String
    let url: String?
    let brand: String
    let faviconURL: String?

    enum CodingKeys: String, CodingKey {
        case type, suggestType, name, domain, url, brand
        case faviconURL = "favicon_url"
    }
}
