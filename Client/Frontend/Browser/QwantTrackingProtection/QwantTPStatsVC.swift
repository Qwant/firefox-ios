// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class QwantTPStatsVC: QwantVIPBaseVC {

    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.Identifier)
        tableView.register(TwoLabelsInlineTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: TwoLabelsInlineTableViewHeaderView.Identifier)
        tableView.rowHeight = UITableView.automaticDimension
        // Set an empty footer to prevent empty cells from appearing in the list.
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    lazy private var placeholderImage: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
    }
    
    lazy private var placeholderLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.l
        label.textAlignment = .center
        label.numberOfLines = 0
    }
    
    lazy private var placeholderButton: UIButton = .build { button in
        button.setTitle(self.viewModel.placeholderButtonTitle, for: .normal)
        button.setImage(UIImage(named: "icon_stats")!, for: .normal)
        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.clipsToBounds = true
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: QwantUX.Spacing.xxxs)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: QwantUX.Spacing.xxxs, bottom: 0, right: 0)
        button.titleLabel?.font = QwantUX.Font.Text.m
        button.addTarget(self, action: #selector(self.reactivateStats), for: .touchUpInside)
    }

    private var viewModel: QwantTPStatsVM
    
    // MARK: - View lifecycle
    
    init(viewModel: QwantTPStatsVM,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.viewModel = viewModel
        super.init(themeManager: themeManager, notificationCenter: notificationCenter)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupConstraints() {
        super.setupConstraints()
        setupStatListView()
        setupPlaceholder()
    }
    
    private func setupStatListView() {
        view.addSubview(tableView)
        
        constraints.append(contentsOf: [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupPlaceholder() {
        view.addSubviews(placeholderLabel, placeholderButton, placeholderImage)
        
        constraints.append(contentsOf: [
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            placeholderImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderImage.topAnchor, constant: -QwantUX.Spacing.xl),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            placeholderButton.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: QwantUX.Spacing.xl),
            placeholderButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            placeholderButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            placeholderButton.heightAnchor.constraint(equalToConstant: QwantUX.SystemDesign.buttonHeight)
        ])
    }
    
    override func updateViewDetails() {
        super.updateViewDetails()
        self.title = viewModel.title
        
        placeholderLabel.text = viewModel.placeholderTextTitle
        placeholderImage.image = viewModel.placeholderImage
        
        tableView.tableHeaderView = TwoCountersInlineView(
            lIcon: UIImage(named: "icon_shield_purple")!,
            lValue: viewModel.statisticsTrackersBlockedFormattedString,
            lTitle: viewModel.statisticsBlockedTrackersTitleString,
            rIcon: UIImage(named: "icon_clock_purple")!,
            rValue: viewModel.statisticsTimeSavedFormattedString,
            rTitle: viewModel.statisticsSavedTimeTitleString)

        applyTheme()
    }

    override func applyTheme() {
        super.applyTheme()

        let theme = themeManager.currentTheme

        tableView.backgroundColor = theme.colors.vip_background
        (tableView.tableHeaderView as? ThemeApplicable)?.applyTheme(theme: theme)
        tableView.reloadData()

        tableView.isHidden = viewModel.shouldShowPlaceholder
        placeholderImage.isHidden = !viewModel.shouldShowPlaceholder
        placeholderLabel.isHidden = !viewModel.shouldShowPlaceholder
        placeholderButton.isHidden = !viewModel.hasDeactivatedStats

        placeholderLabel.textColor = theme.colors.vip_textColor
        placeholderButton.setTitleColor(theme.colors.vip_background, for: .normal)
        placeholderButton.backgroundColor = theme.colors.vip_switchAndButtonTint
    }
}

extension QwantTPStatsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? viewModel.orderedDomains.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.Identifier, for: indexPath) as! ButtonCell
                cell.configureCell(icon: UIImage(named: "icon_stats_red")!,
                                   text: viewModel.deactivateStatsTitle,
                                   color: themeManager.currentTheme.colors.vip_redText)
                cell.backgroundColor = themeManager.currentTheme.colors.vip_sectionColor
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.Identifier, for: indexPath) as! ButtonCell
                cell.configureCell(icon: UIImage(named: "icon_trash")!,
                                   text: viewModel.deleteStatsTitle,
                                   color: themeManager.currentTheme.colors.vip_subtextColor)
                cell.backgroundColor = themeManager.currentTheme.colors.vip_sectionColor
                return cell

            default:
                let cellIdentifier = "TrackerCell"
                var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)

                if cell == nil {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
                }

                guard let cell = cell else {
                    fatalError()
                }

                cell.selectionStyle = .none
                cell.textLabel?.text = viewModel.orderedDomains[indexPath.row].key
                cell.textLabel?.textColor = themeManager.currentTheme.colors.vip_textColor
                cell.textLabel?.font = QwantUX.Font.Text.l
                cell.detailTextLabel?.text = String(describing: viewModel.orderedDomains[indexPath.row].value)
                cell.detailTextLabel?.textColor = themeManager.currentTheme.colors.vip_subtextColor
                cell.detailTextLabel?.font = QwantUX.Font.Text.l
                cell.backgroundColor = themeManager.currentTheme.colors.vip_sectionColor
                return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
            case 1: deactivateStats()
            case 2: deleteStats()
            default: break
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }

        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TwoLabelsInlineTableViewHeaderView.Identifier) as? TwoLabelsInlineTableViewHeaderView else {
            return nil
        }

        headerView.setValues(lValue: viewModel.leftHandSideHeaderTitle, rValue: viewModel.rightHandSideHeaderTitle)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0 }

        return 140
    }
}

extension QwantTPStatsVC {

    private func deleteStats() {
        viewModel.stats.reset()
        updateViewDetails()
        applyTheme()
    }

    private func deactivateStats() {
        let alert = UIAlertController(title: nil, message: viewModel.deactivateStatsMessage, preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: viewModel.deactivateStatsConfirmActionTitle, style: .destructive) { [weak self] _ in
            self?.viewModel.hasDeactivatedStats = true
            self?.updateViewDetails()
            self?.applyTheme()
        }
        let cancel = UIAlertAction(title: viewModel.deactivateStatsCancelActionTitle, style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)

        present(alert, animated: true)
    }

    @objc private func reactivateStats() {
        viewModel.hasDeactivatedStats = false
        updateViewDetails()
        applyTheme()
    }
}
