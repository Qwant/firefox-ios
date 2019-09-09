//
//  RestRequester.swift
//  Client
//
//  Created by GayaMac on 19/01/2018.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation

class RestRequester {
    
    public static func makeHTTPGetRequest(path: String, isJsonResponse : Bool,
                                          onCompletion: @escaping (Error?, Any?) -> Void,
                                          onTimeout: @escaping () -> Void) {
        
        guard let url = URL(string: path) else {
            print("Error: cannot create URL with " + path)
            onCompletion(nil, nil)
            return
        }
        
        var retE : Error?
        var retS : Any?
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let sem = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard error == nil else {
                print("Error calling GET on " + path)
                print(error)
                retE = error
                sem.signal()
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data on " + path)
                sem.signal()
                return
            }
            
            do {
                print("Success GET : " + path)
                if (isJsonResponse) {
                    guard let receivedJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                        print("Could not get JSON from responseData as dictionary")
                        sem.signal()
                        return
                    }
                    print(receivedJSON)
                    retS = receivedJSON
                } else {
                    retS = responseData
                }
                sem.signal()
            } catch {
                print("error parsing response from Get on " + path)
                sem.signal()
                return
            }
        }
        task.resume()
        let timeout_result = sem.wait(timeout: DispatchTime.now() + .milliseconds(1000))
        switch timeout_result {
        case .success:
            onCompletion(retE, retS)
            break;
        case .timedOut:
            onTimeout();
            break;
        default:
            break;
        }
    }
    
    public static func makeHTTPPostRequest(path: String, postString : String, isJsonResponse : Bool,
                                           onCompletion: @escaping (Error?, Any?) -> Void,
                                           onTimeout: @escaping () -> Void) {
        
        guard let url = URL(string: path) else {
            print("Error: cannot create URL with " + path)
            onCompletion(nil, nil)
            return
        }
        
        var retE : Error?
        var retS : Any?
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let sem = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard error == nil else {
                print("Error calling POST on " + path)
                print(error)
                retE = error
                sem.signal()
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data on " + path)
                sem.signal()
                return
            }
            
            do {
                print("Success POST : " + path)
                if (isJsonResponse) {
                    guard let receivedJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                        print("Could not get JSON from responseData as dictionary")
                        sem.signal()
                        return
                    }
                    print(receivedJSON)
                    retS = receivedJSON
                } else {
                    retS = responseData
                }
                sem.signal()
            } catch {
                print("error parsing response from POST on " + path)
                sem.signal()
                return
            }
        }
        task.resume()
        let timeout_result = sem.wait(timeout: DispatchTime.now() + .milliseconds(500))
        switch timeout_result {
        case .success:
            onCompletion(retE, retS)
            break;
        case .timedOut:
            onTimeout();
            break;
        default:
            break;
        }
    }
    
}
