// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

class ButtonCell: UITableViewCell, ThemeApplicable {
    static let Identifier = "ButtonCell"
    
    private let button = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.cornerRadius = QwantUX.SystemDesign.cornerRadius
        button.clipsToBounds = true
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: QwantUX.Spacing.xxxs)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: QwantUX.Spacing.xxxs, bottom: 0, right: 0)
        button.titleLabel?.font = QwantUX.Font.Text.l
        button.isUserInteractionEnabled = false
        
        contentView.addSubviews(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: QwantUX.Spacing.s),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: QwantUX.Spacing.m),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -QwantUX.Spacing.m),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -QwantUX.Spacing.s)
        ])
    }
    
    func configureCell(icon: UIImage, text: String, color: UIColor) {
        button.setImage(icon, for: .normal)
        button.setTitle(text, for: .normal)
        button.setTitleColor(color, for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyTheme(theme: Theme) {
        
    }
}
