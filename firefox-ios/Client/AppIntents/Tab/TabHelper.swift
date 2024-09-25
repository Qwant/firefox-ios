// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

struct TabHelper {
    var tabManager: TabManager

    func openWithinExistingTab(url: URL, tab: Tab) {
        tabManager.selectTab(tab)
        let request = URLRequest(url: url)
        tab.loadRequest(request)
    }

    func openWithinNewTab(url: URL, isPrivate: Bool) {
        let privateQuery = "private=\(isPrivate ? "true" : "false")"
        let urlQuery = "url=\(url.absoluteString)"
        let queries = [urlQuery, privateQuery].compactMap { $0 }.joined(separator: "&")
        let scheme = "qwant://open-url?\(queries)"
        DefaultApplicationHelper().open(URL(string: scheme)!)
    }
}
