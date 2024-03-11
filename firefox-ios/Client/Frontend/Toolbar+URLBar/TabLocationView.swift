// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import Shared

protocol TabLocationViewDelegate: AnyObject {
    func tabLocationViewDidTapLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidLongPressLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapReaderMode(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapReload(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapShield(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapQwantIcon(_ tabLocationView: TabLocationView)
    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: TabLocationView)
    func tabLocationViewPresentCFR(at sourceView: UIView)

    /// - returns: whether the long-press was handled by the delegate; i.e. return `false` when the conditions
    /// for even starting handling long-press were not satisfied
    @discardableResult
    func tabLocationViewDidLongPressReaderMode(_ tabLocationView: TabLocationView) -> Bool
    func tabLocationViewDidLongPressReload(_ tabLocationView: TabLocationView)
    func tabLocationViewLocationAccessibilityActions(
        _ tabLocationView: TabLocationView
    ) -> [UIAccessibilityCustomAction]?
}

class TabLocationView: UIView, FeatureFlaggable {
    // MARK: UX
    struct UX {
        static let hostFontColor = UIColor.black
        static let spacing: CGFloat = 8
        static let statusIconSize: CGFloat = 18
        static let buttonSize: CGFloat = 40
        static let urlBarPadding = 4
        static let trackingProtectionAnimationDuration = 0.3
        static let trackingProtectionxOffset = CGAffineTransform(translationX: 25, y: 0)
    }

    // MARK: Variables
    weak var delegate: TabLocationViewDelegate?

    private lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLocation))
        longPressRecognizer.delegate = self
        return longPressRecognizer
    }()
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLocation))
        tapRecognizer.delegate = self
        return tapRecognizer
    }()

    var notificationCenter: NotificationProtocol = NotificationCenter.default
    private var themeManager: ThemeManager = AppContainer.shared.resolve()
    let windowUUID: WindowUUID
    let logger: Logger

    var isTrackingProtectionDisplayed = false

    /// Tracking protection button, gets updated from tabDidChangeContentBlocking
    var blockerStatus: BlockerStatus = .noBlockedURLs
    var hasSecureContent = false

    var url: URL? {
        didSet {
            updateTextWithURL()
            iconView.isHidden = !isValidHttpUrlProtocol(url) || url?.isQwantUrl == false
            fixedSpace.isHidden = iconView.isHidden
            setNeedsUpdateConstraints()
            trackingProtectionButtonVisibility(for: url)
        }
    }

    var readerModeState: ReaderModeState {
        get {
            return readerModeButton.readerModeState
        }
        set (newReaderModeState) {
            guard newReaderModeState != self.readerModeButton.readerModeState else { return }
            setReaderModeState(newReaderModeState)
        }
    }

    lazy var contentView: UIStackView = {
        let space1px = UIView.build()
        space1px.widthAnchor.constraint(equalToConstant: 1).isActive = true
        let subviews = [
            trackingProtectionButton,
            fixedSpace,
            iconView,
            space1px,
            urlTextField,
            readerModeButton,
            reloadButton
        ]
        let contentView = UIStackView(arrangedSubviews: subviews)
        contentView.distribution = .fill
        contentView.alignment = .center
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    lazy var urlTextField: URLTextField = .build { urlTextField in
        // Prevent the field from compressing the toolbar buttons on the 4S in landscape.
        urlTextField.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        urlTextField.accessibilityIdentifier = "url"
        urlTextField.accessibilityActionsSource = self
        urlTextField.backgroundColor = .clear
        urlTextField.accessibilityLabel = .TabLocationAddressBarAccessibilityLabel
        urlTextField.font = UIFont.preferredFont(forTextStyle: .body)
        urlTextField.adjustsFontForContentSizeCategory = true

        // Remove the default drop interaction from the URL text field so that our
        // custom drop interaction on the BVC can accept dropped URLs.
        if let dropInteraction = urlTextField.textDropInteraction {
            urlTextField.removeInteraction(dropInteraction)
        }
    }

    private func setURLTextfieldPlaceholder(isPrivate: Bool, theme: Theme) {
        let attributes = [NSAttributedString.Key.foregroundColor: theme.colors.omnibar_gray(isPrivate)]
        urlTextField.attributedPlaceholder = NSAttributedString(
            string: .QwantOmnibar.Placeholder,
            attributes: attributes
        )
    }

    lazy var fixedSpace = UIView.build()

    lazy var iconView: UIView = {
        let image: UIImageView = .build()
        image.image = UIImage.templateImageNamed("qwant_Q")

        let button: UIButton = .build()
        button.addTarget(self, action: #selector(self.didPressQwantIcon), for: .touchUpInside)

        let view: UIView = .build()
        view.layer.cornerRadius = 30/2
        view.clipsToBounds = true
        view.addSubview(image)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalTo: image.heightAnchor, multiplier: 452/519),
            image.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 1.5),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -1),

            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }()

    lazy var trackingProtectionButton: LockButton = .build { trackingProtectionButton in
        trackingProtectionButton.addTarget(
            self,
            action: #selector(self.didPressTPShieldButton(_:)),
            for: .touchUpInside
        )
        trackingProtectionButton.clipsToBounds = false
        trackingProtectionButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.trackingProtection
        trackingProtectionButton.showsLargeContentViewer = true
        trackingProtectionButton.largeContentImage = .templateImageNamed(StandardImageIdentifiers.Large.lock)
        trackingProtectionButton.largeContentTitle = .TabLocationLockButtonLargeContentTitle
        trackingProtectionButton.accessibilityLabel = .TabLocationLockButtonAccessibilityLabel
    }

    private(set) lazy var readerModeButton: ReaderModeButton = .build { readerModeButton in
        readerModeButton.addTarget(self, action: #selector(self.tapReaderModeButton), for: .touchUpInside)
        readerModeButton.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self,
                                         action: #selector(self.longPressReaderModeButton)))
        readerModeButton.isAccessibilityElement = true
        readerModeButton.isHidden = true
        readerModeButton.accessibilityLabel = .TabLocationReaderModeAccessibilityLabel
        readerModeButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.readerModeButton
        readerModeButton.accessibilityCustomActions = [
            UIAccessibilityCustomAction(
                name: .TabLocationReaderModeAddToReadingListAccessibilityLabel,
                target: self,
                selector: #selector(self.readerModeCustomAction))]
        readerModeButton.showsLargeContentViewer = true
        readerModeButton.largeContentTitle = .TabLocationReaderModeAccessibilityLabel
        readerModeButton.largeContentImage = .templateImageNamed(StandardImageIdentifiers.Large.readerView)
    }

    lazy var reloadButton: StatefulButton = {
        let reloadButton = StatefulButton(frame: .zero, state: .reload)
        reloadButton.addTarget(self, action: #selector(tapReloadButton), for: .touchUpInside)
        reloadButton.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(longPressReloadButton)))
        reloadButton.imageView?.contentMode = .scaleAspectFit
        reloadButton.contentHorizontalAlignment = .center
        reloadButton.accessibilityLabel = .TabLocationReloadAccessibilityLabel
        reloadButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.reloadButton
        reloadButton.accessibilityHint = .TabLocationReloadAccessibilityHint
        reloadButton.isAccessibilityElement = true
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.showsLargeContentViewer = true
        reloadButton.largeContentTitle = .TabLocationReloadAccessibilityLabel
        return reloadButton
    }()

    init(windowUUID: WindowUUID, logger: Logger = DefaultLogger.shared) {
        self.windowUUID = windowUUID
        self.logger = logger
        super.init(frame: .zero)
        setupNotifications(
            forObserver: self,
            observing: [
                .TrackingProtectionViewControllerDidDismiss,
                .TrackingProtectionViewControllerDidAppear
            ]
        )
        register(self, forTabEvents: .didGainFocus, .didToggleDesktopMode, .didChangeContentBlocking)

        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(tapRecognizer)

        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

            trackingProtectionButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            trackingProtectionButton.heightAnchor.constraint(equalToConstant: UX.buttonSize),
            fixedSpace.widthAnchor.constraint(equalToConstant: 5),
            iconView.widthAnchor.constraint(equalToConstant: 30),
            iconView.heightAnchor.constraint(equalToConstant: 30),
            readerModeButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            readerModeButton.heightAnchor.constraint(equalToConstant: UX.buttonSize),
            reloadButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            reloadButton.heightAnchor.constraint(equalToConstant: UX.buttonSize),
        ])

        // Setup UIDragInteraction to handle dragging the location
        // bar for dropping its URL into other apps.
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.allowsSimultaneousRecognitionDuringLift = true
        self.addInteraction(dragInteraction)

        trackingProtectionButtonVisibility(for: url)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Accessibility

    private lazy var _accessibilityElements = [
        trackingProtectionButton,
        urlTextField,
        readerModeButton,
        reloadButton
    ]

    override var accessibilityElements: [Any]? {
        get {
            return _accessibilityElements.filter { !$0.isHidden }
        }
        set {
            super.accessibilityElements = newValue
        }
    }

    func overrideAccessibility(enabled: Bool) {
        _accessibilityElements.forEach {
            $0.isAccessibilityElement = enabled
        }
    }

    // MARK: - User actions

    @objc
    func tapReaderModeButton() {
        delegate?.tabLocationViewDidTapReaderMode(self)
    }

    @objc
    func tapReloadButton() {
        delegate?.tabLocationViewDidTapReload(self)
    }

    @objc
    func longPressReaderModeButton(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.tabLocationViewDidLongPressReaderMode(self)
        }
    }

    @objc
    func longPressReloadButton(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.tabLocationViewDidLongPressReload(self)
        }
    }

    @objc
    func longPressLocation(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.tabLocationViewDidLongPressLocation(self)
        }
    }

    @objc
    func tapLocation(_ recognizer: UITapGestureRecognizer) {
        delegate?.tabLocationViewDidTapLocation(self)
    }

    @objc
    func didPressTPShieldButton(_ button: UIButton) {
        delegate?.tabLocationViewDidTapShield(self)
    }

    @objc
    func didPressQwantIcon() {
        delegate?.tabLocationViewDidTapQwantIcon(self)
    }

    @objc
    func readerModeCustomAction() -> Bool {
        return delegate?.tabLocationViewDidLongPressReaderMode(self) ?? false
    }

    private func updateTextWithURL() {
        if url?.isQwantUrl == true {
            urlTextField.text = url?.qwantSearchTerm
            urlTextField.textAlignment = .left
            return
        }

        urlTextField.textAlignment = .center
        urlTextField.text = url?.normalizedHost ?? url?.absoluteString
    }

    func trackingProtectionButtonVisibility(for url: URL?) {
        ensureMainThread {
            let isValidHttpUrlProtocol = self.isValidHttpUrlProtocol(url)
            let isQwantUrl = url?.isQwantUrl ?? false
            let isReaderModeURL = url?.isReaderModeURL ?? false
            let isReaderModeActive = self.readerModeState == .active
            let shouldHide = !isValidHttpUrlProtocol || isQwantUrl || isReaderModeURL || isReaderModeActive
            self.trackingProtectionButton.isHidden = shouldHide
        }
    }

    private func currentTheme() -> Theme {
        return themeManager.getCurrentTheme(for: windowUUID)
    }
}

// MARK: - Private
private extension TabLocationView {
    func isValidHttpUrlProtocol(_ url: URL?) -> Bool {
        ["https", "http"].contains(url?.scheme ?? "")
    }

    func setReaderModeState(_ newReaderModeState: ReaderModeState) {
        let wasHidden = readerModeButton.isHidden
        self.readerModeButton.readerModeState = newReaderModeState

        readerModeButton.isHidden = newReaderModeState == .unavailable
        // When the user turns on the reader mode we need to hide the trackingProtectionButton (according to 16400),
        // we will hide it once the newReaderModeState == .active
        trackingProtectionButtonVisibility(for: url)

        if wasHidden != readerModeButton.isHidden && !isTrackingProtectionDisplayed {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
            if !readerModeButton.isHidden {
                // Delay the Reader Mode accessibility announcement briefly to prevent interruptions.
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    UIAccessibility.post(
                        notification: UIAccessibility.Notification.announcement,
                        argument: String.ReaderModeAvailableVoiceOverAnnouncement
                    )
                }
            }
        }
        UIView.animate(withDuration: 0.1, animations: { () in
            self.readerModeButton.alpha = newReaderModeState == .unavailable ? 0 : 1
        })
    }
}

extension TabLocationView: Notifiable {
    func handleNotifications(_ notification: Notification) {
        guard let notificationUUID = notification.object as? UUID else { return }
        guard windowUUID == notificationUUID else { return }
        switch notification.name {
        case .TrackingProtectionViewControllerDidDismiss:
            isTrackingProtectionDisplayed = false
        case .TrackingProtectionViewControllerDidAppear:
            isTrackingProtectionDisplayed = true
        default: break
        }
    }
}

extension TabLocationView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // When long pressing a button make sure the textfield's long press gesture is not triggered
        return !(otherGestureRecognizer.view is UIButton)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // If the longPressRecognizer is active, fail the tap recognizer to avoid conflicts.
        return gestureRecognizer == longPressRecognizer && otherGestureRecognizer == tapRecognizer
    }
}

extension TabLocationView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        // Ensure we actually have a URL in the location bar and that the URL is not local.
        guard let url = self.url,
              !InternalURL.isValid(url: url),
              let itemProvider = NSItemProvider(contentsOf: url)
        else { return [] }

        TelemetryWrapper.recordEvent(category: .action, method: .drag, object: .locationBar)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }

    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        delegate?.tabLocationViewDidBeginDragInteraction(self)
    }
}

extension TabLocationView: AccessibilityActionsSource {
    func accessibilityCustomActionsForView(_ view: UIView) -> [UIAccessibilityCustomAction]? {
        if view === urlTextField {
            return delegate?.tabLocationViewLocationAccessibilityActions(self)
        }
        return nil
    }
}

// MARK: ThemeApplicable
extension TabLocationView: ThemeApplicable, PrivateModeUI {
    func applyTheme(theme: Theme) {
        readerModeButton.applyTheme(theme: theme)
        trackingProtectionButton.applyTheme(theme: theme)
        reloadButton.applyTheme(theme: theme)
        trackingProtectionButtonVisibility(for: url)
    }

    func applyUIMode(isPrivate: Bool, theme: Theme) {
        iconView.backgroundColor = theme.colors.omnibar_qwantLogo(isPrivate)
        iconView.tintColor = theme.colors.omnibar_qwantLogoTint(isPrivate)
        urlTextField.textColor = theme.colors.omnibar_urlBarText(isPrivate)
        setURLTextfieldPlaceholder(isPrivate: isPrivate, theme: theme)
        readerModeButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        reloadButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        trackingProtectionButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        applyTheme(theme: theme)
    }
}

extension TabLocationView: TabEventHandler {
    var tabEventWindowResponseType: TabEventHandlerWindowResponseType { return .singleWindow(windowUUID) }

    func updateBlockerStatus(forTab tab: Tab) {
        logger.log("Tab did change content blocking", level: .info, category: .adblock)
        guard let blocker = tab.contentBlocker else { return }

        ensureMainThread { [self] in
            trackingProtectionButton.alpha = 1.0
            self.blockerStatus = blocker.status
        }
    }

    func tabDidChangeContentBlocking(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }

    func tabDidGainFocus(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }
}

private extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.width)
    }
}
