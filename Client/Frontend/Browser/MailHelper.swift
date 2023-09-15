// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import MessageUI
import Shared

struct MailMetadata {
    let to: String
    let subject: String
    let body: String
}

class MailHelper {
    
    private let prefs: Prefs
    private let metadata: MailMetadata
    weak var mailComposeDelegate: MFMailComposeViewControllerDelegate?
    
    private lazy var mailtoLinkHandler = MailtoLinkHandler()
    private lazy var mailtoMetadata = MailToMetadata(to: metadata.to, headers: [
        "subject": metadata.subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
        "body": metadata.body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!])
    
    init(prefs: Prefs,
         metadata: MailMetadata) {
        self.prefs = prefs
        self.metadata = metadata
    }
    
    private func customMailURL() -> URL? {
        if let mailScheme = prefs.stringForKey(PrefsKeys.KeyMailToOption), mailScheme != "mailto",
           let provider = mailtoLinkHandler.mailSchemeProviders[mailScheme],
           let mailURL = provider.newEmailURLFromMetadata(mailtoMetadata) {
            return mailURL
        }
        return nil
    }
    
    func canSendMail() -> Bool {
        if let mailURL = customMailURL() {
            return UIApplication.shared.canOpenURL(mailURL) || MFMailComposeViewController.canSendMail()
        }
        return MFMailComposeViewController.canSendMail()
    }
    
    func sendMail(_ navigationController: UINavigationController?) {
        if let mailURL = customMailURL(), UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:])
        } else {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = mailComposeDelegate
            
            // Configure the fields of the interface.
            composeVC.setToRecipients([metadata.to])
            composeVC.setSubject(metadata.subject)
            composeVC.setMessageBody(metadata.body, isHTML: false)
            
            // Present the view controller modally.
            navigationController?.present(composeVC, animated: true, completion: nil)
        }
    }
}
