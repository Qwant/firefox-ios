//
//  GameOffline.swift
//  Client
//
//  Created by GayaMac on 16/01/2018.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation

public class GameOffline {
    
    static public let sharedInstance = GameOffline()
    
    public var code : String = ""
    
    private init() {
        let filePath = Bundle.main.path(forResource: "gameOffline", ofType: "html")
        let file = try! Data(contentsOf: URL(fileURLWithPath: filePath!))
        code = String(data: file, encoding: String.Encoding.utf8) as String? ?? ""
    }
    
}
