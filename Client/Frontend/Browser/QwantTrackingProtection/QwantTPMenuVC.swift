// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import MessageUI

class QwantTPMenuVC: QwantVIPBaseVC {
    
    private func repositionLogo(imageView: UIImageView) {
        let isPortrait = UIDevice.current.orientation.isPortrait
        let shift = isPortrait ? UIEdgeInsets(top: -16, left: 0, bottom: 0, right: 0) : UIEdgeInsets.zero
        imageView.image = UIImage(imageLiteralResourceName: "qwant_vip_logo_and_text").withAlignmentRectInsets(shift)
        imageView.contentMode = isPortrait ? .scaleAspectFill : .scaleAspectFit
        imageView.setNeedsLayout()
    }

    // MARK: UI components
    
    // Title view
    private lazy var titleImageView: UIImageView = .build { image in
        self.repositionLogo(imageView: image)
    }
    
    private lazy var imageIcon = {
        return UIBarButtonItem(customView: self.titleImageView)
    }()
    
    private lazy var scrollView: UIScrollView = .build { scrollView in
        scrollView.backgroundColor = .clear
    }
    
    private lazy var contentView: UIView = .build { view in
        view.backgroundColor = .clear
    }
    
    // Local tracking protection
    
    private lazy var localProtectionView = ETPSectionView(frame: .zero)
    
    private lazy var localProtectionShieldImage: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
    }
    
    private lazy var localProtectionShieldCounterLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Title.l
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
    }
    
    private lazy var localProtectionTitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Title.m
        label.numberOfLines = 1
    }
    
    private lazy var localProtectionSubtitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 1
    }
    
    private lazy var localProtectionDetailArrow: UIImageView = .build { image in
        image.image = UIImage(systemName: "chevron.right")
    }
    
    private lazy var localProtectionConnectionImage: UIImageView = .build { image in
        image.contentMode = .scaleAspectFit
    }
    
    private lazy var localProtectionConnectionLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.s
        label.numberOfLines = 1
    }
    
    private lazy var localProtectionActivationButton: UIButton = .build { button in
        button.setTitle(self.viewModel.reactivateProtectionTitleString, for: .normal)
        button.titleLabel?.font = QwantUX.Font.Text.m
        button.setImage(UIImage(imageLiteralResourceName: "icon_shield"), for: .normal)
        button.addTarget(self, action: #selector(self.didActivateTrackingProtection), for: .touchUpInside)
        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.clipsToBounds = true
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: QwantUX.Spacing.xxxs)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: QwantUX.Spacing.xxxs, bottom: 0, right: 0)
    }
    
    private lazy var localProtectionDetailsButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.localProtectionDetailsTapped), for: .touchUpInside)
    }
    
    private lazy var localProtectionSeparatorLine: UIView = .build()
    
    private lazy var localProtectionLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.xl
        label.numberOfLines = 1
    }
    
    private lazy var localProtectionToggle: UISwitch = .build { toggle in
        toggle.addTarget(self, action: #selector(self.didChangeSwitchState), for: .valueChanged)
        toggle.layer.cornerRadius = toggle.frame.height / 2
        toggle.clipsToBounds = true
    }
    
    private lazy var localProtectionActivityIndicator: UIActivityIndicatorView = .build { activityIndicator in
        activityIndicator.style = .medium
        activityIndicator.color = .systemGray
        activityIndicator.startAnimating()
    }
    
    private lazy var localProtectionFooterLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.s
        label.numberOfLines = 0
    }
    
    // Protection level view
    private lazy var protectionLevelView = ETPSectionView(frame: .zero)

    private lazy var protectionLevelDetailsButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.protectionSettingsTapped), for: .touchUpInside)
    }

    private lazy var protectionLevelTitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.xl
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
    }

    private lazy var protectionLevelSubtitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 0
    }

    private lazy var protectionLevelDetailsArrow: UIImageView = .build { image in
        image.image = UIImage(systemName: "chevron.right")
    }

    // Statistics views
    private lazy var statisticsLeftView = ETPSectionView(frame: .zero)

    private lazy var statisticsLeftTitle: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 1
    }

    private lazy var statisticsLeftValue: UILabel = .build { label in
        label.font = QwantUX.Font.Title.m
        label.numberOfLines = 1
    }

    private lazy var statisticsLeftImage: UIImageView = .build { image in
        image.image = UIImage(imageLiteralResourceName: "icon_shield_purple")
        image.contentMode = .scaleAspectFit
    }

    private lazy var statisticsRightView = ETPSectionView(frame: .zero)

    private lazy var statisticsRightTitle: UILabel = .build { label in
        label.font = QwantUX.Font.Text.m
        label.numberOfLines = 1
    }

    private lazy var statisticsRightValue: UILabel = .build { label in
        label.font = QwantUX.Font.Title.m
        label.numberOfLines = 1
    }

    private lazy var statisticsRightImage: UIImageView = .build { image in
        image.image = UIImage(imageLiteralResourceName: "icon_clock_purple")
        image.contentMode = .scaleAspectFit
    }

    private lazy var statisticsDetailsButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.statisticsTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = QwantUX.Font.Text.xl
    }

    // Information view
    private lazy var informationView = ETPSectionView(frame: .zero)

    private lazy var informationDetailsButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.informationDetailsTapped), for: .touchUpInside)
    }

    private lazy var informationTitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.xl
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
    }

    private lazy var informationDetailsArrow: UIImageView = .build { image in
        image.image = UIImage(systemName: "chevron.right")
    }
    
    // Mail view
    private lazy var mailView = ETPSectionView(frame: .zero)

    private lazy var mailDetailsButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.sendMailTapped), for: .touchUpInside)
    }

    private lazy var mailTitleLabel: UILabel = .build { label in
        label.font = QwantUX.Font.Text.xl
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
    }

    private lazy var mailDetailsExternal: UIImageView = .build { image in
        image.image = UIImage(imageLiteralResourceName: "icon_www_external")
        image.contentMode = .scaleAspectFit
    }
    
    private var viewModel: QwantTPMenuVM
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    var asPopover: Bool = false
    
    // MARK: - View lifecycle
    
    init(viewModel: QwantTPMenuVM,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default) {
        self.viewModel = viewModel
        super.init(themeManager: themeManager, notificationCenter: notificationCenter)
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
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        setupTitleView()
        setupScrollView()
        setupLocalProtectionView()
        setupProtectionLevelView()
        setupStatisticsView()
        setupInformationView()
        setupMailView()
    }
    
    private func setupTitleView() {
        let isPortrait = UIDevice.current.orientation.isPortrait
        constraints.append(contentsOf: [
            titleImageView.heightAnchor.constraint(equalToConstant: 40),
            titleImageView.widthAnchor.constraint(equalToConstant: isPortrait ? 219 : 203)
        ])
        
        repositionLogo(imageView: titleImageView)
    }
    
    private func setupScrollView() {
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide

        constraints.append(contentsOf: [
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
        ])
    }
    
    private func setupLocalProtectionView() {
        let localProtectionHeaderContainer = UIView()
        localProtectionHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        localProtectionHeaderContainer.addSubviews(localProtectionShieldImage, localProtectionShieldCounterLabel, localProtectionTitleLabel, localProtectionDetailArrow)
        
        let localProtectionActivatedContainer = UIView()
        localProtectionActivatedContainer.translatesAutoresizingMaskIntoConstraints = false
        localProtectionActivatedContainer.addSubviews(localProtectionSubtitleLabel, localProtectionConnectionImage, localProtectionConnectionLabel, localProtectionSeparatorLine, localProtectionLabel, localProtectionToggle, localProtectionActivityIndicator)

        let localProtectionDeactivatedContainer = UIView()
        localProtectionDeactivatedContainer.translatesAutoresizingMaskIntoConstraints = false
        localProtectionDeactivatedContainer.addSubviews(localProtectionActivationButton)

        localProtectionView.addSubviews(localProtectionHeaderContainer, localProtectionActivatedContainer, localProtectionDeactivatedContainer, localProtectionDetailsButton)
        contentView.addSubviews(localProtectionFooterLabel, localProtectionView)
        
        let localProtectionHeaderContainerConstraints = [
            localProtectionHeaderContainer.topAnchor.constraint(equalTo: localProtectionView.topAnchor),
            localProtectionHeaderContainer.leadingAnchor.constraint(equalTo: localProtectionView.leadingAnchor),
            localProtectionHeaderContainer.trailingAnchor.constraint(equalTo: localProtectionView.trailingAnchor),
            
            localProtectionShieldImage.topAnchor.constraint(equalTo: localProtectionHeaderContainer.topAnchor, constant: QwantUX.Spacing.m),
            localProtectionShieldImage.centerXAnchor.constraint(equalTo: localProtectionHeaderContainer.centerXAnchor),
            localProtectionShieldImage.widthAnchor.constraint(equalToConstant: 56),
            localProtectionShieldImage.heightAnchor.constraint(equalToConstant: 64),
            
            localProtectionShieldCounterLabel.centerXAnchor.constraint(equalTo: localProtectionShieldImage.centerXAnchor),
            localProtectionShieldCounterLabel.centerYAnchor.constraint(equalTo: localProtectionShieldImage.centerYAnchor),
            localProtectionShieldCounterLabel.widthAnchor.constraint(equalTo: localProtectionShieldImage.widthAnchor, multiplier: 0.75),
            
            localProtectionTitleLabel.topAnchor.constraint(equalTo: localProtectionShieldImage.bottomAnchor, constant: QwantUX.Spacing.xs),
            localProtectionTitleLabel.centerXAnchor.constraint(equalTo: localProtectionHeaderContainer.centerXAnchor),
            localProtectionTitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: localProtectionHeaderContainer.leadingAnchor, constant: QwantUX.Spacing.m),
            localProtectionTitleLabel.bottomAnchor.constraint(equalTo: localProtectionHeaderContainer.bottomAnchor, constant: QwantUX.Spacing.m),
            
            localProtectionDetailArrow.trailingAnchor.constraint(equalTo: localProtectionView.trailingAnchor, constant: -QwantUX.Spacing.m),
            localProtectionDetailArrow.centerYAnchor.constraint(equalTo: localProtectionView.centerYAnchor, constant: -(QwantUX.Spacing.xs + localProtectionToggle.frame.height + QwantUX.Spacing.xs + 1) / 2)
        ]
        
        let localProtectionActivatedContainerConstraints = [
            localProtectionActivatedContainer.topAnchor.constraint(equalTo: localProtectionHeaderContainer.bottomAnchor, constant: QwantUX.Spacing.m),
            localProtectionActivatedContainer.leadingAnchor.constraint(equalTo: localProtectionView.leadingAnchor),
            localProtectionActivatedContainer.trailingAnchor.constraint(equalTo: localProtectionView.trailingAnchor),
            localProtectionActivatedContainer.bottomAnchor.constraint(equalTo: localProtectionView.bottomAnchor),
            
            localProtectionSubtitleLabel.topAnchor.constraint(equalTo: localProtectionActivatedContainer.topAnchor, constant: QwantUX.Spacing.xxxs),
            localProtectionSubtitleLabel.centerXAnchor.constraint(equalTo: localProtectionActivatedContainer.centerXAnchor),
            localProtectionSubtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: localProtectionActivatedContainer.leadingAnchor, constant: QwantUX.Spacing.m),
            
            localProtectionConnectionLabel.topAnchor.constraint(equalTo: localProtectionSubtitleLabel.bottomAnchor, constant: QwantUX.Spacing.xxxs),
            localProtectionConnectionLabel.centerXAnchor.constraint(equalTo: localProtectionActivatedContainer.centerXAnchor, constant: (15 + QwantUX.Spacing.xs) / 2), // (Image width + spacing) / 2
            localProtectionConnectionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: localProtectionActivatedContainer.leadingAnchor, constant: QwantUX.Spacing.m),
            localProtectionConnectionLabel.heightAnchor.constraint(equalToConstant: 15),
            
            localProtectionConnectionImage.trailingAnchor.constraint(equalTo: localProtectionConnectionLabel.leadingAnchor, constant: -QwantUX.Spacing.xs),
            localProtectionConnectionImage.centerYAnchor.constraint(equalTo: localProtectionConnectionLabel.centerYAnchor),
            localProtectionConnectionImage.heightAnchor.constraint(equalToConstant: 15),
            localProtectionConnectionImage.widthAnchor.constraint(equalToConstant: 15),
            
            localProtectionSeparatorLine.topAnchor.constraint(equalTo: localProtectionConnectionImage.bottomAnchor, constant: QwantUX.Spacing.m),
            localProtectionSeparatorLine.leadingAnchor.constraint(equalTo: localProtectionActivatedContainer.leadingAnchor, constant: QwantUX.Spacing.m),
            localProtectionSeparatorLine.heightAnchor.constraint(equalToConstant: 1),
            localProtectionSeparatorLine.trailingAnchor.constraint(equalTo: localProtectionActivatedContainer.trailingAnchor),
            
            localProtectionLabel.leadingAnchor.constraint(equalTo: localProtectionActivatedContainer.leadingAnchor, constant: QwantUX.Spacing.m),
            localProtectionLabel.trailingAnchor.constraint(greaterThanOrEqualTo: localProtectionToggle.leadingAnchor, constant: -QwantUX.Spacing.m),
            localProtectionLabel.centerYAnchor.constraint(equalTo: localProtectionToggle.centerYAnchor),
            
            localProtectionToggle.topAnchor.constraint(equalTo: localProtectionSeparatorLine.bottomAnchor, constant: QwantUX.Spacing.xs),
            localProtectionToggle.trailingAnchor.constraint(equalTo: localProtectionActivatedContainer.trailingAnchor, constant: -QwantUX.Spacing.m),
            localProtectionToggle.bottomAnchor.constraint(equalTo: localProtectionActivatedContainer.bottomAnchor, constant: -QwantUX.Spacing.xs),
            
            localProtectionActivityIndicator.centerYAnchor.constraint(equalTo: localProtectionToggle.centerYAnchor),
            localProtectionActivityIndicator.centerXAnchor.constraint(equalTo: localProtectionToggle.centerXAnchor)
        ]
        
        let localProtectionDeactivatedContainerConstraints = [
            localProtectionDeactivatedContainer.topAnchor.constraint(equalTo: localProtectionHeaderContainer.bottomAnchor, constant: QwantUX.Spacing.m),
            localProtectionDeactivatedContainer.leadingAnchor.constraint(equalTo: localProtectionView.leadingAnchor),
            localProtectionDeactivatedContainer.trailingAnchor.constraint(equalTo: localProtectionView.trailingAnchor),
            localProtectionDeactivatedContainer.bottomAnchor.constraint(equalTo: localProtectionView.bottomAnchor),
            
            localProtectionActivationButton.topAnchor.constraint(equalTo: localProtectionDeactivatedContainer.topAnchor, constant: QwantUX.Spacing.m),
            localProtectionActivationButton.heightAnchor.constraint(equalToConstant: 36),
            localProtectionActivationButton.leadingAnchor.constraint(equalTo: localProtectionDeactivatedContainer.leadingAnchor, constant: QwantUX.Spacing.m),
            localProtectionActivationButton.trailingAnchor.constraint(equalTo: localProtectionDeactivatedContainer.trailingAnchor, constant: -QwantUX.Spacing.m),
            localProtectionActivationButton.bottomAnchor.constraint(equalTo: localProtectionDeactivatedContainer.bottomAnchor, constant: -QwantUX.Spacing.m),
        ]
        
        constraints.append(contentsOf: [
            localProtectionDetailsButton.topAnchor.constraint(equalTo: localProtectionHeaderContainer.topAnchor),
            localProtectionDetailsButton.leadingAnchor.constraint(equalTo: localProtectionHeaderContainer.leadingAnchor),
            localProtectionDetailsButton.trailingAnchor.constraint(equalTo: localProtectionHeaderContainer.trailingAnchor),
            localProtectionDetailsButton.bottomAnchor.constraint(equalTo: localProtectionSeparatorLine.bottomAnchor),
            
            localProtectionView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: QwantUX.Spacing.m),
            localProtectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            localProtectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            localProtectionFooterLabel.topAnchor.constraint(equalTo: localProtectionView.bottomAnchor, constant: QwantUX.Spacing.xs),
            localProtectionFooterLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.xxl),
            localProtectionFooterLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.xxl),
        ])
        
        constraints.append(contentsOf: localProtectionHeaderContainerConstraints)
        if viewModel.globalETPIsEnabled {
            constraints.append(contentsOf: localProtectionActivatedContainerConstraints)
        } else {
            constraints.append(contentsOf: localProtectionDeactivatedContainerConstraints)
        }
    }
    
    private func setupProtectionLevelView() {
        protectionLevelView.addSubviews(protectionLevelDetailsButton, protectionLevelTitleLabel, protectionLevelSubtitleLabel, protectionLevelDetailsArrow)
        contentView.addSubview(protectionLevelView)
        
        let topAnchor = !viewModel.globalETPIsEnabled ? localProtectionView.bottomAnchor : localProtectionFooterLabel.bottomAnchor

        constraints.append(contentsOf: [
            protectionLevelView.topAnchor.constraint(equalTo: topAnchor, constant: QwantUX.Spacing.xxl),
            protectionLevelView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            protectionLevelView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            protectionLevelTitleLabel.topAnchor.constraint(equalTo: protectionLevelView.topAnchor, constant: QwantUX.Spacing.s),
            protectionLevelTitleLabel.leadingAnchor.constraint(equalTo: protectionLevelView.leadingAnchor, constant: QwantUX.Spacing.m),
            protectionLevelTitleLabel.bottomAnchor.constraint(equalTo: protectionLevelView.bottomAnchor, constant: -QwantUX.Spacing.s),
            
            protectionLevelSubtitleLabel.centerYAnchor.constraint(equalTo: protectionLevelTitleLabel.centerYAnchor),
            protectionLevelSubtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: protectionLevelTitleLabel.trailingAnchor, constant: QwantUX.Spacing.m),
            
            protectionLevelDetailsArrow.centerYAnchor.constraint(equalTo: protectionLevelTitleLabel.centerYAnchor),
            protectionLevelDetailsArrow.leadingAnchor.constraint(equalTo: protectionLevelSubtitleLabel.trailingAnchor, constant: QwantUX.Spacing.s),
            protectionLevelDetailsArrow.trailingAnchor.constraint(equalTo: protectionLevelView.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            protectionLevelDetailsButton.topAnchor.constraint(equalTo: protectionLevelView.topAnchor),
            protectionLevelDetailsButton.leadingAnchor.constraint(equalTo: protectionLevelView.leadingAnchor),
            protectionLevelDetailsButton.trailingAnchor.constraint(equalTo: protectionLevelView.trailingAnchor),
            protectionLevelDetailsButton.bottomAnchor.constraint(equalTo: protectionLevelView.bottomAnchor)
        ])
    }
    
    private func setupStatisticsView() {
        statisticsLeftView.addSubviews(statisticsLeftTitle, statisticsLeftValue, statisticsLeftImage)
        statisticsRightView.addSubviews(statisticsRightTitle, statisticsRightValue, statisticsRightImage)
        contentView.addSubviews(statisticsLeftView, statisticsRightView, statisticsDetailsButton)

        constraints.append(contentsOf: [
            statisticsLeftView.topAnchor.constraint(equalTo: protectionLevelView.bottomAnchor, constant: QwantUX.Spacing.xl),
            statisticsLeftView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            statisticsLeftView.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -QwantUX.Spacing.xxs),

            statisticsLeftTitle.topAnchor.constraint(equalTo: statisticsLeftView.topAnchor, constant: QwantUX.Spacing.s),
            statisticsLeftTitle.leadingAnchor.constraint(equalTo: statisticsLeftView.leadingAnchor, constant: QwantUX.Spacing.m),
            statisticsLeftTitle.trailingAnchor.constraint(equalTo: statisticsLeftView.trailingAnchor, constant: -QwantUX.Spacing.m),

            statisticsLeftValue.topAnchor.constraint(equalTo: statisticsLeftTitle.bottomAnchor, constant: QwantUX.Spacing.xs),
            statisticsLeftValue.leadingAnchor.constraint(equalTo: statisticsLeftView.leadingAnchor, constant: QwantUX.Spacing.m),
            statisticsLeftValue.trailingAnchor.constraint(greaterThanOrEqualTo: statisticsLeftImage.leadingAnchor, constant: QwantUX.Spacing.s),
            statisticsLeftValue.bottomAnchor.constraint(equalTo: statisticsLeftView.bottomAnchor, constant: -QwantUX.Spacing.s),

            statisticsLeftImage.trailingAnchor.constraint(equalTo: statisticsLeftView.trailingAnchor, constant: -QwantUX.Spacing.m),
            statisticsLeftImage.bottomAnchor.constraint(equalTo: statisticsLeftView.bottomAnchor, constant: -QwantUX.Spacing.s),
            statisticsLeftImage.widthAnchor.constraint(equalToConstant: 28),
            statisticsLeftImage.heightAnchor.constraint(equalToConstant: 28),

            statisticsRightView.topAnchor.constraint(equalTo: protectionLevelView.bottomAnchor, constant: QwantUX.Spacing.xl),
            statisticsRightView.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: QwantUX.Spacing.xxs),
            statisticsRightView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            statisticsRightView.heightAnchor.constraint(equalTo: statisticsRightView.heightAnchor),

            statisticsRightTitle.topAnchor.constraint(equalTo: statisticsRightView.topAnchor, constant: QwantUX.Spacing.s),
            statisticsRightTitle.leadingAnchor.constraint(equalTo: statisticsRightView.leadingAnchor, constant: QwantUX.Spacing.m),
            statisticsRightTitle.trailingAnchor.constraint(equalTo: statisticsRightView.trailingAnchor, constant: -QwantUX.Spacing.m),

            statisticsRightValue.topAnchor.constraint(equalTo: statisticsRightTitle.bottomAnchor, constant: QwantUX.Spacing.xs),
            statisticsRightValue.leadingAnchor.constraint(equalTo: statisticsRightView.leadingAnchor, constant: QwantUX.Spacing.m),
            statisticsRightValue.trailingAnchor.constraint(greaterThanOrEqualTo: statisticsRightImage.leadingAnchor, constant: QwantUX.Spacing.s),
            statisticsRightValue.bottomAnchor.constraint(equalTo: statisticsRightView.bottomAnchor, constant: -QwantUX.Spacing.s),

            statisticsRightImage.trailingAnchor.constraint(equalTo: statisticsRightView.trailingAnchor, constant: -QwantUX.Spacing.m),
            statisticsRightImage.bottomAnchor.constraint(equalTo: statisticsRightView.bottomAnchor, constant: -QwantUX.Spacing.s),
            statisticsRightImage.widthAnchor.constraint(equalToConstant: 28),
            statisticsRightImage.heightAnchor.constraint(equalToConstant: 28),

            statisticsDetailsButton.topAnchor.constraint(equalTo: statisticsLeftView.bottomAnchor, constant: QwantUX.Spacing.xs),
            statisticsDetailsButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            statisticsDetailsButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m)
        ])
    }
    
    private func setupInformationView() {
        informationView.addSubviews(informationTitleLabel, informationDetailsArrow, informationDetailsButton)
        contentView.addSubview(informationView)
        
        constraints.append(contentsOf: [
            informationView.topAnchor.constraint(equalTo: statisticsDetailsButton.bottomAnchor, constant: QwantUX.Spacing.xl),
            informationView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            informationView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            informationTitleLabel.topAnchor.constraint(equalTo: informationView.topAnchor, constant: QwantUX.Spacing.s),
            informationTitleLabel.leadingAnchor.constraint(equalTo: informationView.leadingAnchor, constant: QwantUX.Spacing.m),
            informationTitleLabel.bottomAnchor.constraint(equalTo: informationView.bottomAnchor, constant: -QwantUX.Spacing.s),
                        
            informationDetailsArrow.centerYAnchor.constraint(equalTo: informationTitleLabel.centerYAnchor),
            informationDetailsArrow.leadingAnchor.constraint(greaterThanOrEqualTo: informationTitleLabel.trailingAnchor, constant: QwantUX.Spacing.s),
            informationDetailsArrow.trailingAnchor.constraint(equalTo: informationView.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            informationDetailsButton.topAnchor.constraint(equalTo: informationView.topAnchor),
            informationDetailsButton.leadingAnchor.constraint(equalTo: informationView.leadingAnchor),
            informationDetailsButton.trailingAnchor.constraint(equalTo: informationView.trailingAnchor),
            informationDetailsButton.bottomAnchor.constraint(equalTo: informationView.bottomAnchor)
        ])
        
        if !viewModel.mailHelper.canSendMail() {
            constraints.append(informationView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -QwantUX.Spacing.m))
        }
    }
    
    private func setupMailView() {
        mailView.addSubviews(mailTitleLabel, mailDetailsExternal, mailDetailsButton)
        contentView.addSubview(mailView)
        
        guard viewModel.mailHelper.canSendMail() else { return }
        
        constraints.append(contentsOf: [
            mailView.topAnchor.constraint(equalTo: informationView.bottomAnchor, constant: QwantUX.Spacing.xl),
            mailView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: QwantUX.Spacing.m),
            mailView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -QwantUX.Spacing.m),
            mailView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -QwantUX.Spacing.m),

            mailTitleLabel.topAnchor.constraint(equalTo: mailView.topAnchor, constant: QwantUX.Spacing.s),
            mailTitleLabel.leadingAnchor.constraint(equalTo: mailView.leadingAnchor, constant: QwantUX.Spacing.m),
            mailTitleLabel.bottomAnchor.constraint(equalTo: mailView.bottomAnchor, constant: -QwantUX.Spacing.s),
            
            mailDetailsExternal.centerYAnchor.constraint(equalTo: mailTitleLabel.centerYAnchor),
            mailDetailsExternal.leadingAnchor.constraint(greaterThanOrEqualTo: mailTitleLabel.trailingAnchor, constant: QwantUX.Spacing.s),
            mailDetailsExternal.trailingAnchor.constraint(equalTo: mailView.trailingAnchor, constant: -QwantUX.Spacing.m),
            
            mailDetailsButton.topAnchor.constraint(equalTo: mailView.topAnchor),
            mailDetailsButton.leadingAnchor.constraint(equalTo: mailView.leadingAnchor),
            mailDetailsButton.trailingAnchor.constraint(equalTo: mailView.trailingAnchor),
            mailDetailsButton.bottomAnchor.constraint(equalTo: mailView.bottomAnchor),
        ])
    }
    
    override func updateViewDetails() {
        super.updateViewDetails()
        navigationItem.setLeftBarButton(imageIcon, animated: false)

        localProtectionShieldCounterLabel.text = viewModel.globalETPIsEnabled && viewModel.isSiteETPEnabled ? String(describing: viewModel.blockedTrackersCount) : nil
        localProtectionTitleLabel.text = viewModel.protectionTitleString
        localProtectionSubtitleLabel.text = viewModel.websiteTitle
        localProtectionSubtitleLabel.isHidden = !viewModel.globalETPIsEnabled
        localProtectionConnectionImage.isHidden = !viewModel.globalETPIsEnabled
        localProtectionConnectionLabel.text = viewModel.connectionStatusString
        localProtectionConnectionLabel.isHidden = !viewModel.globalETPIsEnabled
        localProtectionSeparatorLine.isHidden = !viewModel.globalETPIsEnabled
        localProtectionLabel.text = viewModel.protectionStatusString
        localProtectionLabel.isHidden = !viewModel.globalETPIsEnabled
        localProtectionToggle.isOn = viewModel.isSiteETPEnabled
        localProtectionToggle.isHidden = !viewModel.globalETPIsEnabled || viewModel.isSiteETPEnabling
        localProtectionActivityIndicator.isHidden = !viewModel.globalETPIsEnabled || !viewModel.isSiteETPEnabling
        localProtectionActivationButton.isHidden = viewModel.globalETPIsEnabled
        localProtectionDetailArrow.isHidden = !viewModel.isSiteETPEnabled || !viewModel.globalETPIsEnabled || viewModel.isSiteETPEnabling
        localProtectionDetailsButton.isHidden = !viewModel.isSiteETPEnabled || !viewModel.globalETPIsEnabled || viewModel.isSiteETPEnabling
        localProtectionFooterLabel.text = viewModel.protectionStatusDetailString
        localProtectionFooterLabel.isHidden = !viewModel.globalETPIsEnabled

        protectionLevelTitleLabel.text = viewModel.trackingProtectionTitleString
        protectionLevelSubtitleLabel.text = viewModel.trackingProtectionValueString

        statisticsLeftTitle.text = viewModel.statisticsBlockedTrackersTitleString
        statisticsLeftValue.text = viewModel.statisticsTrackersBlockedFormattedString
        statisticsRightTitle.text = viewModel.statisticsSavedTimeTitleString
        statisticsRightValue.text = viewModel.statisticsTimeSavedFormattedString
        statisticsDetailsButton.setTitle(viewModel.statisticsSeeDetails, for: .normal)

        informationTitleLabel.text = viewModel.informationTitle

        mailTitleLabel.text = viewModel.mailTitle
        mailView.isHidden = !viewModel.mailHelper.canSendMail()
        mailTitleLabel.isHidden = !viewModel.mailHelper.canSendMail()
        mailDetailsExternal.isHidden = !viewModel.mailHelper.canSendMail()
        mailDetailsButton.isHidden = !viewModel.mailHelper.canSendMail()
    }

    // MARK: - Button actions
    
    @objc private func didActivateTrackingProtection() {
        viewModel.activateTrackingProtection()
        updateViewDetails()
        setupView()
        applyTheme()
    }
    
    @objc private func localProtectionDetailsTapped() {
        guard let controller = viewModel.getDetailsViewController() else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func didChangeSwitchState() {
        // site is safelisted if site ETP is disabled
        viewModel.toggleSiteSafelistStatus() { [weak self] in
            self?.updateViewDetails()
            self?.setupView()
            self?.applyTheme()
        }
        updateViewDetails()
        setupView()
        applyTheme()
    }
    
    @objc private func protectionSettingsTapped() {
        let controller = viewModel.getProtectionSettingsViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func statisticsTapped() {
        guard let controller = viewModel.getStatsViewController() else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func informationDetailsTapped() {
        self.navigationController?.pushViewController(viewModel.getInformationViewController(), animated: true)
    }
    
    @objc private func sendMailTapped() {
        viewModel.mailHelper.sendMail(self.navigationController)
    }

    override func applyTheme() {
        super.applyTheme()
        let theme = themeManager.currentTheme

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = theme.colors.vip_background
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance

        localProtectionView.backgroundColor = theme.colors.vip_sectionColor
        localProtectionShieldImage.image = viewModel.shieldImage
        localProtectionShieldCounterLabel.textColor = theme.colors.vip_blackText
        localProtectionTitleLabel.textColor = theme.colors.vip_textColor
        localProtectionSubtitleLabel.textColor = theme.colors.vip_textColor
        localProtectionDetailArrow.tintColor = theme.colors.vip_subtextColor

        localProtectionConnectionImage.image = viewModel.connectionStatusImage
        if viewModel.connectionSecure {
            localProtectionConnectionImage.tintColor = theme.colors.vip_subtextColor
        }
        localProtectionConnectionLabel.textColor = theme.colors.vip_subtextColor
        localProtectionSeparatorLine.backgroundColor = theme.colors.vip_horizontalLine
        localProtectionLabel.textColor = viewModel.protectionStatusColor
        localProtectionToggle.onTintColor = theme.colors.vip_greenText
        localProtectionToggle.tintColor = theme.colors.vip_redText
        localProtectionToggle.backgroundColor = theme.colors.vip_redText
        localProtectionToggle.subviews.first?.subviews.first?.backgroundColor = .clear

        localProtectionActivationButton.setTitleColor(theme.colors.vip_background, for: .normal)
        localProtectionActivationButton.backgroundColor = theme.colors.vip_switchAndButtonTint

        localProtectionDetailsButton.backgroundColor = .clear

        localProtectionFooterLabel.textColor = theme.colors.vip_subtextColor

        protectionLevelView.backgroundColor = theme.colors.vip_sectionColor
        protectionLevelTitleLabel.textColor = theme.colors.vip_textColor
        protectionLevelSubtitleLabel.textColor = theme.colors.vip_subtextColor
        protectionLevelDetailsArrow.tintColor = theme.colors.vip_subtextColor

        statisticsLeftView.backgroundColor = theme.colors.vip_sectionColor
        statisticsLeftTitle.textColor = theme.colors.vip_textColor
        statisticsLeftValue.textColor = theme.colors.vip_textColor

        statisticsRightView.backgroundColor = theme.colors.vip_sectionColor
        statisticsRightTitle.textColor = theme.colors.vip_textColor
        statisticsRightValue.textColor = theme.colors.vip_textColor

        statisticsDetailsButton.setTitleColor(theme.colors.vip_switchAndButtonTint, for: .normal)

        informationView.backgroundColor = theme.colors.vip_sectionColor
        informationTitleLabel.textColor = theme.colors.vip_textColor
        informationDetailsArrow.tintColor = theme.colors.vip_subtextColor

        mailView.backgroundColor = theme.colors.vip_sectionColor
        mailTitleLabel.textColor = theme.colors.vip_textColor

        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupView()
    }
}

extension QwantTPMenuVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
