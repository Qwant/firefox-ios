// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import Foundation
import Shared

class TrackingProtectionButton: UIButton {
    
    private lazy var badgeLabel: InsetLabel = .build { label in
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.layer.zPosition = 1
        label.layer.masksToBounds = false
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.layer.borderWidth = 1
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 1.0
        label.layer.shadowRadius = 0.0
        label.contentInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: topAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        setImage(UIImage(imageLiteralResourceName: "tracking_protection_on"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBadgeValue(value: Int) {
        guard value > 0 else {
            badgeLabel.isHidden = true
            return
        }
        badgeLabel.isHidden = false
        badgeLabel.text = value < 100 ? String(describing: value) : "99+"
    }
}

// MARK: - Theme protocols

extension TrackingProtectionButton: ThemeApplicable {
    func applyTheme(theme: Theme) {
        if theme.type == .light {
            badgeLabel.textColor = .Qwant.Light.TextColor
            badgeLabel.layer.backgroundColor = UIColor.Qwant.Light.TextBackground.cgColor
            badgeLabel.layer.borderColor = UIColor.Qwant.Light.BorderColor.cgColor
            badgeLabel.layer.shadowColor = UIColor.Qwant.Light.BorderShadow.cgColor
        } else {
            badgeLabel.textColor = .Qwant.Dark.TextColor
            badgeLabel.layer.backgroundColor = UIColor.Qwant.Dark.TextBackground.cgColor
            badgeLabel.layer.borderColor = UIColor.Qwant.Dark.BorderColor.cgColor
            badgeLabel.layer.shadowColor = UIColor.Qwant.Dark.BorderShadow.cgColor
        }
    }
}

class InsetLabel: UILabel {
    
    var contentInsets = UIEdgeInsets.zero
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }
    
    private func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + contentInsets.left + contentInsets.right
        let height = size.height + contentInsets.top + contentInsets.bottom
        return CGSize(width: width, height: height)
    }
}
