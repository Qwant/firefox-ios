//
//  RestBlacklistManager.swift
//  Client
//
//  Created by GayaMac on 12/12/2017.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

class RestBlacklistManager : NSObject {
    
    private static let host = "mobile-secure.qwantjunior.com"
    private static let baseURL = "https://\(host)/api/qwant-junior-mobile"
    // mobile-secure.qwantjunior.com
    // qwant-junior-mobile-server2.eu-gb.mybluemix.net
    
    
    public static func getQwantJuniorHost() -> String {
        return host
    }

    public static func testPaths(route : String, paths : [String], onCompletion: @escaping ([Bool]) -> Void, onTimeout: @escaping () -> Void) {
        var postString : String = ""
        var ret : [Bool] = []
        var i = 0
        while (i < paths.count) {
            if (i > 0) {
                postString += "&"
            }
            postString += "test" + String(i + 1) + "=" + paths[i]
            ret.append(true)
            print(String(i + 1) + " -> " + paths[i])
            i += 1
        }
        
        RestRequester.makeHTTPPostRequest(path: baseURL + route, postString: postString, isJsonResponse: true, onCompletion: { err, res in
            let json : [String : Any]? = res as! [String : Any]?
            if (err != nil || json == nil) {
                onCompletion(ret)
                return
            }
            var i = 0
            while (i < paths.count) {
                if (json!["test" + String(i + 1)] == nil) {
                    ret[i] = false
                }
                if (json!["test" + String(i + 1)]! as! Int == 1) {
                    ret[i] = true
                } else {
                    ret[i] = false
                }
                i += 1
            }
            onCompletion(ret)
        }, onTimeout: {
            onTimeout();
        })
    }
    
    public static func ping() {

        RestRequester.makeHTTPPostRequest(path: baseURL + "/ping", postString: "", isJsonResponse: true, onCompletion: { err, res in
            let json : [String : Any]? = res as! [String : Any]?
            if (err != nil || json == nil) {
                return
            }
        }, onTimeout: {
            
        })
    }

}
