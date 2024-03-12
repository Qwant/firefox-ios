// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import SiteImageView

class QwantBrandSuggestCell: UITableViewCell, ReusableCell, ThemeApplicable {
    struct UX {
        static let imageSize: CGFloat = 28
        static let borderViewMargin: CGFloat = 16
        static let iconBorderWidth: CGFloat = 0.5
    }

    weak var delegate: BrandSuggestCellDelegate?
    var suggest: QwantSuggest?

    // Tableview cell items
    private lazy var selectedView: UIView = .build { _ in }

    lazy var containerView: UIView = .build { view in
        view.backgroundColor = .clear
    }

    lazy var leftImageView: FaviconImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = QwantUX.SystemDesign.Favicon.cornerRadius
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = QwantUX.SystemDesign.Favicon.borderWidth
        imageView.backgroundColor = .clear
    }

    lazy var titleLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(withTextStyle: .body, size: 16)
        label.textAlignment = .natural
        label.numberOfLines = 2
    }

    lazy var adLabel: UILabel = .build { label in
        label.font = DefaultDynamicFontHelper.preferredFont(withTextStyle: .body, size: 12)
        label.textAlignment = .natural
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    lazy var informationIcon: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        imageView.image = UIImage(imageLiteralResourceName: "qwant_information")
    }

    lazy var invisibleTapZone: UIButton = .build { button in
        button.addTarget(self, action: #selector(self.infoTapped), for: .touchUpInside)
    }

    var topSeparatorView: UIView = .build()
    var bottomSeparatorView: UIView = .build()

    func addCustomSeparator(atTop: Bool, atBottom: Bool) {
        let height: CGFloat = 0.5  // firefox separator height
        let leading: CGFloat = atTop || atBottom ? 0 : 50 // 50 is just a placeholder fallback
        if atTop {
            topSeparatorView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: height))
            topSeparatorView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            contentView.addSubview(topSeparatorView)
        }

        if atBottom {
            bottomSeparatorView = UIView(
                frame: CGRect(
                    x: leading,
                    y: frame.size.height - height,
                    width: frame.size.width,
                    height: height
                )
            )
            bottomSeparatorView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
            contentView.addSubview(bottomSeparatorView)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        separatorInset = UIEdgeInsets(top: 0,
                                      left: QwantUX.SystemDesign.Favicon.height + 2 * QwantUX.Spacing.m,
                                      bottom: 0,
                                      right: 0)
        selectionStyle = .default

        containerView.addSubview(leftImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(adLabel)
        containerView.addSubview(informationIcon)
        containerView.addSubview(invisibleTapZone)

        contentView.addSubview(containerView)
        bringSubviewToFront(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -QwantUX.Spacing.m),

            leftImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                   constant: QwantUX.Spacing.m),
            leftImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leftImageView.heightAnchor.constraint(equalToConstant: UX.imageSize),
            leftImageView.widthAnchor.constraint(equalToConstant: UX.imageSize),
            leftImageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor,
                                                    constant: -QwantUX.Spacing.m),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,
                                            constant: QwantUX.Spacing.xs),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                               constant: -QwantUX.Spacing.xs),
            titleLabel.trailingAnchor.constraint(equalTo: adLabel.leadingAnchor,
                                                 constant: -QwantUX.Spacing.xs),

            adLabel.topAnchor.constraint(equalTo: containerView.topAnchor,
                                         constant: QwantUX.Spacing.xs),
            adLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                            constant: -QwantUX.Spacing.xs),
            adLabel.trailingAnchor.constraint(equalTo: informationIcon.leadingAnchor,
                                              constant: -QwantUX.Spacing.xs),

            informationIcon.topAnchor.constraint(equalTo: containerView.topAnchor,
                                                 constant: QwantUX.Spacing.xs),
            informationIcon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                    constant: -QwantUX.Spacing.xs),
            informationIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                      constant: -6),
            informationIcon.widthAnchor.constraint(equalToConstant: QwantUX.Spacing.m),

            invisibleTapZone.topAnchor.constraint(equalTo: containerView.topAnchor),
            invisibleTapZone.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            invisibleTapZone.leadingAnchor.constraint(equalTo: adLabel.leadingAnchor),
            invisibleTapZone.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        selectedBackgroundView = selectedView
    }

    func applyTheme(theme: Theme) {
        backgroundColor = theme.colors.layer5
        selectedView.backgroundColor = theme.colors.layer5Hover
        titleLabel.textColor = theme.colors.textPrimary
        adLabel.textColor = theme.colors.textSecondary
        leftImageView.layer.borderColor = theme.colors.borderPrimary.cgColor
        accessoryView?.tintColor = theme.colors.actionSecondary
        topSeparatorView.backgroundColor = theme.colors.borderPrimary
        bottomSeparatorView.backgroundColor = theme.colors.borderPrimary
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        selectionStyle = .default
        separatorInset = UIEdgeInsets(
            top: 0,
            left: QwantUX.SystemDesign.Favicon.height + 2 * QwantUX.Spacing.m,
            bottom: 0,
            right: 0
        )
        delegate = nil
        suggest = nil
    }

    @objc
    private func infoTapped() {
        delegate?.brandSuggestCellDidTapInfo(suggest)
    }
}

protocol BrandSuggestCellDelegate: AnyObject {
    func brandSuggestCellDidTapInfo(_ suggest: QwantSuggest?)
}
