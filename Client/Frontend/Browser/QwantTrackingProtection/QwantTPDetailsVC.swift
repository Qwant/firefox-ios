// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Common

class QwantTPDetailsVC: UIViewController, Themeable {
    var themeManager: ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: NotificationProtocol
    weak var enhancedTrackingProtectionMenuDelegate: EnhancedTrackingProtectionMenuDelegate?
    
    // MARK: UI components
    
    // Title view
    
    private lazy var titleLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.websiteTitle
        label.numberOfLines = 0
    }
    
    private lazy var domainLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.detailsLabel
        label.numberOfLines = 0
    }
    
    private lazy var titleView: UIStackView = {
        let vStack = UIStackView(arrangedSubviews: [self.titleLabel, self.domainLabel])
        vStack.spacing = 2
        vStack.axis = .vertical
        vStack.alignment = .center
        
        return vStack
    }()
    
    private lazy var closeButton = {
        return UIBarButtonItem(barButtonSystemItem: .close) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }()
    
    lazy private var tableView: UITableView = .build { [weak self] tableView in
        guard let self = self else { return }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CountersCell.self, forCellReuseIdentifier: CountersCell.Identifier)
        tableView.register(TrackerCell.self, forCellReuseIdentifier: TrackerCell.Identifier)

        // Set an empty footer to prevent empty cells from appearing in the list.
        tableView.tableFooterView = UIView()
    }
    
    private var constraints = [NSLayoutConstraint]()
    
    // MARK: - Variables
    
    private var viewModel: QwantTPDetailsVM
    
    // MARK: - View lifecycle
    
    init(viewModel: QwantTPDetailsVM,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.viewModel = viewModel
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        listenForThemeChange(view)
        setupNotifications(forObserver: self, observing: [.ContentBlockerDidBlock])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewDetails()
        applyTheme()
    }
    
    private func setupView() {
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        
        setupTrackerListView()
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupTrackerListView() {
        view.addSubview(tableView)
        
        let trackerListConstraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]
        
        constraints.append(contentsOf: trackerListConstraints)
    }
    
    private func updateViewDetails() {
        navigationItem.titleView = titleView
        navigationItem.setRightBarButton(closeButton, animated: false)
        
        titleLabel.text = viewModel.title
        domainLabel.text = viewModel.websiteTitle
        
        tableView.reloadData()
    }
}

// MARK: - Themable
extension QwantTPDetailsVC {
    @objc func applyTheme() {
        let theme = themeManager.currentTheme
        overrideUserInterfaceStyle = theme.type.getInterfaceStyle()
        view.backgroundColor = theme.colors.etp_background
        
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Notifiable
extension QwantTPDetailsVC: Notifiable {
    func handleNotifications(_ notification: Notification) {
        switch notification.name {
            case .ContentBlockerDidBlock:
                updateViewDetails()
            default: break
        }
    }
}

extension QwantTPDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.orderedDomains.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
            case 0:
                let lImage: UIImage = #imageLiteral(resourceName: "context_pocket")
                let rImage: UIImage = #imageLiteral(resourceName: "menu-TrackingProtection")
                return CountersCell(lIcon: lImage, lValue: String(describing: viewModel.stats.total), lTitle: viewModel.blockedTrackersTitleString,
                                    rIcon: rImage, rValue: String(describing: viewModel.orderedDomains.count), rTitle: viewModel.blockedDomainsTitleString)
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCell.Identifier, for: indexPath)
                cell.textLabel?.text = viewModel.orderedDomains[indexPath.row - 1].key
                cell.detailTextLabel?.text = String(describing: viewModel.orderedDomains[indexPath.row - 1].value)
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
            case 0: return 110
            default: return 44
        }
    }
}

class CountersCell: UITableViewCell, ThemeApplicable {
    static let Identifier = "CountersCell"
    
    private let lView = UIView()
    private let lImageView = UIImageView()
    private let lCountLabel = UILabel()
    private let lTitleLabel = UILabel()
    
    private let rView = UIView()
    private let rImageView = UIImageView()
    private let rCountLabel = UILabel()
    private let rTitleLabel = UILabel()
    
    init(lIcon: UIImage, lValue: String, lTitle: String,
         rIcon: UIImage, rValue: String, rTitle: String) {
        super.init(style: .default, reuseIdentifier: CountersCell.Identifier)
        selectionStyle = .none
        
        lView.translatesAutoresizingMaskIntoConstraints = false
        lView.layer.cornerRadius = ETPMenuUX.UX.viewCornerRadius
        
        lImageView.translatesAutoresizingMaskIntoConstraints = false
        lImageView.contentMode = .scaleAspectFit
        lImageView.image = lIcon.withRenderingMode(.alwaysTemplate)
        lImageView.layer.zPosition = 0
        
        lCountLabel.translatesAutoresizingMaskIntoConstraints = false
        lCountLabel.font = ETPMenuUX.Fonts.websiteTitle
        lCountLabel.adjustsFontSizeToFitWidth = true
        lCountLabel.text = lValue
        lCountLabel.textAlignment = .natural
        lCountLabel.numberOfLines = 1
        lCountLabel.layer.zPosition = 1
        
        lTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        lTitleLabel.font = ETPMenuUX.Fonts.minorInfoLabel
        lTitleLabel.adjustsFontSizeToFitWidth = true
        lTitleLabel.text = lTitle
        lTitleLabel.textAlignment = .natural
        lTitleLabel.numberOfLines = 1
        lTitleLabel.layer.zPosition = 1
        
        rView.translatesAutoresizingMaskIntoConstraints = false
        rView.layer.cornerRadius = ETPMenuUX.UX.viewCornerRadius
        
        rImageView.translatesAutoresizingMaskIntoConstraints = false
        rImageView.contentMode = .scaleAspectFit
        rImageView.image = rIcon.withRenderingMode(.alwaysTemplate)
        rImageView.layer.zPosition = 0
        
        rCountLabel.translatesAutoresizingMaskIntoConstraints = false
        rCountLabel.font = ETPMenuUX.Fonts.websiteTitle
        rCountLabel.text = rValue
        rCountLabel.adjustsFontSizeToFitWidth = true
        rCountLabel.textAlignment = .natural
        rCountLabel.numberOfLines = 1
        rCountLabel.layer.zPosition = 1
        
        rTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        rTitleLabel.font = ETPMenuUX.Fonts.minorInfoLabel
        rTitleLabel.adjustsFontSizeToFitWidth = true
        rTitleLabel.text = rTitle
        rTitleLabel.textAlignment = .natural
        rTitleLabel.numberOfLines = 1
        rTitleLabel.layer.zPosition = 1
        
        lView.addSubviews(lImageView, lCountLabel, lTitleLabel)
        rView.addSubviews(rImageView, rCountLabel, rTitleLabel)
        contentView.addSubviews(lView, rView)
        
        let lConstraints = [
            lImageView.bottomAnchor.constraint(equalTo: lView.bottomAnchor, constant: -8),
            lImageView.trailingAnchor.constraint(equalTo: lView.trailingAnchor, constant: -8),
            lImageView.widthAnchor.constraint(equalToConstant: 40),
            lImageView.heightAnchor.constraint(equalToConstant: 40),
            
            lTitleLabel.topAnchor.constraint(equalTo: lView.topAnchor, constant: ETPMenuUX.UX.gutterDistance),
            lTitleLabel.leadingAnchor.constraint(equalTo: lView.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            lTitleLabel.trailingAnchor.constraint(equalTo: lView.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            
            lCountLabel.topAnchor.constraint(equalTo: lTitleLabel.bottomAnchor, constant: 8),
            lCountLabel.leadingAnchor.constraint(equalTo: lTitleLabel.leadingAnchor),
            lCountLabel.trailingAnchor.constraint(equalTo: lTitleLabel.trailingAnchor),
            lCountLabel.bottomAnchor.constraint(equalTo: lView.bottomAnchor, constant: -ETPMenuUX.UX.gutterDistance),
        ]
        
        let rConstraints = [
            rImageView.bottomAnchor.constraint(equalTo: rView.bottomAnchor, constant: -8),
            rImageView.trailingAnchor.constraint(equalTo: rView.trailingAnchor, constant: -8),
            rImageView.widthAnchor.constraint(equalToConstant: 40),
            rImageView.heightAnchor.constraint(equalToConstant: 40),
            
            rTitleLabel.topAnchor.constraint(equalTo: rView.topAnchor, constant: ETPMenuUX.UX.gutterDistance),
            rTitleLabel.leadingAnchor.constraint(equalTo: rView.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            rTitleLabel.trailingAnchor.constraint(equalTo: rView.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            
            rCountLabel.topAnchor.constraint(equalTo: rTitleLabel.bottomAnchor, constant: 8),
            rCountLabel.leadingAnchor.constraint(equalTo: rTitleLabel.leadingAnchor),
            rCountLabel.trailingAnchor.constraint(equalTo: rTitleLabel.trailingAnchor),
            rCountLabel.bottomAnchor.constraint(equalTo: rView.bottomAnchor, constant: -ETPMenuUX.UX.gutterDistance),
        ]
        
        let allConstraints = [
            lView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: ETPMenuUX.UX.gutterDistance),
            lView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            lView.trailingAnchor.constraint(equalTo: rView.leadingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            rView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            rView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: ETPMenuUX.UX.gutterDistance),
            lView.widthAnchor.constraint(equalTo: rView.widthAnchor),
            lView.heightAnchor.constraint(equalTo: rView.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(lConstraints)
        NSLayoutConstraint.activate(rConstraints)
        NSLayoutConstraint.activate(allConstraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ThemeApplicable

    func applyTheme(theme: Theme) {
        contentView.backgroundColor = theme.colors.etp_background

        lView.backgroundColor = theme.colors.etp_sectionColor
        lImageView.tintColor = theme.colors.etp_subtextColor.withAlphaComponent(0.2)
        lTitleLabel.textColor = theme.colors.etp_subtextColor

        rView.backgroundColor = theme.colors.etp_sectionColor
        rImageView.tintColor = theme.colors.etp_subtextColor.withAlphaComponent(0.2)
        rTitleLabel.textColor = theme.colors.etp_subtextColor

    }
    
//    func applyTheme() {
//        contentView.backgroundColor = UIColor.legacyTheme.etpMenu.background
//
//        lView.backgroundColor = UIColor.legacyTheme.etpMenu.sectionColor
//        lImageView.tintColor = UIColor.legacyTheme.etpMenu.subtextColor.withAlphaComponent(0.2)
//        lTitleLabel.textColor = UIColor.legacyTheme.etpMenu.subtextColor
//
//        rView.backgroundColor = UIColor.legacyTheme.etpMenu.sectionColor
//        rImageView.tintColor = UIColor.legacyTheme.etpMenu.subtextColor.withAlphaComponent(0.2)
//        rTitleLabel.textColor = UIColor.legacyTheme.etpMenu.subtextColor
//    }
}

class TrackerCell: UITableViewCell {
    static let Identifier = "TrackerCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
