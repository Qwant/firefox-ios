// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import AppIntents

@available(iOS 18, *)
struct QwantShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FindOnPageIntent(),
            phrases: [
                "Find on page with \(.applicationName)"
            ],
            shortTitle: "Find on page",
            systemImageName: "text.magnifyingglass"
        )
        AppShortcut(
            intent: ClearHistoryIntent(),
            phrases: [
                "Clear history with \(.applicationName)"
            ],
            shortTitle: "Clear history",
            systemImageName: "trash"
        )
        AppShortcut(
            intent: SearchIntent(),
            phrases: [
                "Search with \(.applicationName)"
            ],
            shortTitle: "Search Web",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenBookmarkIntent(),
            phrases: [
                "Open bookmark with \(.applicationName)"
            ],
            shortTitle: "Open Bookmark",
            systemImageName: "bookmark.fill"
        )
        AppShortcut(
            intent: BookmarkTabIntent(),
            phrases: [
                "Bookmark tab with \(.applicationName)"
            ],
            shortTitle: "Bookmark Tab",
            systemImageName: "bookmark"
        )
        AppShortcut(
            intent: DeleteBookmarksIntent(),
            phrases: [
                "Delete bookmarks with \(.applicationName)"
            ],
            shortTitle: "Delete Bookmarks",
            systemImageName: "bookmark.slash"
        )
        AppShortcut(
            intent: CreateTabIntent(),
            phrases: [
                "Create tab with \(.applicationName)"
            ],
            shortTitle: "Create Tab",
            systemImageName: "rectangle.stack.badge.plus"
        )
        AppShortcut(
            intent: CloseTabsIntent(),
            phrases: [
                "Close tabs with \(.applicationName)"
            ],
            shortTitle: "Close Tabs",
            systemImageName: "rectangle.stack.badge.minus"
        )
        AppShortcut(
            intent: SwitchToTabIntent(),
            phrases: [
                "Switch to tab with \(.applicationName)"
            ],
            shortTitle: "Switch to Tab",
            systemImageName: "checkmark.rectangle.stack"
        )
        AppShortcut(
            intent: OpenURLInTabIntent(),
            phrases: [
                "Open URL with \(.applicationName)"
            ],
            shortTitle: "Open Link",
            systemImageName: "rectangle.stack.badge.plus"
        )
    }
}
