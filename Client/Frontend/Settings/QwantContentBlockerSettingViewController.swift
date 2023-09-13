// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import MessageUI
import Shared
import Common

class QwantContentBlockerSettingViewController: SettingsTableViewController {
    let prefs: Prefs
    var currentBlockingStrength: QwantBlockingStrength

    init(prefs: Prefs,
         isShownFromSettings: Bool = true) {
        self.prefs = prefs

        currentBlockingStrength = QwantBlockingStrength.currentStrength(from: prefs)
        
        super.init(style: .grouped)
        
        self.title = .QwantTrackingProtection.GlobalProtection

        if !isShownFromSettings {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(done))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.reloadData()
    }
    
    override func generateSettings() -> [SettingSection] {
        let protectionLevelSetting: [CheckmarkSetting] = QwantBlockingStrength.allCases.map { option in
            let id = QwantBlockingStrength.accessibilityId(for: option)
            let setting = CheckmarkSetting(
                title: NSAttributedString(string: option.settingTitle),
                style: .rightSide,
                subtitle: NSAttributedString(string: option.settingSubtitle),
                accessibilityIdentifier: id,
                isChecked: { return option == self.currentBlockingStrength },
                onChecked: {
                    self.currentBlockingStrength = option
                    if let strength = option.toBlockingStrength {
                        self.prefs.setString(strength.rawValue, forKey: ContentBlockingConfig.Prefs.StrengthKey)
                    }
                    self.prefs.setBool(option != .deactivated, forKey: ContentBlockingConfig.Prefs.EnabledKey)

                    QwantTabContentBlocker.prefsChanged()
                    self.tableView.reloadData()
            })
            
            return setting
        }
        
        let firstSectionTitle = NSAttributedString(string: .TrackingProtectionOptionProtectionLevelTitle)
        let optionalFooterTitle = NSAttributedString(string: .TrackingProtectionLevelFooter)
        let firstSection = SettingSection(title: firstSectionTitle, footerTitle: optionalFooterTitle, children: protectionLevelSetting)

        let secondSectionTitle = NSAttributedString(string: .QwantTrackingProtection.Help)
        let secondSection = SettingSection(title: secondSectionTitle, children: [
            HomepageSetting(),
            FeedbackSetting(prefs: prefs, theme: themeManager.currentTheme, mailComposeDelegate: self)
        ])
        
        return [firstSection, secondSection]
    }
    
    // The first section header gets a More Info link
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let _defaultFooter = super.tableView(tableView, viewForFooterInSection: section) as? ThemedTableSectionHeaderFooterView
        guard let defaultFooter = _defaultFooter else {
            return _defaultFooter
        }
        
        if currentBlockingStrength == .strict {
            return defaultFooter
        }
        
        return nil
    }

    @objc
    func done() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension QwantContentBlockerSettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

class HomepageSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: .QwantTrackingProtection.About, attributes: [NSAttributedString.Key.foregroundColor: theme.colors.textPrimary])
    }
    
    override var url: URL? {
        return URL(string: "https://about.qwant.com/extension")
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        guard let url = self.url else { return }
        delegate?.settingsOpenURLInNewTab(url)
    }
}

class FeedbackSetting: Setting {
    private struct Constants {
        static let to = "extensions@qwant.com"
        static let subject = "[Qwant VIPrivacy] [iOS - \(AppInfo.appVersion)]"
        static let body = "\(AppName.longName) \(AppInfo.appVersion) (\(AppInfo.buildNumber))"
    }
    
    private let prefs: Prefs
    weak var mailComposeDelegate: MFMailComposeViewControllerDelegate?
    
    private lazy var mailtoLinkHandler = MailtoLinkHandler()
    private lazy var mailtoMetadata = MailToMetadata(to: Constants.to, headers: [
        "subject": Constants.subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
        "body": Constants.body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!])
    
    init(prefs: Prefs,
         theme: Theme,
         mailComposeDelegate: MFMailComposeViewControllerDelegate?) {
        self.prefs = prefs
        self.mailComposeDelegate = mailComposeDelegate
        let title = NSAttributedString(string: .QwantTrackingProtection.Experience, attributes: [NSAttributedString.Key.foregroundColor: theme.colors.textPrimary])
        super.init(title: title)
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        sendMail(navigationController)
    }
    
    override var hidden: Bool {
        return !canSendMail()
    }
    
    private func customMailURL() -> URL? {
        if let mailScheme = prefs.stringForKey(PrefsKeys.KeyMailToOption), mailScheme != "mailto",
           let provider = mailtoLinkHandler.mailSchemeProviders[mailScheme],
           let mailURL = provider.newEmailURLFromMetadata(mailtoMetadata) {
            return mailURL
        }
        return nil
    }
    
    private func canSendMail() -> Bool {
        if let mailURL = customMailURL() {
            return UIApplication.shared.canOpenURL(mailURL) || MFMailComposeViewController.canSendMail()
        }
        return MFMailComposeViewController.canSendMail()
    }
    
    private func sendMail(_ navigationController: UINavigationController?) {
        if let mailURL = customMailURL(), UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:])
        } else {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = mailComposeDelegate
            
            // Configure the fields of the interface.
            composeVC.setToRecipients([Constants.to])
            composeVC.setSubject(Constants.subject)
            composeVC.setMessageBody(Constants.body, isHTML: false)
            
            // Present the view controller modally.
            navigationController?.present(composeVC, animated: true, completion: nil)
        }
    }
}
