// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

class ZapButton: ToolbarButton {
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(defaultImage, for: .normal)
        isAnimating = false
    }

    convenience init() {
        self.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    private var isAnimating = false

    override var isHighlighted: Bool {
        didSet {
            self.stopAnimating()
            self.tintColor = isHighlighted ? selectedTintColor : unselectedTintColor
        }
    }

    override open var isEnabled: Bool {
        didSet {
            if !isEnabled { self.stopAnimating() }
        }
    }

    private lazy var animatedImage: UIImage = {
        let count = 16
        var images = Array(
            repeating: UIImage(named: "zap_animation_1")!.withRenderingMode(.alwaysTemplate),
            count: count * 2
        )
        for i in 0...3 {
            images += (1...count).map { UIImage(named: "zap_animation_\($0)")!.withRenderingMode(.alwaysTemplate) }
        }
        return UIImage.animatedImage(with: images, duration: 6)!.withRenderingMode(.alwaysTemplate)
    }()

    private lazy var defaultImage: UIImage = {
        return UIImage(named: "qwant_zap")!.withRenderingMode(.alwaysTemplate)
    }()

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        setImage(animatedImage, for: .normal)
    }

    func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        setImage(defaultImage, for: .normal)
    }
}
