//
//  BDBlacklistManager.swift
//  Client
//
//  Created by GayaMac on 07/12/2017.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit

class BDBlacklistManager: NSObject {
    
    public enum SQLiteError: Error {
        case OpenDatabase(message: String)
        case Prepare(message: String)
        case Step(message: String)
        case Bind(message: String)
    }
    
    fileprivate let dbPointer: OpaquePointer?
    
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static private func config(dbPointer: OpaquePointer?) -> BDBlacklistManager {
        let bl : BDBlacklistManager = BDBlacklistManager(dbPointer: dbPointer)
        bl.createMD5function()
        bl.test()
        return bl
    }
    
    static public func open() throws -> BDBlacklistManager {
        var db: OpaquePointer? = nil
        /* INTERNAL */
        //let dbPath = Bundle.main.resourcePath! + "/database.qwant_junior_mobile"
        /* EXTERNAL */
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0]
        let dbPath = documentsDirectory + "/databaseV1.1.qwant_junior_mobile"
        // 1
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            // 2
            return config(dbPointer: db)
        } else {
            // 3
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
    
    static public func create() throws -> BDBlacklistManager {
        var db: OpaquePointer? = nil
        /* EXTERNAL */
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0]
        let dbPath = documentsDirectory + "/databaseV1.1.qwant_junior_mobile"
        if (FileManager.default.fileExists(atPath: dbPath) == false) {
            if (sqlite3_open(dbPath, &db) == SQLITE_OK) {
                let sqlQuery = """
DROP TABLE IF EXISTS AvailableBlacklistDomains ;
CREATE TABLE AvailableBlacklistDomains ( domain VARCHAR(128) NOT NULL UNIQUE, available CHAR(1) NOT NULL, sign VARCHAR(32) NOT NULL, expires DATE NOT NULL );
DROP TABLE IF EXISTS AvailableRedirectDomains ;
CREATE TABLE AvailableRedirectDomains ( domain VARCHAR(128) NOT NULL UNIQUE, available CHAR(1) NOT NULL, sign VARCHAR(32) NOT NULL, expires DATE NOT NULL );
DROP TABLE IF EXISTS AvailableBlacklistUrls ;
CREATE TABLE AvailableBlacklistUrls ( url VARCHAR(128) NOT NULL UNIQUE, available CHAR(1) NOT NULL, sign VARCHAR(32) NOT NULL, expires DATE NOT NULL );
DROP TABLE IF EXISTS AvailableRedirectUrls ;
CREATE TABLE AvailableRedirectUrls ( url VARCHAR(128) NOT NULL UNIQUE, available CHAR(1) NOT NULL, sign VARCHAR(32) NOT NULL, expires DATE NOT NULL );
"""
                sqlite3_exec(db, sqlQuery, nil, nil, nil)
                if let errorPointer = sqlite3_errmsg(db) {
                    let message = String.init(cString: errorPointer)
                    print("----> \(message)")
                } else {
                    print("----> No error message provided from sqlite.")
                }
                
                return config(dbPointer: db)
            }
        }
        return try open()
    }
    
    private func createMD5function() {
        sqlite3_create_function(dbPointer, "MD5", 1, SQLITE_UTF8, nil, { (db, argc, argv) in
            if (argc != 1) {
                sqlite3_result_null(db)
                return
            }
            let value = String(cString: sqlite3_value_text(argv![0]))
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            if let data = value.data(using: String.Encoding.utf8) {
                CC_MD5(data.getBytes(), CC_LONG(data.count), &digest)
            }
            
            var digestHex = ""
            for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
                digestHex += String(format: "%02x", digest[index])
            }
            
            sqlite3_result_text(db, digestHex.cString(using: String.Encoding.ascii), Int32(digestHex.lengthOfBytes(using: String.Encoding.ascii)), nil)
        }, nil, nil)
    }
    
    public func test() {
        print("test")
        do {
            //let querySql = "SELECT MD5('coucou les amis');"
            let querySql = "SELECT name FROM sqlite_master WHERE type='table' ;"
            let queryStatement = try prepareStatement(sql: querySql)
            
            defer {
                sqlite3_finalize(queryStatement)
            }
            
            print("Result : ")
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                var i : Int32 = 0
                while (i < sqlite3_column_count(queryStatement)) {
                    print("colomn " + String(i) + " : " + String(cString: sqlite3_column_text(queryStatement, i)))
                    i += 1
                }
            }
        }
        catch BDBlacklistManager.SQLiteError.Prepare(let message) {
            print("Prepare Error : " + message)
            
        } catch is Error {
            print("Other Error")
        }
        
    }

    private func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            if let errorPointer = sqlite3_errmsg(dbPointer) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.Prepare(message: message)
            } else {
                throw SQLiteError.Prepare(message: "No error message provided from sqlite.")
            }
        }
        
        return statement
    }
    
    private func get(table : String, field : String, path: String) -> (available : Bool, expires : Bool)? {
        let querySql = "SELECT " + field + ", available, sign = MD5(" + field + " || available || '2456'), expires < DATE('now') FROM " + table + " WHERE " + field + " = MD5(?) ;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        let str = path.cString(using: String.Encoding.utf8)
        guard sqlite3_bind_text(queryStatement, 1, str, -1, nil) == SQLITE_OK else {
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        //let col0 = sqlite3_column_text(queryStatement, 0)
        //let path = String(cString : col0!)
        let available = (sqlite3_column_int(queryStatement, 1) == 1)
        let sign = (sqlite3_column_int(queryStatement, 2) == 1)
        let expires = (sqlite3_column_int(queryStatement, 3) == 1)
        
        return (available && sign, expires)
    }
    
    public func getDomainInBlacklist(domain: String) -> (available : Bool, expires : Bool)? {
        return get(table: "AvailableBlacklistDomains", field: "domain", path: domain)
    }
    
    public func getDomainInRedirect(domain: String) -> (available : Bool, expires : Bool)? {
        return get(table: "AvailableRedirectDomains", field: "domain", path: domain)
    }
    
    public func getUrlInBlacklist(url: String) -> (available : Bool, expires : Bool)? {
        return get(table: "AvailableBlacklistUrls", field: "url", path: url)
    }
    
    public func getUrlInRedirect(url: String) -> (available : Bool, expires : Bool)? {
        return get(table: "AvailableRedirectUrls", field: "url", path: url)
    }

    private func displayAll(table : String, field : String) {
        let querySql = "SELECT * FROM " + table
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        print("display all " + field + "s in " + table + " : ")
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            
            let col0 = sqlite3_column_text(queryStatement, 0)
            let domain = String(cString : col0!)
            let available = (sqlite3_column_int(queryStatement, 1) == 1)
            let col2 = sqlite3_column_text(queryStatement, 2)
            let sign = String(cString : col2!)
            let col3 = sqlite3_column_text(queryStatement, 3)
            let created = String(cString : col3!)
            
            print(domain + ", " + String(available) + ", " + sign + ", " + created)
        }
    }
    
    public func displayAllDomainsInBlacklist() {
        displayAll(table: "AvailableBlacklistDomains", field: "domain")
    }
    
    public func displayAllDomainsInRedirect() {
        displayAll(table: "AvailableRedirectDomains", field: "domain")
    }
    
    public func displayAllUrlsInBlacklist() {
        displayAll(table: "AvailableBlacklistUrls", field: "url")
    }
    
    public func displayAllUrlsInRedirect() {
        displayAll(table: "AvailableRedirectUrls", field: "url")
    }

    private func insert(table : String, field : String, path: String, available: Bool) throws {
        let insertSql = "INSERT INTO " + table + " (" + field + ", available, sign, expires) VALUES (MD5(?), ?, MD5(MD5(?) || ? || '2456'), DATE('now', '+1 day'));"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let str = path.cString(using: String.Encoding.utf8)
        let i : Int32 = (available) ? 1 : 0
        guard sqlite3_bind_text(insertStatement, 1, str, -1, nil) == SQLITE_OK && sqlite3_bind_int(insertStatement, 2, i) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, str, -1, nil) == SQLITE_OK && sqlite3_bind_int(insertStatement, 4, i) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: "")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            if let errorPointer = sqlite3_errmsg(dbPointer) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.Step(message: message)
            } else {
                throw SQLiteError.Step(message: "No error message provided from sqlite.")
            }
        }
        
        print("Successfully inserted row.")
    }
    
    public func insertDomainInBlacklist(domain: String, available: Bool) throws {
        try insert(table: "AvailableBlacklistDomains", field: "domain", path: domain, available: available)
    }
    
    public func insertDomainInRedirect(domain: String, available: Bool) throws {
        try insert(table: "AvailableRedirectDomains", field: "domain", path: domain, available: available)
    }
    
    public func insertUrlInBlacklist(url: String, available: Bool) throws {
        try insert(table: "AvailableBlacklistUrls", field: "url", path: url, available: available)
    }
    
    public func insertUrlInRedirect(url: String, available: Bool) throws {
        try insert(table: "AvailableRedirectUrls", field: "url", path: url, available: available)
    }

    private func update(table : String, field : String, path: String, available: Bool) throws {
        let insertSql = "UPDATE " + table + " SET sign = MD5(MD5(?) || ? || '2456'), available = ?, expires = DATE('now', '+1 day') WHERE " + field + " = MD5(?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        let str = path.cString(using: String.Encoding.utf8)
        let i : Int32 = (available) ? 1 : 0
        guard sqlite3_bind_text(insertStatement, 1, str, -1, nil) == SQLITE_OK && sqlite3_bind_int(insertStatement, 2, i) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, str, -1, nil) == SQLITE_OK && sqlite3_bind_int(insertStatement, 3, i) == SQLITE_OK
            else {
                throw SQLiteError.Bind(message: "")
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            if let errorPointer = sqlite3_errmsg(dbPointer) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.Step(message: message)
            } else {
                throw SQLiteError.Step(message: "No error message provided from sqlite.")
            }
        }
        
        print("Successfully updated row.")
    }
    
    public func updateDomainInBlacklist(domain: String, available: Bool) throws {
        try update(table: "AvailableBlacklistDomains", field: "domain", path: domain, available: available)
    }
    
    public func updateDomainInRedirect(domain: String, available: Bool) throws {
        try update(table: "AvailableRedirectDomains", field: "domain", path: domain, available: available)
    }
    
    public func updateUrlInBlacklist(url: String, available: Bool) throws {
        try update(table: "AvailableBlacklistUrls", field: "url", path: url, available: available)
    }
    
    public func updateUrlInRedirect(url: String, available: Bool) throws {
        try update(table: "AvailableRedirectUrls", field: "url", path: url, available: available)
    }

}
