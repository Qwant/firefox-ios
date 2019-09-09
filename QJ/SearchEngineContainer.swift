//
//  SearchEngineContainer.swift
//  Client
//
//  Created by GayaMac on 11/01/2018.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SearchEngine {
    
    var name : String
    var domain : String
    var domainRegex : NSRegularExpression
    var search : String?
    var safeSearchUrl : String?
    var safeSearchRequestType : String?
    var safeSearchRequestUrl : String?
    var safeSearchRequestBody : String?
    var state : String
    
    init(name : String, domain : String, search : String? = nil, safeSearchUrl : String? = nil, safeSearchRequestType : String? = nil, safeSearchRequestUrl : String? = nil, safeSearchRequestBody : String? = nil, state : String) {
        self.name = name
        self.domain = domain
        self.domainRegex = try! NSRegularExpression(pattern : domain, options: [])
        self.search = search
        self.safeSearchUrl = safeSearchUrl
        self.safeSearchRequestType = safeSearchRequestType
        self.safeSearchRequestUrl = safeSearchRequestUrl
        self.safeSearchRequestBody = safeSearchRequestBody
        self.state = state
    }
}

class SearchEngineContainer {
    
    private var searchEngines : [String : SearchEngine] = [:]
    
    public init() {
        let filePath = Bundle.main.path(forResource: "search_engines", ofType: "json")
        let file = try! Data(contentsOf: URL(fileURLWithPath: filePath!))
        let json = JSON(file)
        json.forEach({
            let name = $0.1["name"].string
            let domain = $0.1["domain"].string
            let search = $0.1["search"].string
            let safeSearchUrl = $0.1["safe_search_url"].string
            let safeSearchRequestType = $0.1["safe_search_request_type"].string
            let safeSearchRequestUrl = $0.1["safe_search_request_url"].string
            let safeSearchRequestBody = $0.1["safe_search_request_body"].string
            let state = $0.1["state"].string
            let searchEngine = SearchEngine(name : name!, domain : domain!, search : search, safeSearchUrl : safeSearchUrl, safeSearchRequestType : safeSearchRequestType, safeSearchRequestUrl : safeSearchRequestUrl, safeSearchRequestBody : safeSearchRequestBody, state : state!)
            searchEngines[searchEngine.name] = searchEngine
        })
    }
    
    public func findSearchEngineName(domain : String) -> String? {
        for (_, searchEngine) in searchEngines {
            /*if (searchEngine.domainRegex.numberOfMatches(in: domain, options: [], range: NSRange(location: 0, length: domain.count)) != 0) {
                return searchEngine.name
            }*/
            let results = searchEngine.domainRegex.matches(in: domain, options: [], range: NSRange(location: 0, length: domain.count))
            let resultsStr = results.map {
                String(domain[Range($0.range, in: domain)!])
            }
            for result in resultsStr {
                if result! == domain {
                    return searchEngine.name
                }
            }
        }
        return nil
    }
    
    public func getSearchEngine(name : String) -> SearchEngine? {
        return searchEngines[name]
    }

    
}
