//
//  RestWebCache.swift
//  Client
//
//  Created by GayaMac on 26/12/2017.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

private class UtilsBalise {
    
    static func extract(_ raw : [CChar], _ start : Int, _ end : Int ) -> String? {
        let subBuffer = Array(raw[start..<end]) + [0]
        let subBufferStr = String(cString: subBuffer, encoding: String.Encoding.utf8)
        return subBufferStr
    }
    
    static func isEqual(_ char : CChar) -> Bool {
        let charequal : CChar = "=".cString(using: String.Encoding.utf8)![0]
        
        return char == charequal
    }
    
    static func isDoubleQuotes(_ char : CChar) -> Bool {
        let charDquotes : CChar = "\"".cString(using: String.Encoding.utf8)![0]
        
        return char == charDquotes
    }
    
    static func isQuotes(_ char : CChar) -> Bool {
        let charquotes : CChar = "\'".cString(using: String.Encoding.utf8)![0]
        
        return char == charquotes
    }
    
    static func isVar(_ char : CChar) -> Bool {
        let chara : CChar = "a".cString(using: String.Encoding.utf8)![0]
        let charz : CChar = "z".cString(using: String.Encoding.utf8)![0]
        let charA : CChar = "A".cString(using: String.Encoding.utf8)![0]
        let charZ : CChar = "Z".cString(using: String.Encoding.utf8)![0]
        let char0 : CChar = "A".cString(using: String.Encoding.utf8)![0]
        let char9 : CChar = "Z".cString(using: String.Encoding.utf8)![0]
        let char_ : CChar = "_".cString(using: String.Encoding.utf8)![0]
        
        return (char >= chara && char <= charz) || (char >= charA && char <= charZ) || (char >= char0 && char <= char9) || char == char_
    }
    
    static func isAlpha(_ char : CChar) -> Bool {
        let chara : CChar = "a".cString(using: String.Encoding.utf8)![0]
        let charz : CChar = "z".cString(using: String.Encoding.utf8)![0]
        
        return char >= chara && char <= charz
    }
    
    static func isBaliseStart(_ char : CChar) -> Bool {
        let charslash : CChar = "<".cString(using: String.Encoding.utf8)![0]
        
        return char == charslash
    }
    
    static func isBaliseEnd(_ char : CChar) -> Bool {
        let charslash : CChar = ">".cString(using: String.Encoding.utf8)![0]
        
        return char == charslash
    }

    static func isClosed(_ char : CChar) -> Bool {
        let charslash : CChar = "/".cString(using: String.Encoding.utf8)![0]
        
        return char == charslash
    }

    static func isSpace(_ char : CChar) -> Bool {
        let charspace : CChar = " ".cString(using: String.Encoding.utf8)![0]
        
        return char == charspace
    }
    
    static func getCChar(_ str : String) -> CChar {
        let char : CChar = str.cString(using: String.Encoding.utf8)![0]
        return char
    }
}

private class Balise {
    
    var absolute : String
    var absoluteRaw : [CChar]
    var originalSize : Int
    var type : String;
    var opened : Bool;
    var closed : Bool;
    
    var attrs : [String : (String, Int)]
    
    //Advanced++
    var externalIndex : Int;
    var contain : String
    var closedBalise : Balise?
    var openedBalise : Balise?
    var parentBalise : Balise?
    
    init(absolute : String, externalIndex : Int = 0) {
        self.absolute = absolute
        absoluteRaw = Array(absolute.utf8).map { CChar(bitPattern: $0) }
        originalSize = absolute.count
        type = ""
        opened = false
        closed = false
        self.externalIndex = externalIndex
        contain = ""
        attrs = [String : (String, Int)]()
        initType()
    }

    private func initType() {
        var i = 1
        if (UtilsBalise.isClosed(absoluteRaw[i])) {
            opened = false
            closed = true
            i += 1
        } else if UtilsBalise.isAlpha(absoluteRaw[i]) {
            opened = true
        } else {
            type = "Invalid Type"
            return
        }
        while (i < absoluteRaw.count && UtilsBalise.isAlpha(absoluteRaw[i])) {
            i += 1
        }
        if (i == absoluteRaw.count) {
            type = "Invalid Type"
        } else {
            let type = (!closed) ? UtilsBalise.extract(absoluteRaw, 1, i) : UtilsBalise.extract(absoluteRaw, 2, i)
            if (type != nil) {
                self.type = type!
            }
        }
        if (UtilsBalise.isClosed(absoluteRaw[absoluteRaw.count - 2])) {
            closed = true
        }
        //Exceptions
        if (type == "img") {
            closed = true
        }
    }
    
    public func initAttr() {
        var i = 1
        var indexPrevVar = 0
        while (i < absoluteRaw.count) {
            if (UtilsBalise.isSpace(absoluteRaw[i])) {
                while (i < absoluteRaw.count && UtilsBalise.isSpace(absoluteRaw[i])) {
                    i += 1
                }
            }
            else if (UtilsBalise.isVar(absoluteRaw[i])) {
                indexPrevVar = i
                while (i < absoluteRaw.count && UtilsBalise.isVar(absoluteRaw[i])) {
                    i += 1
                }
                let attr = UtilsBalise.extract(absoluteRaw, indexPrevVar, i)
                var value : String? = ""
                var nbQuotes = 0
                if (UtilsBalise.isEqual(absoluteRaw[i])) {
                    i += 1
                    indexPrevVar = i
                    while (i < absoluteRaw.count && UtilsBalise.isVar(absoluteRaw[i])) {
                        i += 1
                    }
                    if (i == indexPrevVar && UtilsBalise.isQuotes(absoluteRaw[i])) {
                        i += 1
                        nbQuotes = 1
                        while (i < absoluteRaw.count && !UtilsBalise.isQuotes(absoluteRaw[i])) {
                            i += 1
                        }
                    }
                    if (i == indexPrevVar && UtilsBalise.isDoubleQuotes(absoluteRaw[i])) {
                        i += 1
                        nbQuotes = 2
                        while (i < absoluteRaw.count && !UtilsBalise.isDoubleQuotes(absoluteRaw[i])) {
                            i += 1
                        }
                    }
                    if (i != indexPrevVar) {
                        value = (nbQuotes == 0) ? UtilsBalise.extract(absoluteRaw, indexPrevVar, i) : UtilsBalise.extract(absoluteRaw, indexPrevVar + 1, i)
                        if (value == nil) {
                            value = ""
                        }
                    }
                }

                if (attr != nil) {
                    attrs[attr!] = (value!, nbQuotes)
                }
                if (i < absoluteRaw.count && !UtilsBalise.isSpace(absoluteRaw[i])) {
                    while (i < absoluteRaw.count && !UtilsBalise.isSpace(absoluteRaw[i])) {
                        i += 1
                    }
                }
            }
            else {
                i += 1
            }
        }
    }
    
    public func changeAttrs(attr : String, value : String, nbQuotes : Int) {
        if (attrs != nil && opened) {
            attrs[attr] = (value, nbQuotes)
            absolute = "<" + self.type
            for (a, (v, n)) in attrs {
                if (a != self.type) {
                    absolute += " " + a
                    if (v != nil) {
                        if (n == 0) {
                            absolute += "=" + v
                        } else if (n == 1) {
                            absolute += "=\'" + v + "\'"
                        } else if (n == 2) {
                            absolute += "=\"" + v + "\""
                        }
                        
                    }
                }
            }
            if (closed) {
                absolute += "/"
            }
            absolute += ">"
            absoluteRaw = Array(absolute.utf8).map { CChar(bitPattern: $0) }
        }
    }
}

private class BaliseFactory {
    
    static func createBalises(html : String) -> ([CChar], [Balise]) {
        var output : [Balise] = []
        
        let stateSearchBaliseOpened : Int = 1
        let stateSearchBaliseClosed : Int = 2

        var i = 0
        var indexPrevWanted = 0
        var indexWanted = 0
        var wanted = stateSearchBaliseOpened
        var buffer : [CChar] = Array(html.utf8).map { CChar(bitPattern: $0) }
        while (i < buffer.count) {
            //Jump double quotes
            if (UtilsBalise.isDoubleQuotes(buffer[i]) && wanted == stateSearchBaliseClosed) {
                i += 1
                while (i < buffer.count && !UtilsBalise.isDoubleQuotes(buffer[i])) {
                    i += 1
                }
                i += 1
            }
                //Jump quotes
            else if (UtilsBalise.isQuotes(buffer[i]) && wanted == stateSearchBaliseClosed) {
                i += 1
                while (i < buffer.count && !UtilsBalise.isQuotes(buffer[i])) {
                    i += 1
                }
                i += 1
            }
            else {
                //Manage script
                if (output.last != nil && output.last!.type == "script" && !output.last!.closed) {
                    if (UtilsBalise.isBaliseStart(buffer[i]) && wanted == stateSearchBaliseOpened &&
                        i + 1 < buffer.count && UtilsBalise.isClosed(buffer[i + 1])) {
                        indexPrevWanted = i
                        wanted = stateSearchBaliseClosed
                    } else if (UtilsBalise.isBaliseEnd(buffer[i]) && wanted == stateSearchBaliseClosed) {
                        indexWanted = i + 1
                        
                        let subBufferStr = UtilsBalise.extract(buffer, indexPrevWanted, indexWanted)
                        if (subBufferStr != nil) {
                            //Get script between balises
                            let b1 = output.last!
                            output.append(Balise(absolute: subBufferStr!, externalIndex : indexPrevWanted))
                            let b2 = output.last!
                            let extracted = UtilsBalise.extract(buffer, b1.externalIndex + b1.absoluteRaw.count, b2.externalIndex)
                            if (extracted != nil) {
                                b1.contain = extracted!
                            }
                            b1.closedBalise = b2
                            b2.openedBalise = b1
                        }
                        wanted = stateSearchBaliseOpened
                    }
                }
                //Other
                else if (UtilsBalise.isBaliseStart(buffer[i]) && wanted == stateSearchBaliseOpened) {
                    indexPrevWanted = i
                    wanted = stateSearchBaliseClosed
                } else if (UtilsBalise.isBaliseEnd(buffer[i]) && wanted == stateSearchBaliseClosed) {
                    indexWanted = i + 1
                    let subBufferStr = UtilsBalise.extract(buffer, indexPrevWanted, indexWanted)
                    if (subBufferStr != nil) {
                        output.append(Balise(absolute: subBufferStr!, externalIndex : indexPrevWanted))
                        let bLast = output.last!
                        if (bLast.type == "a" && bLast.opened) {
                            //print("test a: \(bLast.absolute)")
                            bLast.initAttr()
                        }
                        /*if (bLast.type == "div" && bLast.opened) {
                            bLast.initAttr()
                        }*/
                        //Chercher les balises ouvrantes et fermantes
                        if (!bLast.opened && bLast.closed) {
                            var i = 1
                            while (i < output.count) {
                                let bTmp = output[output.count - i - 1]
                                if (bTmp.type == bLast.type && bTmp.opened && !bTmp.closed && bTmp.closedBalise == nil) {
                                    bTmp.closedBalise = bLast
                                    bLast.openedBalise = bTmp
                                    break
                                }
                                i += 1
                            }
                        }
                        //Chercher les balises parentes
                        var i = 1
                        while (i < output.count) {
                            let bTmp = output[output.count - i - 1]
                            if (bTmp.type != bLast.type && bTmp.opened && !bTmp.closed && bTmp.closedBalise == nil) {
                                bLast.parentBalise = bTmp
                                break
                            }
                            i += 1
                        }
                    }
                    wanted = stateSearchBaliseOpened
                }
                i += 1
            }
        }
        return (buffer, output)
    }
    
    static func createBalises(data : Data) -> ([CChar], [Balise]) {
        let str = data.utf8EncodedString
        if (str != nil) {
            print("utf8EncodedString")
            return createBalises(html: str!)
        } else if (str == nil) {
            let str2 : String? = String(data: data, encoding: String.Encoding.ascii)
            if (str2 != nil) {
                print("String.Encoding.ascii")
                return createBalises(html: str2!)
            }
        }
        return ([], [])
    }
    
}


class RestWebCache : NSObject {
    
    public static func searchInSearchEngineIfBlacklistedResult(searchEngineName : String, url: String) -> Bool {

        var ret = false
        RestRequester.makeHTTPGetRequest(path: url, isJsonResponse: false, onCompletion: { (err, res) in
            if (err != nil) {
                ret = true
                return
            }
            let data : Data? = res as! Data?
            if (data != nil) {
                ret = self.findLink(searchEngine: searchEngineName, data: data!) != nil
                return
            }
            ret = true
        }, onTimeout: {
            
        })
        return ret
    }
    
    private static func decodeUrl(_ url : String) -> String {
        var decodedUrl = url.replacingOccurrences(of: "%21", with: "!")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%23", with: "#")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%24", with: "$")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%26", with: "&")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%27", with: "\'")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%28", with: "(")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%29", with: ")")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%2a", with: "*")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%2b", with: "+")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%2c", with: ",")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%2f", with: "/")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%3a", with: ":")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%3b", with: ";")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%3d", with: "=")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%3f", with: "?")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%40", with: "@")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%5b", with: "[")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%5d", with: "]")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%20", with: " ")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%25", with: "%")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%2d", with: "-")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%2e", with: ".")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%3c", with: "<")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%3e", with: ">")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%5c", with: "\\")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%5e", with: "^")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%5f", with: "_")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%60", with: "`")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%7b", with: "{")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%7c", with: "|")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%7d", with: "}")
        decodedUrl = decodedUrl.replacingOccurrences(of: "%7e", with: "~")
        return decodedUrl
    }
    
    private static func resolveSearch(_ urlSearch : String) -> (String, Bool) {
        
        //Google / Yahoo
        if (!(urlSearch.contains("/url") || urlSearch.contains("r.search.yahoo.com"))) {
            return (urlSearch, false)
        }
            
        let gUrlArray : [CChar] = Array(RestWebCache.decodeUrl(urlSearch).utf8).map { CChar(bitPattern: $0) }
        if (gUrlArray.count > 10) {
            var i = 4
            /*if (gUrlArray[0] == UtilsBalise.getCChar("/") &&
                gUrlArray[1] == UtilsBalise.getCChar("u") &&
                gUrlArray[2] == UtilsBalise.getCChar("r") &&
                gUrlArray[3] == UtilsBalise.getCChar("l")) {
                i = 4
            }*/
            var start = 0
            while (i < gUrlArray.count) {
                if (i + 8 < gUrlArray.count &&
                    gUrlArray[i] == UtilsBalise.getCChar("h") &&
                    gUrlArray[i+1] == UtilsBalise.getCChar("t") &&
                    gUrlArray[i+2] == UtilsBalise.getCChar("t") &&
                    gUrlArray[i+3] == UtilsBalise.getCChar("p")) {
                    if (gUrlArray[i+4] == UtilsBalise.getCChar("s")) {
                        start = i + 8
                    } else {
                        start = i + 7
                    }
                    i = start
                    while (i < gUrlArray.count) {
                        if (gUrlArray[i] == UtilsBalise.getCChar("/")) {
                            return (UtilsBalise.extract(gUrlArray, start, i)!, true)
                        }
                        i += 1
                    }
                }
                i += 1
            }
        }
        if (gUrlArray.count > 1) {
            if (gUrlArray[0] == UtilsBalise.getCChar("/")) {
                return (urlSearch, false)
            }
        }
        return (urlSearch, true)
    }
    
    private static func findLink(searchEngine: String, data : Data) -> String? {
        
        var (html, output) : ([CChar], [Balise]) = BaliseFactory.createBalises(data: data)

        //var divs : [String : [Balise]] = [:]
        var urls : [String] = []
        for elem in output {
            if (elem.type == "a" && elem.opened) {
                let hrefAttr = elem.attrs["href"]
                if (hrefAttr != nil) {
                    var (href, _) = hrefAttr!
                    var (resolvedHref, valid) = resolveSearch(href)
                    print("balise a : \(href) -> \(resolvedHref)")
                    if (valid == true) {
                        //var parentBalise = elem.parentBalise
                        //while (parentBalise != nil) {
                        //    if (parentBalise!.type == "div") {
                        //        if (divs[resolvedHref] == nil) {
                        //            divs[resolvedHref] = [parentBalise!]
                                    urls.append(resolvedHref)
                        //        } else {
                        //            divs[resolvedHref]!.append(parentBalise!)
                        //        }
                        //        parentBalise!.changeAttrs(attr : "href", value : href, nbQuotes : 2)
                        //        break
                        //    }
                        //    parentBalise = parentBalise!.parentBalise
                        //}
                    }
                }
            }
        }
        var countDivHidden = 0
        var result : [Bool] = BlackListSingleton.sharedInstance.areBlackListed(hostsTesting: urls)
        var i = 0
        while (i < urls.count) {
            if (result[i] == true) {
                //Pour cacher une div contenant une balise a avec une url blacklistée
                /*let list : [Balise] = divs[urls[i]]!
                var j = 0
                while (j < list.count) {
                    list[j].changeAttrs(attr : "style", value : "visibility:hidden;", nbQuotes : 2)
                    j += 1
                }*/
                countDivHidden += 1
            }
            i += 1
        }
        
        html += [0]
        let htmlStr = String(cString: html, encoding: String.Encoding.utf8)
        if (htmlStr != nil) {
            print("")
            print("")
            print("\(htmlStr!)")
            print("")
            print("")
            print("")
        }
        
        if (countDivHidden == 0) {
            return nil
        }

        /*var offset = 0
        for elem in output {
            if (elem.type == "div" && elem.opened) {
                let styleAttr = elem.attrs["style"]
                if (styleAttr != nil) {
                    let (visible, _) = styleAttr!
                    if (visible == "visibility:hidden;") {
                        html = Array(html[0..<elem.externalIndex + offset])
                            + elem.absoluteRaw
                            + Array(html[(elem.externalIndex + offset + elem.originalSize)..<html.count])
                        offset += elem.absoluteRaw.count - elem.originalSize
                    }
                }
            }
        }*/
        
        /*html += [0]
        let htmlStr = String(cString: html, encoding: String.Encoding.utf8)
        if (htmlStr != nil) {
            print("")
            print("")
            print("\(htmlStr!)")
            print("")
            print("")
            print("")
        }
        return htmlStr*/
        return ""
    }
}
