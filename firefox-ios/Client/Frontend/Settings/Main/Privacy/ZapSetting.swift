// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

class ZapSetting: Setting {
    let profile: Profile
    var tabManager: TabManager!
    private weak var settingsDelegate: PrivacySettingsDelegate?

    override var accessoryView: UIImageView? { return SettingDisclosureUtility.buildDisclosureIndicator(theme: theme) }
    override var accessibilityIdentifier: String? { return "ZapSetting" }

    init(settings: SettingsTableViewController,
         settingsDelegate: PrivacySettingsDelegate?) {
        self.profile = settings.profile
        self.tabManager = settings.tabManager
        self.settingsDelegate = settingsDelegate
        super.init(title: NSAttributedString(
            string: .QwantZap.ZapSettings,
            attributes: [NSAttributedString.Key.foregroundColor: settings.themeManager.currentTheme.colors.textPrimary])
        )
    }

    override func onClick(_ navigationController: UINavigationController?) {
        settingsDelegate?.pressedZap()
    }
}
