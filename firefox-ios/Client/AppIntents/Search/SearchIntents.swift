// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.search)
struct SearchIntent: ShowInAppSearchResultsIntent {
    @Parameter
    var criteria: StringSearchCriteria
    static var openAppWhenRun = true
    static var searchScopes: [StringSearchScope] = [.general]

    @MainActor
    func perform() async throws -> some IntentResult {
        let scheme = "qwant://open-text?text=\(criteria.term)"
        DefaultApplicationHelper().open(URL(string: scheme)!)
        return .result()
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.findOnPage)
struct FindOnPageIntent: AppIntent {
    @Dependency(key: "TabManager")
    var tabManager: TabManager
    @Parameter
    var tab: TabEntity
    @Parameter
    var searchPhrase: String
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let tab = tabManager.getTabForUUID(uuid: tab.id)
        tabManager.selectTab(tab)
        let scheme = "qwant://deep-link?url=/find-in-page/\(searchPhrase)"
        DefaultApplicationHelper().open(URL(string: scheme)!)
        return .result()
    }
}
