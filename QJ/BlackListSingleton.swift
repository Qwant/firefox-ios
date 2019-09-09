//
//  BlackList.swift
//  Client
//
//  Created by GayaMac on 30/11/2017.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

public class BlackListSingleton {
    public static let sharedInstance = BlackListSingleton()
    private var db: BDBlacklistManager? = nil
    private var firstIsSearchEngine : Bool = true
    private let searchEngineContainer : SearchEngineContainer = SearchEngineContainer()

    private init() {
        do {
            db = try BDBlacklistManager.create()
            print("Successfully opened connection to database.")
            
        } catch BDBlacklistManager.SQLiteError.OpenDatabase(let message) {
            print("Unable to open database. Verify that you created the directory described in the Getting Started section: " + message)
            
            //PlaygroundPage.current.finishExecution()
        } catch is Error {
            print("Other Error")
        }
        RestBlacklistManager.ping()
        
        
        //privacy.trackingprotection.enabled
    }
    
    public func isQwantJuniorHost(hostTesting : String) -> Bool {
        return hostTesting == RestBlacklistManager.getQwantJuniorHost() || hostTesting == "qwantjunior.com" || hostTesting == "www.qwantjunior.com"
    }
    
    public func getWarningUrl() -> String {
        let pre = Locale.preferredLanguages[0]
        let l = (pre.count >= 2) ? pre.substring(with: pre.startIndex..<pre.index(pre.startIndex, offsetBy: 2)) : "null"
        return "https://\(RestBlacklistManager.getQwantJuniorHost())/public/index/warning/\(l)"
    }
    
    public func getIpUrl() -> String {
        let pre = Locale.preferredLanguages[0]
        let l = (pre.count >= 2) ? pre.substring(with: pre.startIndex..<pre.index(pre.startIndex, offsetBy: 2)) : "null"
        return "https://\(RestBlacklistManager.getQwantJuniorHost())/public/index/ip/\(l)"
    }
    
    public func getWarningSearchEngineUrl() -> String {
        let pre = Locale.preferredLanguages[0]
        let l = (pre.count >= 2) ? pre.substring(with: pre.startIndex..<pre.index(pre.startIndex, offsetBy: 2)) : "null"
        return "https://\(RestBlacklistManager.getQwantJuniorHost())/public/index/warning-search-engine/\(l)"
    }
    
    public func getSearchEngineUrl(_ searchEngine : String) -> String {
        let pre = Locale.preferredLanguages[0]
        let l = (pre.count >= 2) ? pre.substring(with: pre.startIndex..<pre.index(pre.startIndex, offsetBy: 2)) : "null"
        return "https://\(RestBlacklistManager.getQwantJuniorHost())/public/index/search-engine/\(l)/\(searchEngine)"
    }
    
    public func getTimeoutUrl() -> String {
        let pre = Locale.preferredLanguages[0]
        let l = (pre.count >= 2) ? pre.substring(with: pre.startIndex..<pre.index(pre.startIndex, offsetBy: 2)) : "null"
        return "https://\(RestBlacklistManager.getQwantJuniorHost())/public/index/timeout/\(l)"
    }

    private static func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    private static func hashPath(_ path : String) -> String {
        print("[HASH PATH]")
        print("path : \(path)")
        let path2 = path.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "www.", with: "")
        let url : URL = URL(string: path)!
        let host = (url.host != nil) ? url.host!.replacingOccurrences(of: "www.", with: "") : path2
        let reversedHost : String = host.components(separatedBy: ".").reversed().joined(separator: ".")
        //print("reversedHost : \(reversedHost)")
        let newPath : String = path2.replacingOccurrences(of: host, with: reversedHost)
        //print("newPath : \(newPath)")
        let md5Data = MD5(string : newPath)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        //print("md5Hex: \(md5Hex)")
        return md5Hex
    }
    
    private static func removeParameterInUrl(_ url : String) -> String {
        //print("[REMOVE PARAMETER IN URL]")
        //print("url : \(url)")
        let rangeParameter = url.range(of: "?")
        if (rangeParameter != nil) {
            let strParameter = url.substring(to : rangeParameter!.lowerBound )
            //print("url without parameter : \(strParameter)")
            return strParameter
        }
        //print("url without parameter : \(url)")
        return url
    }
    
    public func isBlackListed(hostTesting: String, onResponse: @escaping (Bool) -> Void, onTimeout: @escaping () -> Void) -> Bool {

        var ret = false
        var isTimeout = false
        
        let before = Date.nowMicroseconds()
        let test = db!.getDomainInBlacklist(domain: hostTesting)
        if (test == nil || test!.expires) {
            print("Network")
            RestBlacklistManager.testPaths(route: "/blacklist/domains/hash", paths: [BlackListSingleton.hashPath(hostTesting)], onCompletion: { (result : [Bool]) in
                ret = result[0]
                do {
                    if (test == nil) {
                        try self.db!.insertDomainInBlacklist(domain: hostTesting, available: !ret)
                    } else {
                        try self.db!.updateDomainInBlacklist(domain: hostTesting, available: !ret)
                    }
                }
                catch BDBlacklistManager.SQLiteError.Bind(let message) {
                    print("Bind Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Step(let message) {
                    print("Step Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Prepare(let message) {
                    print("Prepare Error : " + message)
                    
                } catch is Error {
                    print("Other Error")
                }
            }, onTimeout: {
                isTimeout = true
            })
        } else {
            print("Local")
            ret = !test!.available
        }
        let after = Date.nowMicroseconds()
        let elapsed = after - before
        print("elapsed : " + String(elapsed))
        if (isTimeout) {
            onTimeout()
        } else {
            if (ret) {
                print("BLACKLIST !")
            } else {
                print("OK GO !")
            }
            onResponse(ret)
            return ret
        }
        return true
    }
    
    public func isBlackListed(urlTesting: String, onResponse: @escaping (Bool) -> Void, onTimeout: @escaping () -> Void) -> Bool {
        
        var ret = false
        var isTimeout = false
        
        let urlTestingWithoutParameter = BlackListSingleton.removeParameterInUrl(urlTesting)
        
        let before = Date.nowMicroseconds()
        let test = db!.getUrlInBlacklist(url: urlTestingWithoutParameter)
        if (test == nil || test!.expires) {
            print("Network")
            RestBlacklistManager.testPaths(route: "/blacklist/urls/hash", paths: [BlackListSingleton.hashPath(urlTestingWithoutParameter)], onCompletion: { (result : [Bool]) in
                ret = result[0]
                do {
                    if (test == nil) {
                        try self.db!.insertUrlInBlacklist(url: urlTestingWithoutParameter, available: !ret)
                    } else {
                        try self.db!.updateUrlInBlacklist(url: urlTestingWithoutParameter, available: !ret)
                    }
                }
                catch BDBlacklistManager.SQLiteError.Bind(let message) {
                    print("Bind Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Step(let message) {
                    print("Step Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Prepare(let message) {
                    print("Prepare Error : " + message)
                    
                } catch is Error {
                    print("Other Error")
                }
            }, onTimeout: {
                isTimeout = true
            })
        } else {
            print("Local")
            ret = !test!.available
        }
        let after = Date.nowMicroseconds()
        let elapsed = after - before
        print("elapsed : " + String(elapsed))
        if (isTimeout) {
            onTimeout()
        } else {
            if (ret) {
                print("BLACKLIST !")
            } else {
                print("OK GO !")
            }
            onResponse(ret)
            return ret
        }
        return true
    }
    
    public func areBlackListed(hostsTesting: [String]) -> [Bool] {
        
        let before = Date.nowMicroseconds()

        var rets : [Bool] = Array(repeating: false, count: hostsTesting.count)
        var retsByHost : [String:Bool] = [:]
        var hostsNotFoundInLocalOrExpired : [String] = []
        var hostsNotFoundInLocalOrExpiredState : [String:String] = [:]

        for hostTesting in hostsTesting {
            let test = db!.getDomainInBlacklist(domain: hostTesting)
            if (test == nil || test!.expires) {
                hostsNotFoundInLocalOrExpired.append(hostTesting)
                hostsNotFoundInLocalOrExpiredState[hostTesting] = (test == nil) ? "notFound" : "expired"
                
            } else {
                retsByHost[hostTesting] = !test!.available
            }
        }
        RestBlacklistManager.testPaths(route: "/blacklist/domains", paths: hostsNotFoundInLocalOrExpired, onCompletion: { (result : [Bool]) in
            var i = 0
            while (i < result.count) {
                let ret = result[i]
                let hostTesting = hostsNotFoundInLocalOrExpired[i]
                retsByHost[hostTesting] = ret
                do {
                    if (hostsNotFoundInLocalOrExpiredState[hostTesting] == "notFound") {
                        try self.db!.insertDomainInBlacklist(domain: hostTesting, available: !ret)
                    } else {
                        try self.db!.updateDomainInBlacklist(domain: hostTesting, available: !ret)
                    }
                }
                catch BDBlacklistManager.SQLiteError.Bind(let message) {
                    print("Bind Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Step(let message) {
                    print("Step Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Prepare(let message) {
                    print("Prepare Error : " + message)
                    
                } catch is Error {
                    print("Other Error")
                }
                i += 1
            }
        }, onTimeout: {
            
        })
        var i = 0
        while (i < hostsTesting.count) {
            rets[i] = retsByHost[hostsTesting[i]]!
            i += 1
        }
        
        let after = Date.nowMicroseconds()
        let elapsed = after - before
        print("elapsed : " + String(elapsed))
        
        return rets
    }
    
    public func isRedirect(hostTesting: String, onResponse: @escaping (Bool) -> Void, onTimeout: @escaping () -> Void) -> Bool {
        
        var ret = false
        var isTimeout = false
        
        let before = Date.nowMicroseconds()
        let test = db!.getDomainInRedirect(domain: hostTesting)
        if (test == nil || test!.expires) {
            print("Network")
            RestBlacklistManager.testPaths(route: "/redirect/domains/hash", paths: [BlackListSingleton.hashPath(hostTesting)], onCompletion: { (result : [Bool]) in
                ret = result[0]
                do {
                    if (test == nil) {
                        try self.db!.insertDomainInRedirect(domain: hostTesting, available: !ret)
                    } else {
                        try self.db!.updateDomainInRedirect(domain: hostTesting, available: !ret)
                    }
                }
                catch BDBlacklistManager.SQLiteError.Bind(let message) {
                    print("Bind Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Step(let message) {
                    print("Step Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Prepare(let message) {
                    print("Prepare Error : " + message)
                    
                } catch is Error {
                    print("Other Error")
                }
            }, onTimeout: {
                isTimeout = true
            })
        } else {
            print("Local")
            ret = !test!.available
        }
        let after = Date.nowMicroseconds()
        let elapsed = after - before
        print("elapsed : " + String(elapsed))
        if (isTimeout) {
            onTimeout()
        } else {
            if (ret) {
                print("REDIRECT !")
            } else {
                print("OK GO !")
            }
            onResponse(ret)
            return ret
        }
        return true
    } 
    
    private func isFacebookRedirect(urlTesting : String) -> Bool {
        return urlTesting.contains("facebook.com/") && urlTesting != "http://facebook.com/" && urlTesting != "https://facebook.com/" && urlTesting != "http://www.facebook.com/" && urlTesting != "https://www.facebook.com/" && urlTesting != "http://m.facebook.com/" && urlTesting != "https://m.facebook.com/" && urlTesting != "http://www.m.facebook.com/" && urlTesting != "https://www.m.facebook.com/"
        //let domain = "(([a-z]+)+\\.)?facebook(\\.[a-z]+)+/[a-z]+"
        //let domainRegex : NSRegularExpression = try! NSRegularExpression(pattern : domain, options: [])
        //let results = domainRegex.matches(in: urlTesting, options: [], range: NSRange(location: 0, length: urlTesting.count))
        //return results.count > 0
    }
    
    public func isRedirect(urlTesting: String, onResponse: @escaping (Bool) -> Void, onTimeout: @escaping () -> Void) -> Bool {
        
        if (isFacebookRedirect(urlTesting: urlTesting)) {
            print("isFacebookRedirect \(urlTesting)")
            onResponse(true)
            return true
        }
        
        var ret = false
        var isTimeout = false
        
        let urlTestingWithoutParameter = BlackListSingleton.removeParameterInUrl(urlTesting)
        
        let before = Date.nowMicroseconds()
        let test = db!.getUrlInRedirect(url: urlTesting)
        if (test == nil || test!.expires) {
            print("Network")
            RestBlacklistManager.testPaths(route: "/redirect/urls/hash", paths: [BlackListSingleton.hashPath(urlTestingWithoutParameter)], onCompletion: { (result : [Bool]) in
                ret = result[0]
                do {
                    if (test == nil) {
                        try self.db!.insertUrlInRedirect(url: urlTestingWithoutParameter, available: !ret)
                    } else {
                        try self.db!.updateUrlInRedirect(url: urlTestingWithoutParameter, available: !ret)
                    }
                }
                catch BDBlacklistManager.SQLiteError.Bind(let message) {
                    print("Bind Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Step(let message) {
                    print("Step Error : " + message)
                    
                } catch BDBlacklistManager.SQLiteError.Prepare(let message) {
                    print("Prepare Error : " + message)
                    
                } catch is Error {
                    print("Other Error")
                }
            }, onTimeout: {
                isTimeout = true
            });
        } else {
            print("Local")
            ret = !test!.available
        }
        let after = Date.nowMicroseconds()
        let elapsed = after - before
        print("elapsed : " + String(elapsed))
        if (isTimeout) {
            onTimeout()
        } else {
            if (ret) {
                print("REDIRECT !")
            } else {
                print("OK GO !")
            }
            onResponse(ret)
            return ret
        }
        return true
    }
    
    public func isIp(hostTesting : String) -> Bool {
        
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if hostTesting.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            // IPv6 peer.
            return true
        }
        else if hostTesting.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            // IPv4 peer.
            return true
        }
        
        return false
    }

    public func isFirstSearchEngine(hostTesting : String) -> Bool {
        
        if (!firstIsSearchEngine) {
            return false
        }
        
        if (searchEngineContainer.findSearchEngineName(domain: hostTesting) != nil) {
            firstIsSearchEngine = false;
            return true
        }
        return false
    }

    public func isSearchEngine(hostTesting : String) -> Bool {
        
        return searchEngineContainer.findSearchEngineName(domain: hostTesting) != nil
    }
    
    public func findSearchEngineName(hostTesting : String) -> String? {
        
        return searchEngineContainer.findSearchEngineName(domain: hostTesting)
    }
    
    public func searchEngineHasSearch(searchEngineName : String, url : String) -> Bool {
        
        let searchEngine = searchEngineContainer.getSearchEngine(name: searchEngineName)
        if (searchEngine != nil) {
            if (searchEngine!.search == nil) {
                return false
            }
            if (url.contains(searchEngine!.search!)) {
                return true
            }
        }
        return false
    }

    public func searchEngineHasSafeSearchUrlAvailable(searchEngineName : String, url : String) -> Bool {
        
        let searchEngine = searchEngineContainer.getSearchEngine(name: searchEngineName)
        if (searchEngine != nil) {
            if (searchEngine!.search == nil) {
                return false
            }
            if (searchEngine!.safeSearchUrl != nil && url.contains(searchEngine!.search!)) {
                return true
            }
        }
        return false
    }

    public func searchEngineHasSafeSearchUrl(searchEngineName : String, url : String) -> Bool {
        
        let searchEngine = searchEngineContainer.getSearchEngine(name: searchEngineName)
        if (searchEngine != nil) {
            if (searchEngine!.search == nil) {
                return false
            }
            if (searchEngine!.safeSearchUrl != nil && url.contains(searchEngine!.search!)) {
                return url.contains(searchEngine!.safeSearchUrl!)
            }
        }
        return false
    }
    
    public func convertSearchEngineSafeSearchUrl(searchEngineName : String, url : String) -> String {
        
        let searchEngine = searchEngineContainer.getSearchEngine(name: searchEngineName)
        if (searchEngine != nil) {
            if (searchEngine!.search == nil) {
                return url
            }
            if (searchEngine!.safeSearchUrl != nil && url.contains(searchEngine!.search!)) {
                if url.contains("?") {
                    return url + "&" + searchEngine!.safeSearchUrl!
                } else {
                    return url + "?" + searchEngine!.safeSearchUrl!
                }
                
            }
        }
        return url
    }
    
    public func searchEngineHasSafeSearchRequestAvailable(searchEngineName : String) -> Bool {
        
        let searchEngine = searchEngineContainer.getSearchEngine(name: searchEngineName)
        if (searchEngine != nil) {
            if (searchEngine!.safeSearchRequestType != nil && searchEngine!.safeSearchRequestUrl != nil) {
                return true
            }
        }
        return false
    }
    
    public func runSearchEngineSafeSearchRequest(searchEngineName : String) -> Void {
        
        let searchEngine = searchEngineContainer.getSearchEngine(name: searchEngineName)
        if (searchEngine != nil) {
            if (searchEngine!.safeSearchRequestType != nil && searchEngine!.safeSearchRequestUrl != nil) {
                if (searchEngine!.safeSearchRequestType! == "GET") {
                    RestRequester.makeHTTPGetRequest(path: searchEngine!.safeSearchRequestUrl!, isJsonResponse: false, onCompletion: { err, res in
                        
                    }, onTimeout: {
                        
                    })
                } else if (searchEngine!.safeSearchRequestType! == "POST") {
                    RestRequester.makeHTTPPostRequest(path: searchEngine!.safeSearchRequestUrl!, postString: searchEngine!.safeSearchRequestBody!, isJsonResponse: false, onCompletion: { err, res in
                        
                    }, onTimeout: {
                        
                    })
                }
            }
        }
    }
    
    public func searchEngineHasValidState(searchEngineName : String) -> Bool {
        
        let searchEngine = searchEngineContainer.getSearchEngine(name: searchEngineName)
        if (searchEngine != nil) {
            if (searchEngine!.state == "valid") {
                return true
            }
        }
        return false
    }
    
    public func searchInSearchEngineIfBlacklistedResult(searchEngineName: String, url: String) -> Bool {
        return RestWebCache.searchInSearchEngineIfBlacklistedResult(searchEngineName: searchEngineName, url: url)
    }


}
