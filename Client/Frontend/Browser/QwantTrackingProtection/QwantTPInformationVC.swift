// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class QwantTPInformationVC: QwantVIPBaseVC {
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        return tableView
    }()
    
    private lazy var footerImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        imageView.image = UIImage(named: "illustration_information")
        imageView.contentMode = .bottom
        return imageView
    }()
    
    private var viewModel: QwantTPInformationVM
    
    // MARK: - View lifecycle
    
    init(viewModel: QwantTPInformationVM,
         and notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.viewModel = viewModel
        super.init(notificationCenter: notificationCenter)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        view.addSubview(tableView)
        
        constraints.append(contentsOf: [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func updateViewDetails() {
        super.updateViewDetails()
        self.title = viewModel.title
        
        tableView.tableFooterView = footerImageView
        applyTheme()
    }
    
    override func applyTheme() {
        super.applyTheme()
        let theme = themeManager.currentTheme

        tableView.backgroundColor = theme.colors.vip_background
        (tableView.tableFooterView as? ThemeApplicable)?.applyTheme(theme: theme)
        tableView.reloadData()
    }

}

extension QwantTPInformationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "OpenExternalWebsiteCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        guard let cell = cell, let type = viewModel.cellType(for: indexPath.row) else {
            fatalError()
        }
        cell.textLabel?.text = type.title
        cell.textLabel?.textColor = themeManager.currentTheme.colors.vip_textColor
        cell.textLabel?.font = QwantUX.Font.Text.l
        cell.accessoryView = type.accessoryView
        cell.backgroundColor = themeManager.currentTheme.colors.vip_sectionColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = viewModel.cellType(for: indexPath.row) else {
            return
        }
        
        let viewController = SettingsContentViewController()
        viewController.settingsTitle = NSAttributedString(string: type.title)
        viewController.url = type.url
        navigationController?.pushViewController(viewController, animated: true)
    }
}
