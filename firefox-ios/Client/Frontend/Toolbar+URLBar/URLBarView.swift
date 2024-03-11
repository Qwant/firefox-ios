// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Shared
import SnapKit
import UIKit

private struct URLBarViewUX {
    static let LocationLeftPadding: CGFloat = 8
    static let Padding: CGFloat = 10
    static let LocationHeight: CGFloat = 44
    static let ButtonHeight: CGFloat = 44
    static let LocationContentOffset: CGFloat = 8
    static let TextFieldCornerRadius: CGFloat = 8
    static let TextFieldBorderWidth: CGFloat = 1
    static let TextFieldBorderWidthSelected: CGFloat = 1
    static let ProgressBarHeight: CGFloat = 3
    static let SearchIconImageWidth: CGFloat = 30
    static let TabsButtonRotationOffset: CGFloat = 1.5
    static let TabsButtonHeight: CGFloat = 18.0
    static let ToolbarButtonInsets = UIEdgeInsets(equalInset: Padding)
    static let urlBarLineHeight = 0.5
}

protocol URLBarDelegate: AnyObject {
    func urlBarDidPressTabs(_ urlBar: URLBarView)
    func urlBarDidPressReaderMode(_ urlBar: URLBarView)
    /// - returns: whether the long-press was handled by the delegate; i.e. return `false` when the conditions
    ///            for even starting handling long-press were not satisfied
    func urlBarDidLongPressReaderMode(_ urlBar: URLBarView) -> Bool
    func urlBarDidLongPressReload(_ urlBar: URLBarView, from button: UIButton)
    func urlBarDidPressStop(_ urlBar: URLBarView)
    func urlBarDidPressReload(_ urlBar: URLBarView)
    func urlBarDidEnterOverlayMode(_ urlBar: URLBarView)
    func urlBarDidLeaveOverlayMode(_ urlBar: URLBarView)
    func urlBarDidLongPressLocation(_ urlBar: URLBarView)
    func urlBarDidPressQRButton(_ urlBar: URLBarView)
    func urlBarDidTapShield(_ urlBar: URLBarView)
    func urlBarLocationAccessibilityActions(_ urlBar: URLBarView) -> [UIAccessibilityCustomAction]?
    func urlBarDidPressScrollToTop(_ urlBar: URLBarView)
    func urlBar(_ urlBar: URLBarView, didRestoreText text: String)
    func urlBar(_ urlBar: URLBarView, didEnterText text: String)
    func urlBar(_ urlBar: URLBarView, didSubmitText text: String)
    // Returns either (search query, true) or (url, false).
    func urlBarDisplayTextForURL(_ url: URL?) -> (String?, Bool)
    func urlBarDidBeginDragInteraction(_ urlBar: URLBarView)
    func urlBarDidPressShare(_ urlBar: URLBarView, shareView: UIView)
    func urlBarPresentCFR(at sourceView: UIView)
}

protocol URLBarViewProtocol {
    var inOverlayMode: Bool { get }
    func enterOverlayMode(_ locationText: String?, pasted: Bool, search: Bool)
    func leaveOverlayMode(didCancel cancel: Bool)
}

extension URLBarViewProtocol {
    func leaveOverlayMode(didCancel cancel: Bool = false) {
        leaveOverlayMode(didCancel: cancel)
    }
}

class URLBarView: UIView, URLBarViewProtocol, AlphaDimmable, TopBottomInterchangeable,
                  SearchEngineDelegate, SearchBarLocationProvider,
                  UIGestureRecognizerDelegate {
    // Additional UIAppearance-configurable properties
    @objc dynamic lazy var locationBorderColor: UIColor = .clear {
        didSet {
            locationContainer.layer.borderColor = locationBorderColor.cgColor
        }
    }

    var parent: UIStackView?
    var searchEngines: SearchEngines?
    weak var delegate: URLBarDelegate?
    weak var tabToolbarDelegate: TabToolbarDelegate?
    var helper: TabToolbarHelper?
    var isTransitioning = false {
        didSet {
            if isTransitioning {
                // Cancel any pending/in-progress animations related to the progress bar
                self.progressBar.setProgress(1, animated: false)
                self.progressBar.alpha = 0.0
            }
        }
    }

    var toolbarIsShowing = false
    var topTabsIsShowing = false

    var locationTextField: ToolbarTextField?
    private var isActivatingLocationTextField = false
    private lazy var locationTextFieldMultistateButton: UIButton = .build { button in
        button.setImage(UIImage.templateImageNamed("qwant_search"), for: .normal)
        button.addTarget(self, action: #selector(self.clearLocationTextField), for: .touchUpInside)
    }

    /// Overlay mode is the state where the lock/reader icons are hidden, the home panels are shown,
    /// and the Cancel button is visible (allowing the user to leave overlay mode).
    var inOverlayMode = false
    var isKeyboardShowing = false

    lazy var locationView: TabLocationView = {
        let locationView = TabLocationView()
        locationView.layer.cornerRadius = URLBarViewUX.ButtonHeight/2
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.delegate = self
        return locationView
    }()

    lazy var locationContainer: UIView = {
        let locationContainer = TabLocationContainerView()
        locationContainer.translatesAutoresizingMaskIntoConstraints = false
        locationContainer.backgroundColor = .clear
        locationContainer.layer.cornerRadius = URLBarViewUX.ButtonHeight/2
        return locationContainer
    }()

    private let line = UIView()

    lazy var tabsButton: TabsButton = {
        let tabsButton = TabsButton()
        tabsButton.accessibilityLabel = .TabTrayButtonShowTabsAccessibilityLabel
        tabsButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.tabsButton
        return tabsButton
    }()

    fileprivate lazy var progressBar: GradientProgressBar = {
        let progressBar = GradientProgressBar()
        progressBar.clipsToBounds = false
        return progressBar
    }()

    fileprivate lazy var cancelButton: UIButton = {
        let cancelButton = InsetButton()
        let flippedChevron = UIImage.templateImageNamed(StandardImageIdentifiers.Large.chevronLeft)?
            .imageFlippedForRightToLeftLayoutDirection()

        cancelButton.setTitle(.ClearPrivateDataAlertCancel, for: .normal)
        cancelButton.accessibilityIdentifier = AccessibilityIdentifiers.Browser.UrlBar.cancelButton
        cancelButton.accessibilityLabel = AccessibilityIdentifiers.GeneralizedIdentifiers.back
        cancelButton.addTarget(self, action: #selector(didClickCancel), for: .touchUpInside)
        cancelButton.alpha = 0
        cancelButton.showsLargeContentViewer = true
        cancelButton.largeContentTitle = AccessibilityIdentifiers.GeneralizedIdentifiers.back
        cancelButton.largeContentImage = flippedChevron
        return cancelButton
    }()

    fileprivate lazy var iconView: UIView = {
        let image = UIImageView(image: UIImage(imageLiteralResourceName: "qwant_Q"))
        image.translatesAutoresizingMaskIntoConstraints = false

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = URLBarViewUX.SearchIconImageWidth/2
        view.clipsToBounds = true
        view.addSubview(image)

        let padding = 5.0
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
        ])
        return view
    }()

    var appMenuButton = ToolbarButton()
    var bookmarksButton = ToolbarButton()
    var addNewTabButton = ToolbarButton()
    var forwardButton = ToolbarButton()
    var multiStateButton = ToolbarButton()
    var zapButton = ZapButton()

    var backButton: ToolbarButton = {
        let backButton = ToolbarButton()
        backButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.backButton
        return backButton
    }()

    lazy var actionButtons: [ThemeApplicable & PrivateModeUI & UIButton] = [
        self.tabsButton,
        self.bookmarksButton,
        self.appMenuButton,
        self.addNewTabButton,
        self.forwardButton,
        self.backButton,
        self.multiStateButton,
        self.zapButton]

    var currentURL: URL? {
        get {
            return locationView.url as URL?
        }

        set(newURL) {
            locationView.url = newURL
        }
    }

    var profile: Profile

    fileprivate lazy var privateModeBadge = BadgeWithBackdrop(
        imageName: "qwant_private_badge",
        backdropCircleColor: .clear,
        badgePadding: 2
    )
    fileprivate let appMenuBadge = BadgeWithBackdrop(imageName: ImageIdentifiers.menuBadge)
    fileprivate let warningMenuBadge = BadgeWithBackdrop(
        imageName: ImageIdentifiers.menuWarning,
        imageMask: ImageIdentifiers.menuWarningMask
    )

    init(profile: Profile) {
        self.profile = profile
        self.searchEngines = SearchEngines(prefs: profile.prefs, files: profile.files)
        super.init(frame: CGRect())
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func searchEnginesDidUpdate() { }

    fileprivate func commonInit() {
        locationContainer.addSubview(locationView)

        [
            line,
            tabsButton,
            progressBar,
            cancelButton,
            bookmarksButton,
            appMenuButton,
            addNewTabButton,
            forwardButton,
            backButton,
            multiStateButton,
            locationContainer,
            iconView,
            zapButton
        ].forEach {
            addSubview($0)
        }

        privateModeBadge.add(toParent: self)
        appMenuBadge.add(toParent: self)
        warningMenuBadge.add(toParent: self)

        helper = TabToolbarHelper(toolbar: self)
        setupConstraints()

        // Make sure we hide any views that shouldn't be showing in non-overlay mode.
        updateViewsForOverlayModeAndToolbarChanges()

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        addGestureRecognizer(gesture)
        gesture.delegate = self
    }

    @objc
    private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        guard
            recognizer.state == .ended,
            isBottomSearchBar,
            !shouldUseiPadSetup()
        else { return }

        if recognizer.translation(in: self).y < -10 {
            dismissOverlayRequested = true
            didClickCancel()
            didClickAddTab()
        }
    }

    fileprivate func setupConstraints() {
        locationView.snp.makeConstraints { make in
            make.edges.equalTo(self.locationContainer)
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(self.locationContainer.snp.trailing)
            make.trailing.equalTo(self.safeArea.trailing)
            make.centerY.equalTo(self.locationContainer)
            make.height.equalTo(URLBarViewUX.ButtonHeight)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalTo(self.safeArea.leading).offset(URLBarViewUX.Padding)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        forwardButton.snp.makeConstraints { make in
            make.leading.equalTo(self.backButton.snp.trailing)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        iconView.snp.remakeConstraints { make in
            let heightMin = URLBarViewUX.LocationHeight + (URLBarViewUX.TextFieldBorderWidthSelected * 2)
            make.height.greaterThanOrEqualTo(heightMin)
            make.centerY.equalTo(self)
            make.leading.equalTo(self.locationContainer.snp.leading).offset(URLBarViewUX.LocationLeftPadding - 2)
            make.size.equalTo(URLBarViewUX.SearchIconImageWidth)
        }

        multiStateButton.snp.makeConstraints { make in
            make.leading.equalTo(self.forwardButton.snp.trailing)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        zapButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.addNewTabButton.snp.leading)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        bookmarksButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.appMenuButton.snp.leading)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        appMenuButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.safeArea.trailing).offset(-URLBarViewUX.Padding)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        addNewTabButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.tabsButton.snp.leading)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        tabsButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.appMenuButton.snp.leading)
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        privateModeBadge.layout(onButton: tabsButton)
        appMenuBadge.layout(onButton: appMenuButton)
        warningMenuBadge.layout(onButton: appMenuButton)
    }

    override func updateConstraints() {
        super.updateConstraints()

        line.snp.remakeConstraints { make in
            if isBottomSearchBar {
                make.top.equalTo(self)
            } else {
                make.bottom.equalTo(self).offset(URLBarViewUX.urlBarLineHeight)
            }

            make.leading.trailing.equalTo(self)
            make.height.equalTo(URLBarViewUX.urlBarLineHeight)
        }

        progressBar.snp.remakeConstraints { make in
            if isBottomSearchBar {
                make.bottom.equalTo(snp.top).inset(URLBarViewUX.ProgressBarHeight / 2)
            } else {
                make.top.equalTo(snp.bottom).inset(URLBarViewUX.ProgressBarHeight / 2)
            }

            make.height.equalTo(URLBarViewUX.ProgressBarHeight)
            make.left.right.equalTo(self)
        }

        zapButton.snp.remakeConstraints { make in
            if topTabsIsShowing {
                make.trailing.equalTo(self.bookmarksButton.snp.leading)
            } else {
                make.trailing.equalTo(self.addNewTabButton.snp.leading)
            }
            make.centerY.equalTo(self)
            make.size.equalTo(URLBarViewUX.ButtonHeight)
        }

        if inOverlayMode {
            iconView.alpha = 1
            // In overlay mode, we always show the location view full width
            self.locationContainer.layer.borderWidth = URLBarViewUX.TextFieldBorderWidthSelected
            self.locationContainer.snp.remakeConstraints { make in
                let heightMin = URLBarViewUX.LocationHeight + (URLBarViewUX.TextFieldBorderWidthSelected * 2)
                make.height.greaterThanOrEqualTo(heightMin)
                if shouldUseiPadSetup() {
                    make.leading.equalTo(self.forwardButton.snp.trailing).offset(URLBarViewUX.Padding)
                    make.trailing.equalTo(self.zapButton.snp.leading).offset(-URLBarViewUX.Padding)
                } else {
                    make.leading.equalTo(self.safeArea.leading).inset(
                        UIEdgeInsets(
                            top: 0,
                            left: URLBarViewUX.LocationLeftPadding-1,
                            bottom: 0,
                            right: 0
                        )
                    )
                    make.trailing.equalTo(self.cancelButton.snp.leading).inset(
                        UIEdgeInsets(
                            top: 0,
                            left: -URLBarViewUX.LocationLeftPadding+1,
                            bottom: 0,
                            right: -URLBarViewUX.LocationLeftPadding+1
                        )
                    )
                }
                make.centerY.equalTo(self)
            }
            self.locationView.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationContainer).inset(
                    UIEdgeInsets(
                        equalInset: URLBarViewUX.TextFieldBorderWidthSelected
                    )
                )
            }
            self.locationTextField?.snp.remakeConstraints { make in
                make.top.bottom.trailing.equalTo(self.locationView).inset(
                    UIEdgeInsets(
                        top: 4,
                        left: URLBarViewUX.LocationLeftPadding,
                        bottom: 4,
                        right: URLBarViewUX.LocationLeftPadding
                    )
                )
                make.leading.equalTo(self.iconView.snp.trailing).inset(
                    UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: -URLBarViewUX.LocationLeftPadding
                    )
                )
            }
            self.cancelButton.snp.remakeConstraints { make in
                make.leading.equalTo(self.locationContainer.snp.trailing)
                make.trailing.equalTo(self.safeArea.trailing).inset(
                    UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: URLBarViewUX.LocationLeftPadding
                    )
                )
                make.centerY.equalTo(self.locationContainer)
                make.height.equalTo(URLBarViewUX.ButtonHeight)
                make.width.equalTo(self.cancelButton.intrinsicContentSize.width + URLBarViewUX.LocationLeftPadding)
            }
        } else {
            iconView.alpha = 0
            self.locationContainer.snp.remakeConstraints { make in
                if self.toolbarIsShowing {
                    // If we are showing a toolbar, show the text field next to the forward button
                    make.leading.equalTo(self.forwardButton.snp.trailing).offset(URLBarViewUX.Padding)
                    make.trailing.equalTo(self.zapButton.snp.leading).offset(-URLBarViewUX.Padding)
                } else {
                    // Otherwise, left align the location view
                    make.leading.trailing.equalTo(self).inset(
                        UIEdgeInsets(
                            top: 0,
                            left: URLBarViewUX.LocationLeftPadding-1,
                            bottom: 0,
                            right: URLBarViewUX.LocationLeftPadding-1
                        )
                    )
                }
                let height = URLBarViewUX.LocationHeight + (URLBarViewUX.TextFieldBorderWidthSelected * 2)
                make.height.greaterThanOrEqualTo(height)
                make.centerY.equalTo(self)
            }
            self.locationContainer.layer.borderWidth = URLBarViewUX.TextFieldBorderWidth
            self.locationView.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationContainer).inset(
                    UIEdgeInsets(
                        equalInset: URLBarViewUX.TextFieldBorderWidth
                    )
                )
            }
        }
    }

    @objc
    func showQRScanner() {
        self.delegate?.urlBarDidPressQRButton(self)
    }

    func createLocationTextField() {
        guard locationTextField == nil else { return }

        locationTextField = ToolbarTextField()
        guard let locationTextField = locationTextField else { return }

        locationTextField.autocompleteDelegate = self
        locationTextField.accessibilityIdentifier = AccessibilityIdentifiers.Browser.UrlBar.searchTextField
        locationTextField.accessibilityLabel = .URLBarLocationAccessibilityLabel
        locationContainer.addSubview(locationTextField)

        // Disable dragging urls on iPhones because it conflicts with editing the text
        if UIDevice.current.userInterfaceIdiom != .pad {
            locationTextField.textDragInteraction?.isEnabled = false
        }
    }

    func qwantLocationTextFieldSetup() {
        locationTextField!.clearButtonMode = .never
        locationTextField!.rightViewMode = .always
        locationTextField!.rightView = locationTextFieldMultistateButton
        locationView.reloadButton.isHidden = false
    }

    override func becomeFirstResponder() -> Bool {
        return self.locationTextField?.becomeFirstResponder() ?? false
    }

    func removeLocationTextField() {
        locationTextField?.removeFromSuperview()
        locationTextField = nil
    }

    /// Ideally we'd split this implementation in two, one URLBarView with a toolbar and one without
    /// However, switching views dynamically at runtime is a difficult. For now, we just use one view
    /// that can show in either mode.
    func setShowToolbar(_ shouldShow: Bool) {
        toolbarIsShowing = shouldShow
        setNeedsUpdateConstraints()
        // when we transition from portrait to landscape, calling this here causes
        // the constraints to be calculated too early and there are constraint errors
        if !toolbarIsShowing {
            updateConstraintsIfNeeded()
        }
        updateViewsForOverlayModeAndToolbarChanges()
    }

    func updateAlphaForSubviews(_ alpha: CGFloat) {
        locationContainer.alpha = alpha
        self.alpha = alpha
    }

    func updateProgressBar(_ progress: Float) {
        progressBar.alpha = 1
        progressBar.isHidden = false
        progressBar.setProgress(progress, animated: !isTransitioning)
    }

    func hideProgressBar() {
        progressBar.isHidden = true
        progressBar.setProgress(0, animated: false)
    }

    func updateReaderModeState(_ state: ReaderModeState) {
        locationView.readerModeState = state
    }

    func setAutocompleteSuggestion(_ suggestion: String?) {
        locationTextField?.setAutocompleteSuggestion(suggestion)
    }

    func setLocation(_ location: String?, search: Bool) {
        guard let text = location, !text.isEmpty else {
            locationTextField?.text = location
            return
        }

        if let url = URL(string: text), url.isQwantHPUrl {
            locationTextField?.text = ""
            return
        }

        if search {
            locationTextField?.text = text
            // Not notifying when empty agrees with AutocompleteTextField.textDidChange.
            delegate?.urlBar(self, didRestoreText: text)
        } else {
            locationTextField?.setTextWithoutSearching(text)
        }
    }

    func enterOverlayMode(_ locationText: String?, pasted: Bool, search: Bool) {
        createLocationTextField()
        qwantLocationTextFieldSetup()
        locationView.connectionStatusImage.isHidden = true

        // Show the overlay mode UI, which includes hiding the locationView and replacing it
        // with the editable locationTextField.
        animateToOverlayState(overlayMode: true)

        delegate?.urlBarDidEnterOverlayMode(self)

        // Bug 1193755 Workaround - Calling becomeFirstResponder before the animation happens
        // won't take the initial frame of the label into consideration, which makes the label
        // look squished at the start of the animation and expand to be correct. As a workaround,
        // we becomeFirstResponder as the next event on UI thread, so the animation starts before we
        // set a first responder.
        if pasted {
            // Clear any existing text, focus the field, then set the actual pasted text.
            // This avoids highlighting all of the text.
            self.locationTextField?.text = ""
            self.isActivatingLocationTextField = true
            DispatchQueue.main.async {
                self.locationTextField?.becomeFirstResponder()
                self.setLocation(locationText, search: search)
                self.isActivatingLocationTextField = false
            }
        } else {
            self.isActivatingLocationTextField = true
            DispatchQueue.main.async {
                self.locationTextField?.becomeFirstResponder()
                // Need to set location again so text could be immediately selected.
                self.setLocation(locationText, search: search)
                self.locationTextField?.selectAll(nil)
                self.isActivatingLocationTextField = false
            }
        }
    }

    func leaveOverlayMode(didCancel cancel: Bool) {
        // This check is a bandaid to prevent conflicts between code that might cancel overlay mode
        // incorrectly while we are still waiting to activate the location field in the next run
        // loop iteration (because the becomeFirstResponder call is dispatched). If we know that we
        // are expecting the location field to be activated, skip this and return early. [FXIOS-8421]
        guard !isActivatingLocationTextField else { return }

        locationTextField?.resignFirstResponder()
        locationView.connectionStatusImage.isHidden = (locationView.url as URL?)?.isQwantUrl == true
        animateToOverlayState(overlayMode: false, didCancel: cancel)
        delegate?.urlBarDidLeaveOverlayMode(self)
    }

    func prepareOverlayAnimation() {
        let ipadSetup = shouldUseiPadSetup()
        // Make sure everything is showing during the transition (we'll hide it afterwards).
        bringSubviewToFront(self.locationContainer)
        bringSubviewToFront(self.iconView)
        cancelButton.isHidden = ipadSetup
        progressBar.isHidden = false
        addNewTabButton.isHidden = !toolbarIsShowing || topTabsIsShowing || ipadSetup
        appMenuButton.isHidden = !toolbarIsShowing && !ipadSetup
        bookmarksButton.isHidden = (!toolbarIsShowing || !topTabsIsShowing) && !ipadSetup
        forwardButton.isHidden = !toolbarIsShowing && !ipadSetup
        backButton.isHidden = !toolbarIsShowing && !ipadSetup
        tabsButton.isHidden = !toolbarIsShowing || topTabsIsShowing || ipadSetup
        multiStateButton.isHidden = true
        zapButton.isHidden = !toolbarIsShowing && !ipadSetup
    }

    func transitionToOverlay(_ didCancel: Bool = false) {
        let ipadSetup = shouldUseiPadSetup()
        locationView.contentView.alpha = inOverlayMode ? 0 : 1
        cancelButton.alpha = inOverlayMode && !ipadSetup ? 1 : 0
        progressBar.alpha = inOverlayMode || didCancel ? 0 : 1
        tabsButton.alpha = inOverlayMode || ipadSetup ? 0 : 1
        appMenuButton.alpha = inOverlayMode && !ipadSetup ? 0 : 1
        bookmarksButton.alpha = inOverlayMode && !ipadSetup ? 0 : 1
        addNewTabButton.alpha = inOverlayMode || ipadSetup ? 0 : 1
        forwardButton.alpha = inOverlayMode && !ipadSetup ? 0 : 1
        backButton.alpha = inOverlayMode && !ipadSetup ? 0 : 1
        multiStateButton.alpha = 0
        zapButton.alpha = inOverlayMode && !ipadSetup ? 0 : 1

        locationContainer.layer.borderColor = locationBorderColor.cgColor

        if inOverlayMode {
            // Make the editable text field span the entire URL bar, covering the lock and reader icons.
            locationTextField?.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationView)
            }
        } else {
            // Shrink the editable text field back to the size of the location view before hiding it.
            locationTextField?.snp.remakeConstraints { make in
                make.edges.equalTo(self.locationView.urlTextField)
            }
        }
    }

    func updateViewsForOverlayModeAndToolbarChanges() {
        let ipadSetup = shouldUseiPadSetup()
        // This ensures these can't be selected as an accessibility element when in the overlay mode.
        locationView.overrideAccessibility(enabled: !inOverlayMode)

        cancelButton.isHidden = !inOverlayMode || ipadSetup
        progressBar.isHidden = inOverlayMode
        addNewTabButton.isHidden = !toolbarIsShowing || topTabsIsShowing || inOverlayMode || ipadSetup
        appMenuButton.isHidden = (!toolbarIsShowing || inOverlayMode) && !ipadSetup
        bookmarksButton.isHidden = (!toolbarIsShowing || inOverlayMode || !topTabsIsShowing) && !ipadSetup
        forwardButton.isHidden = (!toolbarIsShowing || inOverlayMode) && !ipadSetup
        backButton.isHidden = (!toolbarIsShowing || inOverlayMode) && !ipadSetup
        tabsButton.isHidden = !toolbarIsShowing || inOverlayMode || topTabsIsShowing || ipadSetup
        multiStateButton.isHidden = true
        zapButton.isHidden = (!toolbarIsShowing || inOverlayMode) && !ipadSetup

        // badge isHidden is tied to private mode on/off, use alpha to hide in this case
        [privateModeBadge, appMenuBadge, warningMenuBadge].forEach {
            $0.badge.alpha = (!toolbarIsShowing || inOverlayMode) ? 0 : 1
            $0.backdrop.alpha = (!toolbarIsShowing || inOverlayMode) ? 0 : BadgeWithBackdrop.UX.backdropAlpha
        }
    }

    private var dismissOverlayRequested = false

    private func animateToOverlayState(overlayMode overlay: Bool, didCancel cancel: Bool = false) {
        prepareOverlayAnimation()
        layoutIfNeeded()

        inOverlayMode = overlay

        if !overlay {
            removeLocationTextField()
        }

        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.transitionToOverlay(cancel)
                self.setNeedsUpdateConstraints()
                self.layoutIfNeeded()
            }, completion: { _ in
                self.updateViewsForOverlayModeAndToolbarChanges()
                if self.dismissOverlayRequested {
                    self.dismissOverlayRequested = false
                    self.didClickCancel()
                }
            })
    }

    func didClickAddTab() {
        delegate?.urlBarDidPressTabs(self)
    }

    @objc
    private func didClickCancel() {
        leaveOverlayMode(didCancel: true)
    }

    @objc
    func tappedScrollToTopArea() {
        delegate?.urlBarDidPressScrollToTop(self)
    }

    @objc
    func clearLocationTextField() {
        if locationTextField?.isFirstResponder == true {
            locationTextField?.text = nil
        } else {
            locationTextField?.becomeFirstResponder()
        }
        delegate?.urlBar(self, didEnterText: locationTextField?.text ?? "")
    }
}

extension URLBarView: TabToolbarProtocol {
    func privateModeBadge(visible: Bool) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            privateModeBadge.show(visible)
        }
    }

    func appMenuBadge(setVisible: Bool) {
        // Warning badges should take priority over the standard badge
        guard warningMenuBadge.badge.isHidden else { return }

        appMenuBadge.show(setVisible)
    }

    func warningMenuBadge(setVisible: Bool) {
        // Disable other menu badges before showing the warning.
        if !appMenuBadge.badge.isHidden { appMenuBadge.show(false) }
        warningMenuBadge.show(setVisible)
    }

    func updateBackStatus(_ canGoBack: Bool) {
        backButton.isEnabled = canGoBack
    }

    func updateForwardStatus(_ canGoForward: Bool) {
        forwardButton.isEnabled = canGoForward
    }

    func updateTabCount(_ count: Int, animated: Bool = true) {
        tabsButton.updateTabCount(count, animated: animated)
    }

    func updateMiddleButtonState(_ state: MiddleButtonState) {
        helper?.setMiddleButtonState(state)
    }

    func updatePageStatus(_ isWebPage: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // the button should be always enabled so that the search button is enabled on the homepage
            multiStateButton.isEnabled = true
        }
    }

    var access: [Any]? {
        get {
            if inOverlayMode {
                guard let locationTextField = locationTextField else { return nil }
                return [locationTextField, cancelButton]
            } else {
                if toolbarIsShowing {
                    return [
                        backButton,
                        forwardButton,
                        multiStateButton,
                        zapButton,
                        locationView,
                        tabsButton,
                        bookmarksButton,
                        appMenuButton,
                        addNewTabButton,
                        progressBar
                    ]
                } else {
                    return [locationView, progressBar]
                }
            }
        }
        set {
            super.accessibilityElements = newValue
        }
    }

    func addUILargeContentViewInteraction(
        interaction: UILargeContentViewerInteraction
    ) {
        addInteraction(interaction)
    }
}

extension URLBarView: TabLocationViewDelegate {
    func tabLocationViewDidLongPressReaderMode(_ tabLocationView: TabLocationView) -> Bool {
        return delegate?.urlBarDidLongPressReaderMode(self) ?? false
    }

    func tabLocationViewDidLongPressReload(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidLongPressReload(self, from: tabLocationView.reloadButton)
    }

    func tabLocationViewDidTapLocation(_ tabLocationView: TabLocationView) {
        guard let (locationText, isSearchQuery) = delegate?.urlBarDisplayTextForURL(
            locationView.url as URL?
        ) else { return }

        var overlayText = locationText
        // Make sure to use the result from urlBarDisplayTextForURL as it is responsible
        // for extracting out search terms when on a search page
        if let text = locationText,
            let url = URL(string: text, invalidCharacters: false),
            let host = url.host,
            AppConstants.punyCode {
            overlayText = url.absoluteString.replacingOccurrences(of: host, with: host.asciiHostToUTF8())
        }
        enterOverlayMode(overlayText, pasted: false, search: isSearchQuery)
    }

    func tabLocationViewDidLongPressLocation(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidLongPressLocation(self)
    }

    func tabLocationViewDidTapReload(_ tabLocationView: TabLocationView) {
        let state = locationView.reloadButton.isHidden ? .reload : locationView.reloadButton.reloadButtonState

        switch state {
        case .reload:
            delegate?.urlBarDidPressReload(self)
            TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .reloadFromUrlBar)
        case .stop:
            delegate?.urlBarDidPressStop(self)
        case .disabled:
            // do nothing
            break
        }
    }

    func tabLocationViewDidTapStop(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidPressStop(self)
    }

    func tabLocationViewDidTapReaderMode(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidPressReaderMode(self)
    }

    func tabLocationViewDidTapShare(_ tabLocationView: TabLocationView, button: UIButton) {
        delegate?.urlBarDidPressShare(self, shareView: button)
    }

    func tabLocationViewPresentCFR(at sourceView: UIView) {
        delegate?.urlBarPresentCFR(at: sourceView)
    }

    func tabLocationViewLocationAccessibilityActions(
        _ tabLocationView: TabLocationView
    ) -> [UIAccessibilityCustomAction]? {
        return delegate?.urlBarLocationAccessibilityActions(self)
    }

    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidBeginDragInteraction(self)
    }

    func tabLocationViewDidTapShield(_ tabLocationView: TabLocationView) {
        delegate?.urlBarDidTapShield(self)
    }
}

extension URLBarView: AutocompleteTextFieldDelegate {
    func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        guard let text = locationTextField?.text else { return true }
        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            delegate?.urlBar(self, didSubmitText: text)
            return true
        } else {
            return false
        }
    }

    func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didEnterText text: String) {
        delegate?.urlBar(self, didEnterText: text)
    }

    func autocompleteTextFieldShouldClear(_ autocompleteTextField: AutocompleteTextField) -> Bool {
        delegate?.urlBar(self, didEnterText: "")
        return true
    }

    func autocompleteTextFieldDidCancel(_ autocompleteTextField: AutocompleteTextField) {
        leaveOverlayMode(didCancel: true)
    }

    func autocompletePasteAndGo(_ autocompleteTextField: AutocompleteTextField) {
        if let pasteboardContents = UIPasteboard.general.string {
            self.delegate?.urlBar(self, didSubmitText: pasteboardContents)
        }
    }
}

// MARK: UIAppearance
extension URLBarView {
    @objc dynamic var cancelTintColor: UIColor? {
        get { return cancelButton.titleColor(for: .normal) }
        set { return cancelButton.setTitleColor(newValue, for: .normal) }
    }
}

// MARK: ThemeApplicable
extension URLBarView: ThemeApplicable {
    func applyTheme(theme: Theme) {
        locationView.applyTheme(theme: theme)
        locationTextField?.applyTheme(theme: theme)

        actionButtons.forEach { $0.applyTheme(theme: theme) }
        tabsButton.applyTheme(theme: theme)
        addNewTabButton.applyTheme(theme: theme)

        let useKeyboardColor = inOverlayMode && !shouldUseiPadSetup() && isBottomSearchBar && isKeyboardShowing
        backgroundColor = useKeyboardColor ? theme.colors.omnibar_keyboardBackground : theme.colors.layer1
        line.backgroundColor = theme.colors.borderPrimary

        privateModeBadge.badge.tintBackground(color: theme.colors.layer1)
        appMenuBadge.badge.tintBackground(color: theme.colors.layer1)
        warningMenuBadge.badge.tintBackground(color: theme.colors.layer1)

        locationTextFieldMultistateButton.tintColor = theme.colors.omnibar_gray
    }
}

// MARK: - PrivateModeUI
extension URLBarView: PrivateModeUI {
    func applyUIMode(isPrivate: Bool, theme: Theme) {
        if UIDevice.current.userInterfaceIdiom != .pad {
            privateModeBadge.show(isPrivate)
        }

        let gradientStartColor = theme.colors.omnibar_tintColor(isPrivate)
        let gradientMiddleColor = theme.colors.omnibar_tintColor(isPrivate)
        let gradientEndColor = theme.colors.omnibar_tintColor(isPrivate)
        locationBorderColor = theme.colors.omnibar_tintColor(isPrivate)
        progressBar.setGradientColors(
            startColor: gradientStartColor,
            middleColor: gradientMiddleColor,
            endColor: gradientEndColor
        )
        locationTextField?.applyUIMode(isPrivate: isPrivate, theme: theme)
        locationView.applyUIMode(isPrivate: isPrivate, theme: theme)

        iconView.backgroundColor = theme.colors.omnibar_qwantLogo(isPrivate)
        cancelTintColor = theme.colors.omnibar_tintColor(isPrivate)
        locationBorderColor = theme.colors.omnibar_borderColor(isPrivate)
        locationView.backgroundColor = theme.colors.omnibar_urlBarBackground(isPrivate)
        locationContainer.backgroundColor = theme.colors.omnibar_urlBarBackground(isPrivate)
        privateModeBadge.badge.tintImage(color: theme.colors.omnibar_tintColor(isPrivate))

        actionButtons.forEach { $0.applyUIMode(isPrivate: isPrivate, theme: theme) }
        tabsButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        addNewTabButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        applyTheme(theme: theme)
    }
}
