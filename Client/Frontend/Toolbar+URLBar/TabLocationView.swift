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
    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapShare(_ tabLocationView: TabLocationView, button: UIButton)
    func tabLocationViewDidTapShopping(_ tabLocationView: TabLocationView, button: UIButton)

    /// - returns: whether the long-press was handled by the delegate; i.e. return `false` when the conditions for even starting handling long-press were not satisfied
    @discardableResult
    func tabLocationViewDidLongPressReaderMode(_ tabLocationView: TabLocationView) -> Bool
    func tabLocationViewDidLongPressReload(_ tabLocationView: TabLocationView)
    func tabLocationViewLocationAccessibilityActions(_ tabLocationView: TabLocationView) -> [UIAccessibilityCustomAction]?
}

class TabLocationView: UIView, FeatureFlaggable {
    // MARK: UX
    struct UX {
        static let hostFontColor = UIColor.black
        static let spacing: CGFloat = 8
        static let statusIconSize: CGFloat = 18
        static let buttonSize: CGFloat = 40
        static let urlBarPadding = 4
    }

    // MARK: Variables
    weak var delegate: TabLocationViewDelegate?
    var longPressRecognizer: UILongPressGestureRecognizer!
    var tapRecognizer: UITapGestureRecognizer!
    var contentView: UIStackView!
    var currentTheme: Theme?

    var notificationCenter: NotificationProtocol = NotificationCenter.default

    /// Tracking protection button, gets updated from tabDidChangeContentBlocking
    private var blockerStatus: BlockerStatus = .noBlockedURLs
    private var hasSecureContent = false

    private let menuBadge = BadgeWithBackdrop(imageName: ImageIdentifiers.menuBadge, backdropCircleSize: 32)

    var url: URL? {
        didSet {
            updateTextWithURL()
            updateConnectionStatusWithURL()
            connectionStatusImage.isHidden = !isValidHttpUrlProtocol || url?.isQwantUrl == true || urlTextField.isFirstResponder
            trackingProtectionButton.isHidden = !isValidHttpUrlProtocol || url?.isQwantUrl == true
            iconView.isHidden = !isValidHttpUrlProtocol || url?.isQwantUrl == false
            fixedSpace.isHidden = iconView.isHidden
            shareButton.isHidden = !(shouldEnableShareButtonFeature && isValidHttpUrlProtocol)
            setNeedsUpdateConstraints()
        }
    }

    var shouldEnableShareButtonFeature: Bool {
        guard featureFlags.isFeatureEnabled(.shareToolbarChanges, checking: .buildOnly) else {
            return false
        }
        return true
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

    lazy var connectionStatusImage: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
    }

    lazy var urlTextField: URLTextField = .build { urlTextField in
        // Prevent the field from compressing the toolbar buttons on the 4S in landscape.
        urlTextField.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        urlTextField.accessibilityIdentifier = "url"
        urlTextField.accessibilityActionsSource = self
        urlTextField.font = UIConstants.DefaultChromeFont
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
        urlTextField.attributedPlaceholder = NSAttributedString(string: .QwantOmnibar.Placeholder,
                                                                attributes: attributes)
    }

    lazy var fixedSpace = UIView.build()

    lazy var iconView: UIView = {
        let image = UIImageView(image: UIImage(imageLiteralResourceName: "qwant_Q"))
        image.translatesAutoresizingMaskIntoConstraints = false

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30/2
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

    lazy var trackingProtectionButton: TrackingProtectionButton = .build { trackingProtectionButton in
        trackingProtectionButton.addTarget(self, action: #selector(self.didPressTPShieldButton(_:)), for: .touchUpInside)
        trackingProtectionButton.clipsToBounds = false
        trackingProtectionButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.trackingProtection
    }

    lazy var shareButton: ShareButton = .build { shareButton in
        shareButton.addTarget(self, action: #selector(self.didPressShareButton(_:)), for: .touchUpInside)
        shareButton.clipsToBounds = false
        shareButton.contentHorizontalAlignment = .center
        shareButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.shareButton
        shareButton.accessibilityLabel = .TabLocationShareAccessibilityLabel
    }

    private lazy var shoppingButton: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.didPressShoppingButton(_:)), for: .touchUpInside)
        button.isHidden = true
        button.setImage(UIImage(named: StandardImageIdentifiers.Large.shopping)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.accessibilityLabel = .TabLocationShoppingAccessibilityLabel
        button.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.shoppingButton
    }

    private lazy var readerModeButton: ReaderModeButton = .build { readerModeButton in
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
        reloadButton.isAccessibilityElement = true
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        return reloadButton
    }()

    var connectionStatusConstraint = NSLayoutConstraint()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNotifications(forObserver: self, observing: [.FakespotViewControllerDidDismiss])
        register(self, forTabEvents: .didGainFocus, .didToggleDesktopMode, .didChangeContentBlocking)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLocation))
        longPressRecognizer.delegate = self

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLocation))
        tapRecognizer.delegate = self

        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(tapRecognizer)

        let space1px = UIView.build()
        space1px.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let subviews = [trackingProtectionButton, fixedSpace, iconView, space1px, urlTextField, shoppingButton, readerModeButton, shareButton, reloadButton]
        contentView = UIStackView(arrangedSubviews: subviews)
        contentView.distribution = .fill
        contentView.alignment = .center
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.edges(equalTo: self)
        addSubview(connectionStatusImage)

        NSLayoutConstraint.activate([
            trackingProtectionButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            trackingProtectionButton.heightAnchor.constraint(equalToConstant: UX.buttonSize),
            shoppingButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            shoppingButton.heightAnchor.constraint(equalToConstant: UX.buttonSize),
            fixedSpace.widthAnchor.constraint(equalToConstant: 5),
            iconView.widthAnchor.constraint(equalToConstant: 30),
            iconView.heightAnchor.constraint(equalToConstant: 30),
            connectionStatusImage.widthAnchor.constraint(equalToConstant: 16),
            connectionStatusImage.heightAnchor.constraint(equalToConstant: 16),
            connectionStatusImage.centerYAnchor.constraint(equalTo: urlTextField.centerYAnchor),
            readerModeButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            readerModeButton.heightAnchor.constraint(equalToConstant: UX.buttonSize),
            shareButton.heightAnchor.constraint(equalToConstant: UX.buttonSize),
            shareButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            reloadButton.widthAnchor.constraint(equalToConstant: UX.buttonSize),
            reloadButton.heightAnchor.constraint(equalToConstant: UX.buttonSize)
        ])

        // Setup UIDragInteraction to handle dragging the location
        // bar for dropping its URL into other apps.
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.allowsSimultaneousRecognitionDuringLift = true
        self.addInteraction(dragInteraction)

        menuBadge.add(toParent: contentView)
        menuBadge.show(false)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Accessibility

    private lazy var _accessibilityElements = [urlTextField, shoppingButton, readerModeButton, reloadButton, trackingProtectionButton, shareButton]

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
        connectionStatusImage.isHidden = urlTextField.isFirstResponder
    }

    @objc
    func didPressTPShieldButton(_ button: UIButton) {
        delegate?.tabLocationViewDidTapShield(self)
    }

    @objc
    func didPressShareButton(_ button: UIButton) {
        delegate?.tabLocationViewDidTapShare(self, button: shareButton)
    }

    @objc
    func didPressShoppingButton(_ button: UIButton) {
        button.isSelected = true
        delegate?.tabLocationViewDidTapShopping(self, button: button)
    }

    @objc
    func readerModeCustomAction() -> Bool {
        return delegate?.tabLocationViewDidLongPressReaderMode(self) ?? false
    }

    func updateShoppingButtonVisibility(for tab: Tab) {
        guard let url else {
            shoppingButton.isHidden = true
            return
        }
        let environment = featureFlags.isCoreFeatureEnabled(.useStagingFakespotAPI) ? FakespotEnvironment.staging : .prod
        let product = ShoppingProduct(url: url, client: FakespotClient(environment: environment))
        let shouldHideButton = !product.isShoppingButtonVisible || tab.isPrivate
        shoppingButton.isHidden = shouldHideButton
        if !shouldHideButton {
            TelemetryWrapper.recordEvent(category: .action, method: .view, object: .shoppingButton)
        }
    }

    private func updateTextWithURL() {
        if url?.isQwantUrl == true {
            urlTextField.text = url?.qwantSearchTerm?
                .replacingOccurrences(of: "+", with: " ")
            urlTextField.textAlignment = .left
            return
        }

        urlTextField.textAlignment = .center
        if let host = url?.normalizedHost {
            urlTextField.text = host
        } else {
            urlTextField.text = url?.absoluteString
        }
    }

    private func updateConnectionStatusWithURL() {
        NSLayoutConstraint.deactivate([connectionStatusConstraint])

        let width = (urlTextField.text ?? "").width(withConstrainedHeight: UX.buttonSize, font: UIFont.preferredFont(forTextStyle: .body))
        connectionStatusConstraint = connectionStatusImage.rightAnchor.constraint(equalTo: urlTextField.centerXAnchor, constant: -((width / 2) + 4))

        NSLayoutConstraint.activate([connectionStatusConstraint])
    }

    private func setTrackingProtection(isPrivate: Bool, theme: Theme) {
        let imageName = hasSecureContent ? "qwant_lock_on" : "qwant_lock_off"
        let color = hasSecureContent ? theme.colors.omnibar_gray(isPrivate) : theme.colors.vip_redIcon
        connectionStatusImage.image = UIImage(named: imageName)!
            .withRenderingMode(.alwaysTemplate)
            .tinted(withColor: color)
    }
}

// MARK: - Private
private extension TabLocationView {
    var isValidHttpUrlProtocol: Bool {
        ["https", "http"].contains(url?.scheme ?? "")
    }

    func setReaderModeState(_ newReaderModeState: ReaderModeState) {
        let wasHidden = readerModeButton.isHidden
        self.readerModeButton.readerModeState = newReaderModeState

        readerModeButton.isHidden = shoppingButton.isHidden ? newReaderModeState == .unavailable : true
        if wasHidden != readerModeButton.isHidden {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
            if !readerModeButton.isHidden {
                // Delay the Reader Mode accessibility announcement briefly to prevent interruptions.
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: String.ReaderModeAvailableVoiceOverAnnouncement)
                }
            }
        }
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.readerModeButton.alpha = newReaderModeState == .unavailable ? 0 : 1
        })
    }
}

extension TabLocationView: Notifiable {
    func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case .FakespotViewControllerDidDismiss:
            shoppingButton.isSelected = false
        default: break
        }
    }
}

extension TabLocationView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // When long pressing a button make sure the textfield's long press gesture is not triggered
        return !(otherGestureRecognizer.view is UIButton)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        currentTheme = theme
        readerModeButton.applyTheme(theme: theme)
        trackingProtectionButton.applyTheme(theme: theme)
        shareButton.applyTheme(theme: theme)
        reloadButton.applyTheme(theme: theme)
        menuBadge.badge.tintBackground(color: theme.colors.layer3)
        shoppingButton.tintColor = theme.colors.textPrimary
        shoppingButton.setImage(UIImage(named: StandardImageIdentifiers.Large.shopping)?
            .withTintColor(theme.colors.actionPrimary),
                                for: .selected)
    }

    func applyUIMode(isPrivate: Bool, theme: Theme) {
        iconView.backgroundColor = theme.colors.omnibar_qwantLogo(isPrivate)
        urlTextField.textColor = theme.colors.omnibar_urlBarText(isPrivate)
        setURLTextfieldPlaceholder(isPrivate: isPrivate, theme: theme)
        readerModeButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        shareButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        reloadButton.applyUIMode(isPrivate: isPrivate, theme: theme)
        setTrackingProtection(isPrivate: isPrivate, theme: theme)
        applyTheme(theme: theme)
    }
}

extension TabLocationView: TabEventHandler {
    func tabDidChangeContentBlocking(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }

    private func updateBlockerStatus(forTab tab: Tab) {
        guard let blocker = tab.contentBlocker else { return }

        ensureMainThread { [self] in
            trackingProtectionButton.alpha = 1.0
            self.blockerStatus = blocker.status
            self.hasSecureContent = (tab.webView?.hasOnlySecureContent ?? false)
            trackingProtectionButton.setImage(blocker.status.image, for: .normal)
            trackingProtectionButton.setBadgeValue(value: blocker.status.badgeValue(basedOn: blocker.stats.total))
            if let theme = currentTheme {
                trackingProtectionButton.setBadgeColor(color: blocker.status.color(for: theme))
                setTrackingProtection(isPrivate: tab.isPrivate, theme: theme)
            }
            trackingProtectionButton.animateIfNeeded()
        }
    }

    func tabDidGainFocus(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }
}

private extension String {

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
