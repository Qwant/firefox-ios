// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents

@available(iOS 18.0, *)
@AssistantEntity(schema: .browser.tab)
struct TabEntity: AppEntity {
    let id: String
    var url: URL?
    var name: String
    var isPrivate: Bool

    var displayTitle: String {
        guard url == nil else { return "" }
        return isPrivate ? .QwantAppIntents.PrivateTab : .QwantAppIntents.RegularTab
    }

    static var defaultQuery = TabQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            image: DisplayRepresentation
                .Image(systemName: url == nil ? "rectangle.stack.badge.plus" : "rectangle.stack")
        )
    }

    static var NewNormalTab: TabEntity {
        let entity = TabEntity(id: "new_normal_tab")
        entity.name = .QwantAppIntents.NewRegularTab
        entity.isPrivate = false
        return entity
    }

    static var NewPrivateTab: TabEntity {
        let entity = TabEntity(id: "new_private_tab")
        entity.name = .QwantAppIntents.NewPrivateTab
        entity.isPrivate = true
        return entity
    }
}

@available(iOS 18.0, *)
extension TabEntity {
    struct TabQuery: EntityStringQuery, EntityQuery {
        @Dependency(key: "TabManager")
        var tabManager: TabManager

        @MainActor
        func entities(for identifiers: [String]) async throws -> [TabEntity] {
            var entities: [TabEntity] = []
            for id in identifiers {
                entities += tabManager.tabs.filter { $0.id == id }.map(\.entity)
                if id == TabEntity.NewNormalTab.id { entities.append(TabEntity.NewNormalTab) }
                if id == TabEntity.NewPrivateTab.id { entities.append(TabEntity.NewPrivateTab) }
            }
            return entities
        }

        @MainActor
        func suggestedEntities() async throws -> [TabEntity] {
            let newTabs = [TabEntity.NewNormalTab, TabEntity.NewPrivateTab]
            let activeTabs = tabManager.normalActiveTabs.prefix(10).map(\.entity)
            return activeTabs.isEmpty ? newTabs : activeTabs
        }

        @MainActor
        func entities(matching string: String) async throws -> [TabEntity] {
            let matchingTabs = tabManager.tabs.filter { $0.id == string }.map(\.entity)
            return matchingTabs.isEmpty ? [TabEntity.NewNormalTab] : matchingTabs
        }
    }
}

@available(iOS 18.0, *)
extension Tab: @unchecked Sendable {
    public var id: String {
        return tabUUID
    }

    var entity: TabEntity {
        let entity = TabEntity(id: id)
        entity.url = url
        entity.name = title ?? url?.normalizedHost ?? "Tab with no name"
        entity.isPrivate = isPrivate
        return entity
    }
}
