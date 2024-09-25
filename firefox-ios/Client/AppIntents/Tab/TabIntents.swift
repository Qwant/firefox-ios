// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.openURLInTab)
struct OpenURLInTabIntent: AppIntent {
    @Dependency(key: "TabManager")
    var tabManager: TabManager
    @Parameter
    var tab: TabEntity
    @Parameter
    var url: URL
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let helper = TabHelper(tabManager: tabManager)
        if let tab = tabManager.getTabForUUID(uuid: tab.id) {
            helper.openWithinExistingTab(url: url, tab: tab)
        } else {
            helper.openWithinNewTab(url: url, isPrivate: tab.isPrivate)
        }
        return .result()
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.closeTabs)
struct CloseTabsIntent: AppIntent {
    @Dependency(key: "TabManager")
    var tabManager: TabManager
    @Parameter
    var target: [TabEntity]

    @MainActor
    func perform() async throws -> some IntentResult {
        let tabs = target.compactMap { tabManager.getTabForUUID(uuid: $0.id) }
        tabManager.removeTabs(tabs)
        return .result()
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.createTab)
struct CreateTabIntent: AppIntent {
    @Parameter
    var url: URL?
    @Parameter
    var isPrivate: Bool
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some ReturnsValue<TabEntity> {
        let privateQuery = "private=\(isPrivate ? "true" : "false")"
        var urlQuery: String?
        if let url = url?.absoluteString {
            urlQuery = "url=\(url)"
        }

        let queries = [urlQuery, privateQuery].compactMap { $0 }.joined(separator: "&")
        let scheme = "qwant://open-url?\(queries)"
        DefaultApplicationHelper().open(URL(string: scheme)!)
        let entity = TabEntity(id: UUID().uuidString)
        entity.name = url?.normalizedHost ?? "Tab"
        entity.isPrivate = isPrivate
        return .result(value: entity)
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.switchTab)
struct SwitchToTabIntent: OpenIntent {
    @Dependency(key: "TabManager")
    var tabManager: TabManager
    @Parameter
    var target: TabEntity
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        let tab = tabManager.getTabForUUID(uuid: target.id)
        tabManager.selectTab(tab)
        return .result()
    }
}
