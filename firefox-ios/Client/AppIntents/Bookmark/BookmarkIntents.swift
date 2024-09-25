// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents
import MozillaAppServices

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.deleteBookmarks)
struct DeleteBookmarksIntent: DeleteIntent {
    @Parameter
    var entities: [BookmarkEntity]

    @MainActor
    func perform() async throws -> some IntentResult {
        let profile = BrowserProfile(localName: "profile")
        profile.reopen()
        for entity in entities {
            _ = profile.places.deleteBookmarkNode(guid: entity.id).value
        }
        profile.shutdown()
        return .result()
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.bookmarkURL)
struct BookmarkUrlIntent: AppIntent {
    @Parameter
    var url: URL
    @Parameter
    var name: String?

    @MainActor
    func perform() async throws -> some ReturnsValue<BookmarkEntity> {
        enum BookmarkError: Error {
            case failedToCreate
            case failedToRetrieve
        }
        let title = name ?? url.normalizedHost ?? url.host() ?? "bookmark"

        let id = try await withCheckedThrowingContinuation { continuation in
            let profile = BrowserProfile(localName: "profile")
            profile.reopen()
            profile.places.createBookmark(
                parentGUID: BookmarkRoots.MobileFolderGUID,
                url: url.absoluteString,
                title: title,
                position: 0
            ).uponQueue(.main) { result in
                if result.isSuccess {
                    continuation.resume(returning: result.successValue!)
                } else {
                    continuation.resume(throwing: BookmarkError.failedToCreate)
                }
                profile.shutdown()
            }
        }

        let entity = try await BookmarkEntity.defaultQuery.entities(for: [id]).first
        return .result(value: entity!)
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.bookmarkTab)
struct BookmarkTabIntent: AppIntent {
    @Dependency(key: "TabManager")
    var tabManager: TabManager
    @Parameter
    var name: String?
    @Parameter
    var tab: TabEntity

    func perform() async throws -> some ReturnsValue<BookmarkEntity> {
        enum BookmarkError: Error {
            case failedToCreate
            case failedToRetrieve
        }

        guard let url = tab.url else {
            throw BookmarkError.failedToCreate
        }

        let title = name ?? url.normalizedHost ?? url.host() ?? "bookmark"

        let id = try await withCheckedThrowingContinuation { continuation in
            let profile = BrowserProfile(localName: "profile")
            profile.reopen()
            profile.places.createBookmark(
                parentGUID: BookmarkRoots.MobileFolderGUID,
                url: url.absoluteString,
                title: title,
                position: 0
            ).uponQueue(.main) { result in
                if result.isSuccess {
                    continuation.resume(returning: result.successValue!)
                } else {
                    continuation.resume(throwing: BookmarkError.failedToCreate)
                }
                profile.shutdown()
            }
        }

        let entity = try await BookmarkEntity.defaultQuery.entities(for: [id]).first
        return .result(value: entity!)
    }
}

@available(iOS 18.0, *)
@AssistantIntent(schema: .browser.openBookmark)
struct OpenBookmarkIntent: OpenIntent {
    @Dependency(key: "TabManager")
    var tabManager: TabManager
    @Parameter
    var target: BookmarkEntity
    @Parameter(optionsProvider: TabOptionsProvider())
    var tab: TabEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        let helper = TabHelper(tabManager: tabManager)
        if let tab = tabManager.getTabForUUID(uuid: tab.id) {
            helper.openWithinExistingTab(url: target.url, tab: tab)
        } else {
            helper.openWithinNewTab(url: target.url, isPrivate: tab.isPrivate)
        }
        return .result()
    }

    private struct TabOptionsProvider: DynamicOptionsProvider {
        func results() async throws -> [TabEntity] {
            [TabEntity.NewNormalTab, TabEntity.NewPrivateTab]
        }
    }
}
