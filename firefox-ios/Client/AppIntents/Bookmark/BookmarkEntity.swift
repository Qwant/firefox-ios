// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents
import Common
import MozillaAppServices

@available(iOS 18.0, *)
@AssistantEntity(schema: .browser.bookmark)
struct BookmarkEntity: IndexedEntity {
    var id: String
    var name: String
    var url: URL

    static var defaultQuery = BookmarkQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: url.normalizedHost ?? url.host() ?? "")
        )
    }
}

@available(iOS 18.0, *)
extension BookmarkEntity {
    struct BookmarkQuery: EntityQuery {
        @MainActor
        func entities(for identifiers: [BookmarkEntity.ID]) async throws -> [BookmarkEntity] {
            return try await withCheckedThrowingContinuation { continuation in
                let profile = BrowserProfile(localName: "profile")
                profile.reopen()
                profile.places.getBookmarksTree(
                    rootGUID: BookmarkRoots.MobileFolderGUID,
                    recursive: false
                ).uponQueue(.main) { result in
                    let folder = result.successValue as? BookmarkFolderData
                    let childs = folder?.children as? [BookmarkItemData] ?? []
                    let entities = childs.map(\.entity)
                    let subEntities = entities.filter { entity in
                        return identifiers.contains(entity.id)
                    }
                    profile.shutdown()
                    continuation.resume(returning: subEntities)
                }
            }
        }

        @MainActor
        func suggestedEntities() async throws -> [BookmarkEntity] {
            return try await withCheckedThrowingContinuation { continuation in
                let profile = BrowserProfile(localName: "profile")
                profile.reopen()
                profile.places.getBookmarksTree(
                    rootGUID: BookmarkRoots.MobileFolderGUID,
                    recursive: false
                ).uponQueue(.main) { result in
                    let folder = result.successValue as? BookmarkFolderData
                    let childs = folder?.children as? [BookmarkItemData] ?? []
                    profile.shutdown()
                    continuation.resume(returning: childs.prefix(10).map(\.entity))
                }
            }
        }
    }
}

@available(iOS 18.0, *)
extension BookmarkItemData: @unchecked @retroactive Sendable {
    var entity: BookmarkEntity {
        let entity = BookmarkEntity(id: guid)
        entity.name = title
        entity.url = URL(string: url)!
        return entity
    }
}
