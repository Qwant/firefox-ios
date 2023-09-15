// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit
import Shared

extension BlockerStatus {
    var image: UIImage {
        switch self {
            case .blocking, .noBlockedURLs:
                return UIImage(imageLiteralResourceName: "tracking_protection_on")
            case .safelisted:
                return UIImage(imageLiteralResourceName: "tracking_protection_off")
            case .disabled:
                return UIImage(imageLiteralResourceName: "tracking_protection_disabled")
        }
    }
    
    func badgeValue(basedOn value: Int) -> Int {
        switch self {
            case .blocking, .noBlockedURLs: return value
            case .safelisted, .disabled: return 0
        }
    }
}

enum QwantBlocklistFileName: String, CaseIterable {
    case all_in_1_standard = "standard"
    case all_in_1_strict = "strict"

    var filename: String { return self.rawValue }
    
    static var basic: [QwantBlocklistFileName] { return [.all_in_1_standard] }
    static var strict: [QwantBlocklistFileName] { return QwantBlocklistFileName.allCases }
    
    static func listsForMode(strict: Bool) -> [QwantBlocklistFileName] {
        return strict ? QwantBlocklistFileName.strict : QwantBlocklistFileName.basic
    }
}

class QwantContentBlocker {
    var safelistedDomains = QwantSafelistedDomains()
    let ruleStore: WKContentRuleListStore = WKContentRuleListStore.default()
    var blockImagesRule: WKContentRuleList?
    var setupCompleted = false
    
    static let shared = QwantContentBlocker()
    
    private init() {
        let blockImages = NoImageModeDefaults.Script
        ruleStore.compileContentRuleList(forIdentifier: NoImageModeDefaults.ScriptName, encodedContentRuleList: blockImages) { rule, error in
            assert(rule != nil && error == nil)
            self.blockImagesRule = rule
        }
        
        // Read the safelist at startup
        if let list = readSafelistFile() {
            safelistedDomains.domainSet = Set(list)
        }
        
        QwantTPStatsBlocklistChecker.shared.startup()
        
        removeOldListsByDateFromStore() {
            self.removeOldListsByNameFromStore() {
                self.compileListsNotInStore {
                    self.setupCompleted = true
                    NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
                }
            }
        }
    }
    
    func prefsChanged() {
        // This class func needs to notify all the active instances of ContentBlocker to update.
        NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Function to install or remove TP for a tab
    func setupTrackingProtection(forTab tab: ContentBlockerTab, isEnabled: Bool, rules: [QwantBlocklistFileName]) {
        removeTrackingProtection(forTab: tab)
        QwantTPStatsBlocklistChecker.shared.reload(blocklists: rules)
        
        if !isEnabled {
            return
        }
        
        for list in rules {
            let name = list.filename
            ruleStore.lookUpContentRuleList(forIdentifier: name) { rule, error in
                guard let rule = rule else {
                    let msg = "lookUpContentRuleList for \(name): \(error ?? "empty rules")"
                    print("Content blocker [\(name)] error: \(msg)")
                    return
                }
                self.add(contentRuleList: rule, toTab: tab)
            }
        }
    }
    
    private func removeTrackingProtection(forTab tab: ContentBlockerTab) {
        tab.currentWebView()?.configuration.userContentController.removeAllContentRuleLists()
        
        // Add back the block images rule (if needed) after having removed all rules.
        if let rule = blockImagesRule, tab.imageContentBlockingEnabled() {
            add(contentRuleList: rule, toTab: tab)
        }
    }
    
    private func add(contentRuleList: WKContentRuleList, toTab tab: ContentBlockerTab) {
        tab.currentWebView()?.configuration.userContentController.add(contentRuleList)
    }
    
    func noImageMode(enabled: Bool, forTab tab: ContentBlockerTab) {
        guard let rule = blockImagesRule else { return }
        
        if enabled {
            add(contentRuleList: rule, toTab: tab)
        } else {
            tab.currentWebView()?.configuration.userContentController.remove(rule)
        }
        
        // Async required here to ensure remove() call is processed.
        DispatchQueue.main.async() { [weak tab] in
            tab?.currentWebView()?.evaluateJavascriptInDefaultContentWorld("window.__firefox__.NoImageMode.setEnabled(\(enabled))")
        }
    }
}

// MARK: Initialization code
// The rule store can compile JSON rule files into a private format which is cached on disk.
// On app boot, we need to check if the ruleStore's data is out-of-date, or if the names of the rule files
// no longer match. Finally, any JSON rule files that aren't in the ruleStore need to be compiled and stored in the
// ruleStore.
extension QwantContentBlocker {
    private func loadJsonFromBundle(forResource file: String, completion: @escaping (_ jsonString: String) -> Void) {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: file, ofType: "json"),
                  let source = try? String(contentsOfFile: path, encoding: .utf8) else {
                assert(false)
                return
            }
            
            DispatchQueue.main.async {
                completion(source)
            }
        }
    }
    
    private func lastModifiedSince1970(forFileAtPath path: String) -> Date? {
        do {
            let url = URL(fileURLWithPath: path)
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let date = attr[FileAttributeKey.modificationDate] as? Date else { return nil }
            return date
        } catch {
            return nil
        }
    }
    
    private func dateOfMostRecentBlockerFile() -> Date? {
        let blocklists = QwantBlocklistFileName.allCases
        
        return blocklists.reduce(Date(timeIntervalSince1970: 0)) { result, list in
            guard let path = Bundle.main.path(forResource: list.filename, ofType: "json") else { return result }
            if let date = lastModifiedSince1970(forFileAtPath: path) {
                return date > result ? date : result
            }
            return result
        }
    }
    
    func removeAllRulesInStore(completion: @escaping () -> Void) {
        ruleStore.getAvailableContentRuleListIdentifiers { available in
            guard let available = available else {
                completion()
                return
            }
            let deferreds: [Deferred<Void>] = available.map { filename in
                let result = Deferred<Void>()
                self.ruleStore.removeContentRuleList(forIdentifier: filename) { _ in
                    result.fill(())
                }
                return result
            }
            all(deferreds).uponQueue(.main) { _ in
                completion()
            }
        }
    }
    
    // If any blocker files are newer than the date saved in prefs,
    // remove all the content blockers and reload them.
    func removeOldListsByDateFromStore(completion: @escaping () -> Void) {
        
        guard let fileDate = dateOfMostRecentBlockerFile() else {
            completion()
            return
        }
        
        guard let prefsNewestDate = UserDefaults.standard.object(forKey: "blocker-file-date") as? Date else {
            UserDefaults.standard.set(fileDate, forKey: "blocker-file-date")
            completion()
            return
        }
        
        if fileDate <= prefsNewestDate {
            completion()
            return
        }
        
        UserDefaults.standard.set(fileDate, forKey: "blocker-file-date")
        
        removeAllRulesInStore() {
            completion()
        }
    }
    
    func removeOldListsByNameFromStore(completion: @escaping () -> Void) {
        var noMatchingIdentifierFoundForRule = false
        
        ruleStore.getAvailableContentRuleListIdentifiers { available in
            guard let available = available else {
                completion()
                return
            }
            
            let blocklists = QwantBlocklistFileName.allCases.map { $0.filename }
            for listOnDisk in blocklists {
                // If any file from the list on disk is not installed, remove all the rules and re-install them
                if !available.contains(where: { $0 == listOnDisk}) {
                    noMatchingIdentifierFoundForRule = true
                    break
                }
            }
            if !noMatchingIdentifierFoundForRule {
                completion()
                return
            }
            
            self.removeAllRulesInStore {
                completion()
            }
        }
    }
    
    func compileListsNotInStore(completion: @escaping () -> Void) {
        let blocklists = QwantBlocklistFileName.allCases.map { $0.filename }
        let deferreds: [Deferred<Void>] = blocklists.map { filename in
            let result = Deferred<Void>()
            ruleStore.lookUpContentRuleList(forIdentifier: filename) { contentRuleList, error in
                if contentRuleList != nil {
                    result.fill(())
                    return
                }
                self.loadJsonFromBundle(forResource: filename) { jsonString in
                    var str = jsonString
                    guard let range = str.range(of: "]", options: String.CompareOptions.backwards) else { return }
                    str = str.replacingCharacters(in: range, with: self.safelistAsJSON() + "]")
                    self.ruleStore.compileContentRuleList(forIdentifier: filename, encodedContentRuleList: str) { rule, error in
                        if let error = error {
                            print("Content blocker [\(filename)] error: \(error)")
                            assert(false)
                        }
                        assert(rule != nil)
                        
                        result.fill(())
                    }
                }
            }
            return result
        }
        
        all(deferreds).uponQueue(.main) { _ in
            completion()
        }
    }
}
