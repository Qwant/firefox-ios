// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import Storage
import Shared

class QwantSearchTableViewHeader: SiteTableViewHeader, PrivateModeUI {
    override func prepareForReuse() {
        super.prepareForReuse()
        showBorder(for: .top, false)
        showBorder(for: .bottom, false)
    }

    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)

        textLabel?.textColor = theme.colors.omnibar_gray
        textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        showBorder(for: .top, false)
        showBorder(for: .bottom, false)
    }

    func applyUIMode(isPrivate: Bool, theme: Theme) {
        applyTheme(theme: theme)
        backgroundView?.backgroundColor = theme.colors.omnibar_tableViewBackground(isPrivate)
        contentView.backgroundColor = theme.colors.omnibar_tableViewBackground(isPrivate)
    }
}
