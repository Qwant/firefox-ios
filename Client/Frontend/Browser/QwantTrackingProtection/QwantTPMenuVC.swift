// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import Common

class QwantTPMenuVC: UIViewController, Themeable {
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
    
    private lazy var connectionImage: UIImageView = .build { image in
        image.contentMode = .scaleAspectFit
    }
    
    private lazy var connectionLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.detailsLabel
        label.numberOfLines = 0
    }
    
    private lazy var titleView: UIStackView = {
        let hStack = UIStackView(arrangedSubviews: [self.connectionImage, self.connectionLabel])
        hStack.spacing = 8
        hStack.alignment = .center
        
        let vStack = UIStackView(arrangedSubviews: [self.titleLabel, hStack])
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
    
    private lazy var scrollView: UIScrollView = .build { scrollView in
        scrollView.backgroundColor = .clear
    }
    
    private lazy var contentView: UIView = .build { view in
        view.backgroundColor = .clear
    }
    
    private lazy var logoImageView: UIImageView = .build { imageView in
        imageView.image = UIImage(imageLiteralResourceName: "qwant_vip")
        imageView.contentMode = .scaleAspectFit
    }
    
    // Local tracking protection
    private lazy var localProtectionView = ETPSectionView(frame: .zero)
    
    private lazy var localProtectionTitleLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.websiteTitle
        label.numberOfLines = 0
    }
    
    private lazy var localProtectionSubtitleLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.minorInfoLabel
        label.numberOfLines = 0
    }
    
    private lazy var localProtectionToggle: UISwitch = .build { toggle in
        toggle.addTarget(self, action: #selector(self.didChangeSwitchState), for: .valueChanged)
    }
    
    private lazy var localProtectionActivityIndicator: UIActivityIndicatorView = .build { activityIndicator in
        activityIndicator.style = .medium
        activityIndicator.color = .systemGray
        activityIndicator.startAnimating()
    }
    
    // Blocked trackers count view
    private lazy var blockedTrackersView = ETPSectionView(frame: .zero)
    
    private lazy var blockedTrackersButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.blockedTrackersDetailsTapped), for: .touchUpInside)
    }
    
    private lazy var blockedTrackersTitleLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.viewTitleLabels
        label.numberOfLines = 0
    }
    
    private lazy var blockedTrackersCountLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.minorInfoLabel
        label.numberOfLines = 0
    }
    
    private lazy var blockedTrackersDetailArrow: UIImageView = .build { image in
        image.image = UIImage(imageLiteralResourceName: StandardImageIdentifiers.Large.chevronLeft).withRenderingMode(.alwaysTemplate).imageFlippedForRightToLeftLayoutDirection()
        image.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    // Tracking protection settings view
    private lazy var trackingProtectionView = ETPSectionView(frame: .zero)
    
    private lazy var trackingProtectionButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.protectionSettingsTapped), for: .touchUpInside)
    }
    
    private lazy var trackingProtectionTitleLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.websiteTitle
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
    }
    
    private lazy var trackingProtectionSubtitleLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.detailsLabel
        label.numberOfLines = 0
    }
    
    private lazy var trackingProtectionValueLabel: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.minorInfoLabel
        label.numberOfLines = 0
    }
    
    private lazy var trackingProtectionDetailArrow: UIImageView = .build { image in
        image.image = UIImage(imageLiteralResourceName: StandardImageIdentifiers.Large.chevronLeft).withRenderingMode(.alwaysTemplate).imageFlippedForRightToLeftLayoutDirection()
        image.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    // Statistics view
    
    private lazy var statisticsHeader: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.detailsLabel
        label.numberOfLines = 0
    }
    
    private lazy var statisticsTopLine: UIView = .build()
    
    private lazy var statisticsView: UIView = .build()
    
    private lazy var statisticsBlockedTrackersTitle: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.minorInfoLabel
        label.numberOfLines = 0
    }
    
    private lazy var statisticsBlockedTrackersValue: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.websiteTitle
        label.numberOfLines = 0
    }
    
    private lazy var statisticsSeparatorLine: UIView = .build()
    
    private lazy var statisticsSavedTimeTitle: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.minorInfoLabel
        label.numberOfLines = 0
    }
    
    private lazy var statisticsSavedTimeValue: UILabel = .build { label in
        label.font = ETPMenuUX.Fonts.websiteTitle
        label.numberOfLines = 0
    }
    
    private lazy var statisticsBottomLine: UIView = .build()
    
    private lazy var statisticsSeeDetails: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.statisticsTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = ETPMenuUX.Fonts.minorInfoLabel
    }
    
    private var constraints = [NSLayoutConstraint]()
    
    // MARK: - Variables
    
    private var viewModel: QwantTPMenuVM
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    var asPopover: Bool = false
    
    // MARK: - View lifecycle
    
    init(viewModel: QwantTPMenuVM,
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
        if asPopover {
            var height: CGFloat = 800
            if !viewModel.globalETPIsEnabled {
                height = 500
            }
            self.preferredContentSize = CGSize(width: 400, height: height)
        }
//        else {
//            addGestureRecognizer()
//        }
        setupView()
        listenForThemeChange(view)
        setupNotifications(forObserver: self, observing: [.ContentBlockerDidBlock])
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        updateViewDetails()
        applyTheme()
    }
    
    
    private func setupView() {
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()
        
        setupTitleView()
        setupScrollView()
        setupLogoView()
        setupLocalProtectionView()
        setupBlockedTrackersView()
        setupProtectionSettingsView()
        setupStatisticsView()
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupTitleView() {
        
        let connectionConstraints = [
            connectionImage.heightAnchor.constraint(equalToConstant: 15),
            connectionImage.widthAnchor.constraint(equalToConstant: 15)
        ]
        
        constraints.append(contentsOf: connectionConstraints)
    }
    
    private func setupScrollView() {
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide

        let scrollViewConstraints = [
            // Constraints that set the size and position of the scroll view relative to its superview
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            // Constraints that set the size of the scrollable content area inside the scrollview
            frameGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            frameGuide.topAnchor.constraint(equalTo: view.topAnchor),
            frameGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            frameGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentGuide.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
        ]
        
        constraints.append(contentsOf: scrollViewConstraints)
    }
    
    private func setupLogoView() {
        contentView.addSubview(logoImageView)
        
        let logoConstraints = [
            logoImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: ETPMenuUX.UX.gutterDistance),
            logoImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            logoImageView.heightAnchor.constraint(equalToConstant: 30),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: 28.0/207.0)
        ]
        
        constraints.append(contentsOf: logoConstraints)
    }
    
    private func setupLocalProtectionView() {
        let localProtectionLabelsContainer = UIView()
        localProtectionLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        localProtectionLabelsContainer.addSubviews(localProtectionTitleLabel, localProtectionSubtitleLabel)
        localProtectionView.addSubviews(localProtectionLabelsContainer, localProtectionToggle, localProtectionActivityIndicator)
        contentView.addSubview(localProtectionView)
        
        let localProtectionLabelsContainerConstraints = [
            localProtectionTitleLabel.topAnchor.constraint(equalTo: localProtectionLabelsContainer.topAnchor),
            localProtectionTitleLabel.leadingAnchor.constraint(equalTo: localProtectionLabelsContainer.leadingAnchor),
            localProtectionTitleLabel.trailingAnchor.constraint(equalTo: localProtectionLabelsContainer.trailingAnchor),
            
            localProtectionSubtitleLabel.topAnchor.constraint(equalTo: localProtectionTitleLabel.bottomAnchor, constant: 4),
            localProtectionSubtitleLabel.leadingAnchor.constraint(equalTo: localProtectionLabelsContainer.leadingAnchor),
            localProtectionSubtitleLabel.trailingAnchor.constraint(equalTo: localProtectionLabelsContainer.trailingAnchor),
            localProtectionSubtitleLabel.bottomAnchor.constraint(equalTo: localProtectionLabelsContainer.bottomAnchor)
        ]
        
        let localProtectionConstraints = [
            localProtectionView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: viewModel.globalETPIsEnabled ? ETPMenuUX.UX.gutterDistance : 0),
            localProtectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            localProtectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            
            localProtectionLabelsContainer.topAnchor.constraint(equalTo: localProtectionView.topAnchor, constant: 12),
            localProtectionLabelsContainer.leadingAnchor.constraint(equalTo: localProtectionView.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            localProtectionLabelsContainer.trailingAnchor.constraint(equalTo: localProtectionToggle.leadingAnchor, constant: -8),
            localProtectionLabelsContainer.bottomAnchor.constraint(equalTo: localProtectionView.bottomAnchor, constant: -12),

            localProtectionToggle.centerYAnchor.constraint(equalTo: localProtectionLabelsContainer.centerYAnchor),
            localProtectionToggle.trailingAnchor.constraint(equalTo: localProtectionView.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            
            localProtectionActivityIndicator.centerYAnchor.constraint(equalTo: localProtectionToggle.centerYAnchor),
            localProtectionActivityIndicator.centerXAnchor.constraint(equalTo: localProtectionToggle.centerXAnchor)
        ]
        
        constraints.append(contentsOf: localProtectionLabelsContainerConstraints)
        constraints.append(contentsOf: localProtectionConstraints)
        
        if !viewModel.globalETPIsEnabled {
            constraints.append(localProtectionView.heightAnchor.constraint(equalToConstant: 0))
        }
    }
    
    private func setupBlockedTrackersView() {
        blockedTrackersView.addSubviews(blockedTrackersButton, blockedTrackersTitleLabel, blockedTrackersCountLabel, blockedTrackersDetailArrow)
        contentView.addSubview(blockedTrackersView)
        
        let blockedTrackersConstraints = [
            blockedTrackersView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            blockedTrackersView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            blockedTrackersView.topAnchor.constraint(equalTo: localProtectionView.bottomAnchor, constant: 8),
            
            blockedTrackersTitleLabel.leadingAnchor.constraint(equalTo: blockedTrackersView.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            blockedTrackersTitleLabel.centerYAnchor.constraint(equalTo: blockedTrackersView.centerYAnchor),
            
            blockedTrackersDetailArrow.trailingAnchor.constraint(equalTo: blockedTrackersView.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            blockedTrackersDetailArrow.centerYAnchor.constraint(equalTo: blockedTrackersView.centerYAnchor),
            blockedTrackersDetailArrow.heightAnchor.constraint(equalToConstant: 20),
            blockedTrackersDetailArrow.widthAnchor.constraint(equalToConstant: 20),
            blockedTrackersDetailArrow.topAnchor.constraint(equalTo: blockedTrackersView.topAnchor, constant: 12),
            blockedTrackersDetailArrow.bottomAnchor.constraint(equalTo: blockedTrackersView.bottomAnchor, constant: -12),
            
            blockedTrackersCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: blockedTrackersTitleLabel.trailingAnchor, constant: 8),
            blockedTrackersCountLabel.trailingAnchor.constraint(equalTo: blockedTrackersDetailArrow.leadingAnchor),
            blockedTrackersCountLabel.centerYAnchor.constraint(equalTo: blockedTrackersView.centerYAnchor),
            
            blockedTrackersButton.leadingAnchor.constraint(equalTo: blockedTrackersView.leadingAnchor),
            blockedTrackersButton.topAnchor.constraint(equalTo: blockedTrackersView.topAnchor),
            blockedTrackersButton.trailingAnchor.constraint(equalTo: blockedTrackersView.trailingAnchor),
            blockedTrackersButton.bottomAnchor.constraint(equalTo: blockedTrackersView.bottomAnchor),
        ]
        
        constraints.append(contentsOf: blockedTrackersConstraints)
        if !viewModel.isSiteETPEnabled || !viewModel.globalETPIsEnabled {
            constraints.append(blockedTrackersView.heightAnchor.constraint(equalToConstant: 0))
        }
    }
    
    private func setupProtectionSettingsView() {
        let trackingProtectionLabelsContainer = UIView()
        trackingProtectionLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        trackingProtectionLabelsContainer.isUserInteractionEnabled = false
        trackingProtectionLabelsContainer.addSubviews(trackingProtectionTitleLabel, trackingProtectionSubtitleLabel)
        trackingProtectionView.addSubviews(trackingProtectionButton, trackingProtectionLabelsContainer, trackingProtectionValueLabel, trackingProtectionDetailArrow)
        contentView.addSubview(trackingProtectionView)
        
        let trackingProtectionLabelsContainerConstraints = [
            trackingProtectionTitleLabel.topAnchor.constraint(equalTo: trackingProtectionLabelsContainer.topAnchor),
            trackingProtectionTitleLabel.leadingAnchor.constraint(equalTo: trackingProtectionLabelsContainer.leadingAnchor),
            trackingProtectionTitleLabel.trailingAnchor.constraint(equalTo: trackingProtectionLabelsContainer.trailingAnchor),
            
            trackingProtectionSubtitleLabel.topAnchor.constraint(equalTo: trackingProtectionTitleLabel.bottomAnchor, constant: 2),
            trackingProtectionSubtitleLabel.leadingAnchor.constraint(equalTo: trackingProtectionLabelsContainer.leadingAnchor),
            trackingProtectionSubtitleLabel.trailingAnchor.constraint(equalTo: trackingProtectionLabelsContainer.trailingAnchor),
            trackingProtectionSubtitleLabel.bottomAnchor.constraint(equalTo: trackingProtectionLabelsContainer.bottomAnchor)
        ]
        
        
        let trackingProtectionConstraints = [
            trackingProtectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            trackingProtectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
    
            trackingProtectionLabelsContainer.topAnchor.constraint(equalTo: trackingProtectionView.topAnchor, constant: 11),
            trackingProtectionLabelsContainer.leadingAnchor.constraint(equalTo: trackingProtectionView.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            trackingProtectionLabelsContainer.bottomAnchor.constraint(equalTo: trackingProtectionView.bottomAnchor, constant: -11),
            
            trackingProtectionValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: trackingProtectionLabelsContainer.trailingAnchor, constant: 8),
            trackingProtectionValueLabel.trailingAnchor.constraint(equalTo: trackingProtectionDetailArrow.leadingAnchor),
            trackingProtectionValueLabel.centerYAnchor.constraint(equalTo: trackingProtectionView.centerYAnchor),
            
            trackingProtectionDetailArrow.trailingAnchor.constraint(equalTo: trackingProtectionView.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            trackingProtectionDetailArrow.centerYAnchor.constraint(equalTo: trackingProtectionView.centerYAnchor),
            trackingProtectionDetailArrow.heightAnchor.constraint(equalToConstant: 20),
            trackingProtectionDetailArrow.widthAnchor.constraint(equalToConstant: 20),
            
            trackingProtectionButton.leadingAnchor.constraint(equalTo: trackingProtectionView.leadingAnchor),
            trackingProtectionButton.topAnchor.constraint(equalTo: trackingProtectionView.topAnchor),
            trackingProtectionButton.trailingAnchor.constraint(equalTo: trackingProtectionView.trailingAnchor),
            trackingProtectionButton.bottomAnchor.constraint(equalTo: trackingProtectionView.bottomAnchor),
        ]
        
        constraints.append(contentsOf: trackingProtectionLabelsContainerConstraints)
        constraints.append(contentsOf: trackingProtectionConstraints)
        constraints.append(trackingProtectionView.topAnchor.constraint(equalTo: blockedTrackersView.bottomAnchor, constant: viewModel.isSiteETPEnabled && viewModel.globalETPIsEnabled ? 8 : 0))

    }
    
    private func setupStatisticsView() {
        contentView.addSubviews(statisticsHeader, statisticsTopLine, statisticsView, statisticsBlockedTrackersTitle, statisticsBlockedTrackersValue, statisticsSeparatorLine, statisticsSavedTimeTitle, statisticsSavedTimeValue, statisticsBottomLine, statisticsSeeDetails)
        
        let statisticsConstraints = [
            statisticsHeader.topAnchor.constraint(equalTo: trackingProtectionView.bottomAnchor, constant: ETPMenuUX.UX.gutterDistance),
            statisticsHeader.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            statisticsHeader.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            
            statisticsTopLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statisticsTopLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statisticsTopLine.topAnchor.constraint(equalTo: statisticsHeader.bottomAnchor, constant: 4),
            statisticsTopLine.heightAnchor.constraint(equalToConstant: ETPMenuUX.UX.Line.height),
            
            statisticsView.topAnchor.constraint(equalTo: statisticsTopLine.bottomAnchor),
            statisticsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statisticsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statisticsView.bottomAnchor.constraint(equalTo: statisticsBottomLine.topAnchor),
            
            statisticsBlockedTrackersTitle.topAnchor.constraint(equalTo: statisticsSeparatorLine.topAnchor),
            statisticsBlockedTrackersTitle.leadingAnchor.constraint(equalTo: statisticsView.safeAreaLayoutGuide.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            statisticsBlockedTrackersTitle.trailingAnchor.constraint(equalTo: statisticsSeparatorLine.leadingAnchor, constant: -ETPMenuUX.UX.gutterDistance),

            statisticsBlockedTrackersValue.topAnchor.constraint(equalTo: statisticsBlockedTrackersTitle.bottomAnchor, constant: 15),
            statisticsBlockedTrackersValue.leadingAnchor.constraint(equalTo: statisticsBlockedTrackersTitle.leadingAnchor),
            statisticsBlockedTrackersValue.trailingAnchor.constraint(equalTo: statisticsBlockedTrackersTitle.trailingAnchor),
            statisticsBlockedTrackersValue.bottomAnchor.constraint(equalTo: statisticsSeparatorLine.bottomAnchor),

            statisticsSeparatorLine.topAnchor.constraint(equalTo: statisticsView.topAnchor, constant: 11),
            statisticsSeparatorLine.bottomAnchor.constraint(equalTo: statisticsView.bottomAnchor, constant: -11),
            statisticsSeparatorLine.widthAnchor.constraint(equalToConstant: ETPMenuUX.UX.Line.height),
            statisticsSeparatorLine.centerXAnchor.constraint(equalTo: statisticsView.centerXAnchor),
            
            statisticsSavedTimeTitle.topAnchor.constraint(equalTo: statisticsSeparatorLine.topAnchor),
            statisticsSavedTimeTitle.leadingAnchor.constraint(equalTo: statisticsSeparatorLine.trailingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            statisticsSavedTimeTitle.trailingAnchor.constraint(equalTo: statisticsView.safeAreaLayoutGuide.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),

            statisticsSavedTimeValue.topAnchor.constraint(equalTo: statisticsSavedTimeTitle.bottomAnchor, constant: 15),
            statisticsSavedTimeValue.leadingAnchor.constraint(equalTo: statisticsSavedTimeTitle.leadingAnchor),
            statisticsSavedTimeValue.trailingAnchor.constraint(equalTo: statisticsSavedTimeTitle.trailingAnchor),
            statisticsSavedTimeValue.bottomAnchor.constraint(equalTo: statisticsSeparatorLine.bottomAnchor),

            statisticsBottomLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statisticsBottomLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            statisticsBottomLine.topAnchor.constraint(equalTo: statisticsView.bottomAnchor),
            statisticsBottomLine.heightAnchor.constraint(equalToConstant: ETPMenuUX.UX.Line.height),
            
            statisticsSeeDetails.topAnchor.constraint(equalTo: statisticsBottomLine.topAnchor, constant: 8),
            statisticsSeeDetails.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: ETPMenuUX.UX.gutterDistance),
            statisticsSeeDetails.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -ETPMenuUX.UX.gutterDistance),
            statisticsSeeDetails.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -ETPMenuUX.UX.gutterDistance)
        ]
        
        constraints.append(contentsOf: statisticsConstraints)
    }
    
    private func updateViewDetails() {
        
        navigationItem.titleView = titleView
        navigationItem.setRightBarButton(closeButton, animated: false)
        
        titleLabel.text = viewModel.websiteTitle
        connectionLabel.text = viewModel.connectionStatusString
        
        localProtectionToggle.isOn = viewModel.isSiteETPEnabled
        localProtectionTitleLabel.text = viewModel.protectionStatusString
        localProtectionSubtitleLabel.text = viewModel.protectionStatusDetailString
        localProtectionActivityIndicator.isHidden = !viewModel.globalETPIsEnabled || !viewModel.isSiteETPEnabling
        localProtectionToggle.isHidden = !viewModel.globalETPIsEnabled || viewModel.isSiteETPEnabling
        localProtectionTitleLabel.isHidden = !viewModel.globalETPIsEnabled
        localProtectionSubtitleLabel.isHidden = !viewModel.globalETPIsEnabled
        
        blockedTrackersTitleLabel.text = viewModel.blockedTrackersTitleString
        blockedTrackersCountLabel.text = String(describing: viewModel.blockedTrackersCount)
        blockedTrackersTitleLabel.isHidden = !viewModel.isSiteETPEnabled || !viewModel.globalETPIsEnabled
        blockedTrackersCountLabel.isHidden = !viewModel.isSiteETPEnabled || !viewModel.globalETPIsEnabled
        blockedTrackersDetailArrow.isHidden = !viewModel.isSiteETPEnabled || !viewModel.globalETPIsEnabled

        trackingProtectionTitleLabel.text = viewModel.trackingProtectionTitleString
        trackingProtectionSubtitleLabel.text = viewModel.trackingProtectionSubtitleString
        trackingProtectionValueLabel.text = viewModel.trackingProtectionValueString

        statisticsHeader.text = viewModel.statisticsHeaderString
        statisticsBlockedTrackersTitle.text = viewModel.statisticsBlockedTrackersTitleString
        statisticsBlockedTrackersValue.text = viewModel.statisticsTrackersBlockedFormattedString
        statisticsSavedTimeTitle.text = viewModel.statisticsSavedTimeTitleString
        statisticsSavedTimeValue.text = viewModel.statisticsTimeSavedFormattedString
        statisticsSeeDetails.setTitle(viewModel.statisticsSeeDetails, for: .normal)
    }
    
    // MARK: - Button actions
    
    @objc private func didChangeSwitchState() {
        // site is safelisted if site ETP is disabled
        viewModel.toggleSiteSafelistStatus() { [weak self] in
            self?.setupView()
            self?.updateViewDetails()
            self?.applyTheme()
        }
        setupView()
        updateViewDetails()
        applyTheme()
    }
    
    @objc private func blockedTrackersDetailsTapped() {
        guard let controller = viewModel.getDetailsViewController() else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func protectionSettingsTapped() {
        let controller = viewModel.getProtectionSettingsViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func statisticsTapped() {
        guard let controller = viewModel.getStatsViewController() else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }

//    // MARK: - Gesture Recognizer
//
//    private func addGestureRecognizer() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
//        view.addGestureRecognizer(panGesture)
//    }
//
//    @objc
//    func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
//        let translation = sender.translation(in: view)
//        let originalYPosition = self.view.frame.origin.y
//        let originalXPosition = self.view.frame.origin.x
//
//        // Not allowing the user to drag the view upward
//        guard translation.y >= 0 else { return }
//
//        // Setting x based on window calculation because we don't want
//        // users to move the frame side ways, only straight up or down
//        view.frame.origin = CGPoint(x: originalXPosition,
//                                    y: self.pointOrigin!.y + translation.y)
//
//        if sender.state == .ended {
//            let dragVelocity = sender.velocity(in: view)
//            if dragVelocity.y >= 1300 {
//                if CoordinatorFlagManager.isEtpCoordinatorEnabled {
//                    enhancedTrackingProtectionMenuDelegate?.didFinish()
//                } else {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            } else {
//                // Set back to original position of the view controller
//                UIView.animate(withDuration: 0.3) {
//                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: originalXPosition, y: originalYPosition)
//                }
//            }
//        }
//    }
}

// MARK: - Themable
extension QwantTPMenuVC {
    @objc func applyTheme() {
        let theme = themeManager.currentTheme
        overrideUserInterfaceStyle = theme.type.getInterfaceStyle()
        view.backgroundColor = theme.colors.etp_background
        
        localProtectionView.backgroundColor = theme.colors.etp_sectionColor
        localProtectionTitleLabel.textColor = viewModel.protectionStatusColor
        localProtectionSubtitleLabel.textColor = theme.colors.etp_subtextColor
        localProtectionToggle.tintColor = UIColor.Qwant.Theme.Green60
        localProtectionToggle.onTintColor = UIColor.Qwant.Theme.Green60
        
        blockedTrackersView.backgroundColor = theme.colors.etp_sectionColor
        blockedTrackersCountLabel.textColor = theme.colors.etp_subtextColor
        blockedTrackersDetailArrow.tintColor = theme.colors.etp_subtextColor
        
        trackingProtectionView.backgroundColor = theme.colors.etp_sectionColor
        trackingProtectionSubtitleLabel.textColor = theme.colors.etp_subtextColor
        trackingProtectionValueLabel.textColor = theme.colors.etp_subtextColor
        trackingProtectionDetailArrow.tintColor = theme.colors.etp_subtextColor
        
        statisticsHeader.textColor = theme.colors.etp_subtextColor
        statisticsTopLine.backgroundColor = theme.colors.etp_horizontalLine
        statisticsView.backgroundColor = theme.colors.etp_sectionColor
        statisticsBlockedTrackersTitle.textColor = theme.colors.etp_subtextColor
        statisticsSeparatorLine.backgroundColor = theme.colors.etp_horizontalLine
        statisticsSavedTimeTitle.textColor = theme.colors.etp_subtextColor
        statisticsBottomLine.backgroundColor = theme.colors.etp_horizontalLine
        
        statisticsSeeDetails.setTitleColor(theme.colors.etp_switchAndButtonTint, for: .normal)
        
        connectionLabel.textColor = theme.colors.etp_subtextColor
        connectionImage.image = viewModel.connectionStatusImage
        if viewModel.connectionSecure {
            connectionImage.tintColor = theme.colors.etp_subtextColor
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Notifiable

extension QwantTPMenuVC: Notifiable {
    func handleNotifications(_ notification: Notification) {
        switch notification.name {
            case .ContentBlockerDidBlock:
                updateViewDetails()
            default: break
        }
    }
}
