// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Shared

private let SectionToggles = 0
private let SectionButton = 1
private let NumberOfSections = 2

class QwantZapSettingsTableViewController: ThemedTableViewController {
    fileprivate var zapButton: UITableViewCell?

    var profile: Profile!
    var tabManager: TabManager!

    fileprivate lazy var zap: QwantZap = {
        QwantZap(profile: profile, tabManager: tabManager)
    }()

    fileprivate var zapButtonEnabled = true {
        didSet {
            zapButton?.textLabel?.textColor = zapButtonEnabled ? themeManager.currentTheme.colors.textWarning : themeManager.currentTheme.colors.textDisabled
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        zapButtonEnabled = zap.enabledClearables.count != 0

        title = .QwantZap.ZapSettings

        tableView.register(ThemedTableSectionHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: ThemedTableSectionHeaderFooterView.cellIdentifier)

        let footer = ThemedTableSectionHeaderFooterView(frame: CGRect(width: tableView.bounds.width,
                                                                      height: SettingsUX.TableViewHeaderFooterHeight))
        footer.applyTheme(theme: themeManager.currentTheme)
        tableView.tableFooterView = footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell()
        cell.applyTheme(theme: themeManager.currentTheme)

        if indexPath.section == SectionToggles {
            cell.textLabel?.text = zap.clearables[indexPath.item].clearable.label
            cell.textLabel?.numberOfLines = 0
            let control = UISwitch()
            control.onTintColor = themeManager.currentTheme.colors.actionPrimary
            control.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            control.isOn = zap.toggles[indexPath.item]
            cell.accessoryView = control
            cell.selectionStyle = .none
            control.tag = indexPath.item
        } else {
            assert(indexPath.section == SectionButton)
            cell.textLabel?.text = .QwantZap.ZapAlertOK
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = zap.enabledClearables.count != 0 ? themeManager.currentTheme.colors.textWarning : themeManager.currentTheme.colors.textDisabled
            cell.accessibilityTraits = UIAccessibilityTraits.button
            cell.accessibilityIdentifier = "Zap now"
            zapButton = cell
        }

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return NumberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SectionToggles {
            return zap.clearables.count
        }
        assert(section == SectionButton)
        return 1
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SectionButton {
            // Highlight the button only if it's enabled.
            return zapButtonEnabled
        }
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SectionButton {

            QwantTracking.track(.zap_settings(isIntention: true))
            let alert = UIAlertController(title: .QwantZap.ZapAlertTitle, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: .QwantZap.ZapAlertOK, style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                QwantTracking.track(.zap_settings(isIntention: false))
                let viewController = ZapAnimationController(zap: self.zap)
                viewController.onFinish = { [weak viewController] in
                    viewController?.willMove(toParent: nil)
                    viewController?.view.removeFromSuperview()
                    viewController?.removeFromParent()

                    // Disable the Clear Private Data button after it's clicked.
                    self.zapButtonEnabled = false
                    tableView.deselectRow(at: indexPath, animated: true)

                    SimpleToast().showAlertWithText(.QwantZap.ZapToast,
                                                    bottomContainer: tableView,
                                                    theme: self.themeManager.currentTheme)
                }

                self.addChild(viewController)
                viewController.view.frame = self.view.bounds
                self.view.addSubview(viewController.view)
                viewController.didMove(toParent: self)
            }))
            alert.addAction(UIAlertAction(title: .QwantZap.ZapAlertCancel, style: .cancel, handler: { _ in
                tableView.deselectRow(at: indexPath, animated: true)
            }))
            present(alert, animated: true)
        }
    }

    @objc func switchValueChanged(_ toggle: UISwitch) {
        zap.toggles[toggle.tag] = toggle.isOn

        // Dim the clear button if no clearables are selected.
        zapButtonEnabled = zap.toggles.contains(true)
    }
}
