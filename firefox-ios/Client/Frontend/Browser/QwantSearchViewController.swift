// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import Storage
import Shared
import SiteImageView

private enum SearchListSection: Int, CaseIterable {
    case history
    case openedTabsAndBookmarks
    case suggest
}

protocol QwantSearchViewControllerDelegate: AnyObject {
    func qwantSearchViewController(
        _ searchViewController: QwantSearchViewController,
        didSelectURL url: URL,
        searchTerm: String?
    )
    func qwantSearchViewController(
        _ searchViewController: QwantSearchViewController,
        uuid: String
    )
    func presentQwantSearchSettingsController()
    func qwantSearchViewController(
        _ searchViewController: QwantSearchViewController,
        didHighlightText text: String,
        search: Bool
    )
    func qwantSearchViewController(
        _ searchViewController: QwantSearchViewController,
        didAppend text: String
    )
}

class QwantSearchViewController: UIViewController,
                                 UITableViewDelegate,
                                 UITableViewDataSource,
                                 Themeable,
                                 Notifiable {
    var searchDelegate: QwantSearchViewControllerDelegate?
    private let viewModel: SearchViewModel

    private var openedTabs = [Tab]()
    private var bookmarks = [Site]()
    private var history = [Site]()
    private var suggest = [String]()

    private let profile: Profile
    private var tabManager: TabManager
    private lazy var suggestClient: SearchSuggestClient = {
        return SearchSuggestClient(
            searchEngine: profile.searchEngines.defaultEngine!,
            userAgent: UserAgent.getUserAgent())
    }()

    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(TwoLineImageOverlayCell.self,
                       forCellReuseIdentifier: TwoLineImageOverlayCell.cellIdentifier)
        table.register(QwantOneLineTableViewCell.self,
                       forCellReuseIdentifier: QwantOneLineTableViewCell.cellIdentifier)
        table.register(QwantSearchTableViewHeader.self,
                       forHeaderFooterViewReuseIdentifier: QwantSearchTableViewHeader.cellIdentifier)
        table.keyboardDismissMode = .onDrag
        table.accessibilityIdentifier = "SiteTable"
        table.estimatedRowHeight = 44
        table.setEditing(false, animated: false)

        // Set an empty footer to prevent empty cells from appearing in the list.
        table.tableFooterView = UIView()

        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }

        return table
    }()

    var savedQuery: String = ""
    var searchQuery: String = "" {
        didSet {
            // Reload the tableView to show the updated text in each engine.
            reloadData()
        }
    }

    fileprivate func sectionContent() -> [SearchListSection: [Any]] {
        return [
            .history: history,
            .openedTabsAndBookmarks: openedTabs + bookmarks,
            .suggest: suggest,
        ]
    }

    private func sectionType(for idx: Int) -> SearchListSection? {
        let filteredSections = sectionContent()
            .filter({ !$0.value.isEmpty })
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
        return filteredSections[idx].key
    }

    // Init
    override private init(nibName: String?, bundle: Bundle?) {
        fatalError("init(coder:) has not been implemented")
    }

    init(profile: Profile,
         viewModel: SearchViewModel,
         tabManager: TabManager,
         notificationCenter: NotificationProtocol = NotificationCenter.default,
         themeManager: ThemeManager = AppContainer.shared.resolve()) {
        self.profile = profile
        self.viewModel = viewModel
        self.tabManager = tabManager
        self.notificationCenter = notificationCenter
        self.themeManager = themeManager

        super.init(nibName: nil, bundle: nil)
        listenForThemeChange(view)
        applyTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // The view might outlive this view controller thanks to animations;
        // explicitly nil out its references to us to avoid crashes. Bug 1218826.
        tableView.dataSource = nil
        tableView.delegate = nil
    }

    // View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layoutTable()
        setupNotifications(forObserver: self, observing: [.DynamicFontChanged])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.setEditing(false, animated: false)
        // The AS context menu does not behave correctly. Dismiss it when rotating.
        if self.presentedViewController as? PhotonActionSheet != nil {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }

    private func setupView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func layoutTable() {
        // Note: We remove and re-add tableview from superview so that we can update
        // the constraints to be aligned with Search Engine Scroll View top anchor
        tableView.removeFromSuperview()
        view.addSubviews(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func reloadData() {
        fetchSuggest()
        fetchBookmarks()
        fetchTabs()
        fetchHistory()
    }

    private func fetchSuggest() {
        self.suggest = [searchQuery]
        self.savedQuery = self.searchQuery
        self.tableView.reloadData()

        SuggestFetcher(
            profile: profile,
            maxCount: 6,
            client: suggestClient)
        .fetch(for: searchQuery) { suggest in
            self.suggest = suggest
            self.savedQuery = self.searchQuery
            self.tableView.reloadData()
        }
    }

    private func fetchBookmarks() {
        BookmarksFetcher(
            profile: profile,
            maxCount: 1)
        .fetch(for: searchQuery) { sites in
            self.bookmarks = sites
            self.tableView.reloadData()
        }
    }

    private func fetchTabs() {
        TabsFetcher(
            profile: profile,
            tabManager: tabManager,
            maxCount: 2,
            isPrivate: viewModel.isPrivate)
        .fetch(for: searchQuery) { tabs in
            self.openedTabs = tabs
            self.tableView.reloadData()
        }
    }

    private func fetchHistory() {
        HistoryFetcher(
            profile: profile,
            maxCount: 2,
            tabs: tabManager.tabs)
        .fetch(for: searchQuery) { sites in
            self.history = sites
            self.tableView.reloadData()
        }
    }

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionType(for: section)! {
        case .suggest:
            let count = suggest.count
            return count < 6 ? count : 6
        case .openedTabsAndBookmarks:
            return openedTabs.count + bookmarks.count
        case .history:
            return history.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let twoLineImageOverlayCell = tableView.dequeueReusableCell(
            withIdentifier: TwoLineImageOverlayCell.cellIdentifier, for: indexPath) as! TwoLineImageOverlayCell
        let oneLineTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: QwantOneLineTableViewCell.cellIdentifier, for: indexPath) as! QwantOneLineTableViewCell
        let cell = getCellForSection(twoLineImageOverlayCell,
                                     oneLineCell: oneLineTableViewCell,
                                     for: sectionType(for: indexPath.section)!,
                                     indexPath)
        cell.backgroundColor = themeManager.currentTheme.colors.omnibar_tableViewCellBackground(viewModel.isPrivate)
        return cell
    }

    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sectionType(for: indexPath.section)! {
        case .suggest:
            // Assume that only the default search engine can provide search suggestions.
            let engine = profile.searchEngines.defaultEngine!
            guard let suggestion = suggest[safe: indexPath.row] else { return }
            if let url = engine.searchURLForQuery(suggestion) {
                searchDelegate?.qwantSearchViewController(self, didSelectURL: url, searchTerm: suggestion)
            }
        case .openedTabsAndBookmarks:
            let tabsAndBookmarks: [Any] = openedTabs + bookmarks
            guard let tabOrBookmark = tabsAndBookmarks[safe: indexPath.row] else { return }
            if let tab = tabOrBookmark as? Tab {
                searchDelegate?.qwantSearchViewController(self, uuid: tab.tabUUID)
            } else if let site = tabOrBookmark as? Site, let url = URL(string: site.url) {
                searchDelegate?.qwantSearchViewController(self, didSelectURL: url, searchTerm: nil)
            }
        case .history:
            guard let site = history[safe: indexPath.row] else { return }
            if let url = URL(string: site.url) {
                searchDelegate?.qwantSearchViewController(self, didSelectURL: url, searchTerm: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.numberOfRows(inSection: section) == 0 ? 0 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let type = sectionType(for: section),
              type == SearchListSection.suggest,
              let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: QwantSearchTableViewHeader.cellIdentifier) as? QwantSearchTableViewHeader
        else { return nil }

        let viewModel = SiteTableViewHeaderModel(title: .QwantOmnibar.SearchHeaderTitle,
                                                 isCollapsible: false,
                                                 collapsibleState: nil)
        headerView.configure(viewModel)
        headerView.applyUIMode(isPrivate: self.viewModel.isPrivate, theme: themeManager.currentTheme)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionContent().filter({ !$0.value.isEmpty }).count
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch sectionType(for: indexPath.section)! {
        case .suggest:
            // Assume that only the default search engine can provide search suggestions.
            guard let suggestion = suggest[safe: indexPath.row] else { return }
            searchDelegate?.qwantSearchViewController(self, didHighlightText: suggestion, search: false)
        case .openedTabsAndBookmarks:
            let tabsAndBookmarks: [Any] = openedTabs + bookmarks
            guard let tabOrBookmark = tabsAndBookmarks[safe: indexPath.row] else { return }
            if let tab = tabOrBookmark as? Tab, let text = tab.url?.absoluteString {
                searchDelegate?.qwantSearchViewController(self, didHighlightText: text, search: false)
            } else if let site = tabOrBookmark as? Site {
                searchDelegate?.qwantSearchViewController(self, didHighlightText: site.url, search: false)
            }
        case .history:
            guard let site = history[safe: indexPath.row] else { return }
            searchDelegate?.qwantSearchViewController(self, didHighlightText: site.url, search: false)
        }
    }

    // Themeable
    var themeManager: ThemeManager
    var themeObserver: NSObjectProtocol?
    var notificationCenter: NotificationProtocol

    func applyTheme() {
        let theme = themeManager.currentTheme
        navigationController?.navigationBar.barTintColor = theme.colors.layer1
        navigationController?.navigationBar.tintColor = theme.colors.iconAction
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.colors.textPrimary]
        setNeedsStatusBarAppearanceUpdate()

        tableView.backgroundColor = theme.colors.omnibar_tableViewBackground(viewModel.isPrivate)
        tableView.separatorColor = theme.colors.omnibar_tableViewSeparator
        tableView.reloadData()

        view.backgroundColor = theme.colors.omnibar_tableViewBackground(viewModel.isPrivate)
        reloadData()
    }

    func getAttributedBoldSearchSuggestions(searchPhrase: String, query: String) -> NSAttributedString? {
        // the search term (query) stays normal weight
        // everything past the search term (query) will be bold
        let range = searchPhrase.range(of: query)
        guard searchPhrase != query, let upperBound = range?.upperBound else { return nil }

        let boldString = String(searchPhrase[upperBound..<searchPhrase.endIndex])
        let attributedString = searchPhrase.attributedText(
            boldString: boldString,
            font: DefaultDynamicFontHelper.preferredFont(
                withTextStyle: .body,
                size: 17,
                weight: .regular
            )
        )
        return attributedString
    }

    private func getCellForSection(_ twoLineCell: TwoLineImageOverlayCell,
                                   oneLineCell: QwantOneLineTableViewCell,
                                   for section: SearchListSection,
                                   _ indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch section {
        case .suggest:
            let site = suggest[indexPath.row]
            oneLineCell.titleLabel.text = site
            if let attributedString = getAttributedBoldSearchSuggestions(searchPhrase: site, query: savedQuery) {
                oneLineCell.titleLabel.attributedText = attributedString
            }
            oneLineCell.leftImageView.contentMode = .center
            oneLineCell.leftImageView.layer.borderWidth = 0
            oneLineCell.leftImageView.layer.cornerRadius = 14
            oneLineCell.leftImageView.image = UIImage(named: "qwant_search")?.withRenderingMode(.alwaysTemplate)
            oneLineCell.leftImageView.tintColor = themeManager.currentTheme.colors.omnibar_tintColor(viewModel.isPrivate)
            oneLineCell.leftImageView.backgroundColor = nil
            let appendButton = UIButton(type: .roundedRect)
            appendButton.setImage(searchAppendImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            appendButton.addTarget(self, action: #selector(append(_ :)), for: .touchUpInside)
            appendButton.sizeToFit()
            oneLineCell.accessoryView = indexPath.row > 0 ? appendButton : nil
            cell = oneLineCell
        case .openedTabsAndBookmarks:
            let tabsAndBookmarks: [Any] = openedTabs + bookmarks
            if let openedTab = tabsAndBookmarks[indexPath.row] as? Tab {
                twoLineCell.descriptionLabel.isHidden = false
                twoLineCell.titleLabel.text = openedTab.title ?? openedTab.lastTitle
                twoLineCell.descriptionLabel.text =
                    [openedTab.url?.normalizedHost, String.SearchSuggestionCellSwitchToTabLabel]
                    .compactMap({ $0 })
                    .joined(separator: " • ")
                twoLineCell.leftOverlayImageView.image = UIImage(named: "qwant_tabs")?.withRenderingMode(.alwaysTemplate)
                twoLineCell.leftOverlayImageView.tintColor =
                    themeManager.currentTheme.colors.omnibar_tintColor(viewModel.isPrivate)
                twoLineCell.leftOverlayImageView.backgroundColor =
                    themeManager.currentTheme.colors.omnibar_tableViewCellBackground(viewModel.isPrivate)
                twoLineCell.leftOverlayImageView.layer.cornerRadius = 4.0
                twoLineCell.leftOverlayImageView.clipsToBounds = true
                twoLineCell.leftImageView.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
                twoLineCell.leftImageView.layer.borderWidth = 0.5
                let urlString = openedTab.url?.absoluteString ?? ""
                twoLineCell.leftImageView.setFavicon(FaviconImageViewModel(siteURLString: urlString))
                twoLineCell.accessoryView = nil
                cell = twoLineCell
            } else if let site = tabsAndBookmarks[indexPath.row] as? Site {
                twoLineCell.descriptionLabel.isHidden = false
                twoLineCell.titleLabel.text = site.title
                twoLineCell.descriptionLabel.text = site.tileURL.normalizedHost ?? ""
                twoLineCell.leftOverlayImageView.image =
                    UIImage(named: "qwant_bookmarks")?.withRenderingMode(.alwaysTemplate)
                twoLineCell.leftOverlayImageView.tintColor =
                    themeManager.currentTheme.colors.omnibar_tintColor(viewModel.isPrivate)
                twoLineCell.leftOverlayImageView.backgroundColor =
                    themeManager.currentTheme.colors.omnibar_tableViewCellBackground(viewModel.isPrivate)
                twoLineCell.leftOverlayImageView.layer.cornerRadius = 11.0
                twoLineCell.leftOverlayImageView.clipsToBounds = true
                twoLineCell.leftImageView.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
                twoLineCell.leftImageView.layer.borderWidth = 0.5
                let urlString = site.url
                twoLineCell.leftImageView.setFavicon(FaviconImageViewModel(siteURLString: urlString))
                twoLineCell.accessoryView = nil
                cell = twoLineCell
            }
        case .history:
            let site = history[indexPath.row] as Site

            if let url = URL(string: site.url), url.isQwantUrl,
               let query = url.qwantSearchTerm, !query.isEmpty {
                oneLineCell.titleLabel.text = query.replacingOccurrences(of: "+", with: " ")
                oneLineCell.leftImageView.contentMode = .center
                oneLineCell.leftImageView.layer.borderWidth = 0
                oneLineCell.leftImageView.image = UIImage(named: "qwant_history")?.withRenderingMode(.alwaysTemplate)
                oneLineCell.leftImageView.tintColor = themeManager.currentTheme.colors.omnibar_tintColor(viewModel.isPrivate)
                oneLineCell.leftImageView.backgroundColor = nil
                let appendButton = UIButton(type: .roundedRect)
                appendButton.setImage(searchAppendImage?.withRenderingMode(.alwaysTemplate), for: .normal)
                appendButton.addTarget(self, action: #selector(append(_ :)), for: .touchUpInside)
                appendButton.sizeToFit()
                oneLineCell.accessoryView = appendButton
                cell = oneLineCell
            } else {
                twoLineCell.descriptionLabel.isHidden = false
                twoLineCell.titleLabel.text = site.title
                twoLineCell.descriptionLabel.text = site.url
                twoLineCell.leftOverlayImageView.image = UIImage(named: "qwant_history")?.withRenderingMode(.alwaysTemplate)
                twoLineCell.leftOverlayImageView.tintColor =
                    themeManager.currentTheme.colors.omnibar_tintColor(viewModel.isPrivate)
                twoLineCell.leftOverlayImageView.backgroundColor =
                    themeManager.currentTheme.colors.omnibar_tableViewCellBackground(viewModel.isPrivate)
                twoLineCell.leftOverlayImageView.layer.cornerRadius = 11.0
                twoLineCell.leftOverlayImageView.clipsToBounds = true
                twoLineCell.leftImageView.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
                twoLineCell.leftImageView.layer.borderWidth = 0.5
                twoLineCell.leftImageView.setFavicon(FaviconImageViewModel(siteURLString: site.url))
                twoLineCell.accessoryView = nil
                cell = twoLineCell
            }
        }

        // We need to set the correct theme on the cells when the initial display happens
        let theme = themeManager.currentTheme
        oneLineCell.applyTheme(theme: theme)
        oneLineCell.titleLabel.textColor = theme.colors.omnibar_tableViewCellPrimaryText(viewModel.isPrivate)
        oneLineCell.selectedBackgroundView?.backgroundColor =
            theme.colors.omnibar_tableViewSelectedCellBackground(viewModel.isPrivate)
        oneLineCell.accessoryView?.tintColor = theme.colors.omnibar_gray(viewModel.isPrivate)
        twoLineCell.applyTheme(theme: theme)
        twoLineCell.titleLabel.textColor = theme.colors.omnibar_tableViewCellPrimaryText(viewModel.isPrivate)
        twoLineCell.descriptionLabel.textColor = theme.colors.omnibar_tableViewCellSecondaryText(viewModel.isPrivate)
        twoLineCell.selectedBackgroundView?.backgroundColor =
            theme.colors.omnibar_tableViewSelectedCellBackground(viewModel.isPrivate)
        return cell
    }

    @objc
    func append(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            let section = sectionType(for: indexPath.section)
            var newQuery = ""
            if section == .suggest, let suggest = suggest[safe: indexPath.row] {
                newQuery = suggest
            } else if section == .history,
                      let history = history[safe: indexPath.row],
                      let url = URL(string: history.url),
                      let term = url.qwantSearchTerm {
                newQuery = term.replacingOccurrences(of: "+", with: " ")
            }
            searchDelegate?.qwantSearchViewController(self, didAppend: newQuery + " ")
            searchQuery = newQuery + " "
        }
    }

    private var searchAppendImage: UIImage? {
        var searchAppendImage = UIImage(named: "qwant_append")?.withRenderingMode(.alwaysTemplate)

        if !viewModel.isBottomSearchBar, let image = searchAppendImage, let cgImage = image.cgImage {
            searchAppendImage = UIImage(
                cgImage: cgImage,
                scale: image.scale,
                orientation: .downMirrored
            )
        }
        return searchAppendImage
    }

    // MARK: - Notifiable

    func handleNotifications(_ notification: Notification) {
        switch notification.name {
        case .DynamicFontChanged:
            dynamicFontChanged(notification)
        default:
            break
        }
    }

    func dynamicFontChanged(_ notification: Notification) {
        guard notification.name == .DynamicFontChanged else { return }
        reloadData()
    }
}

// MARK: - Keyboard shortcuts
extension QwantSearchViewController {
    func handleKeyCommands(sender: UIKeyCommand) {
        guard let input = sender.input else { return }

        guard let firstSection = SearchListSection.allCases.first(where: {
            tableView(tableView, numberOfRowsInSection: $0.rawValue) > 0
        })?.rawValue else {
            return
        }

        guard let lastSection = SearchListSection.allCases.last(where: {
            tableView(tableView, numberOfRowsInSection: $0.rawValue) > 0
        })?.rawValue else {
            return
        }

        guard let current = tableView.indexPathForSelectedRow else {
            if sender.input == UIKeyCommand.inputDownArrow {
                let next = IndexPath(item: 0, section: firstSection)
                self.tableView(tableView, didHighlightRowAt: next)
                tableView.selectRow(at: next, animated: false, scrollPosition: .top)
            }
            return
        }

        let nextSection: Int
        let nextItem: Int
        switch input {
        case UIKeyCommand.inputDownArrow:
            let currentSectionItemsCount = tableView(tableView, numberOfRowsInSection: current.section)
            if current.item == currentSectionItemsCount - 1 {
                if current.section == lastSection {
                    // We've reached the last item in the last section
                    return
                } else {
                    // We can go to the next section.
                    guard current.section + 1 <= lastSection else { return }
                    nextSection = current.section + 1
                    nextItem = 0
                }
            } else {
                nextSection = current.section
                nextItem = current.item + 1
            }
        case UIKeyCommand.inputUpArrow:
            // we're going down, we should check if we've reached the first item in this section.
            if current.item == 0 {
                // We have, so check if we can decrement the section.
                if current.section == firstSection {
                    // We've reached the first item in the first section.
                    searchDelegate?.qwantSearchViewController(self, didHighlightText: searchQuery, search: false)
                    return
                } else {
                    nextSection = current.section - 1
                    nextItem = tableView(tableView, numberOfRowsInSection: nextSection) - 1
                }
            } else {
                nextSection = current.section
                nextItem = current.item - 1
            }
        default:
            return
        }
        guard nextItem >= 0, nextSection >= firstSection, nextSection <= lastSection else { return }
        let next = IndexPath(item: nextItem, section: nextSection)
        self.tableView(tableView, didHighlightRowAt: next)
        tableView.selectRow(at: next, animated: false, scrollPosition: .middle)
    }
}

/**
 * UIScrollView that prevents buttons from interfering with scroll.
 */
private class ButtonScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}
