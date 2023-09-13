// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

struct QwantUX {
    struct Font {
        static let title: UIFont = .systemFont(ofSize: 28, weight: .bold)
        static let text: UIFont = .systemFont(ofSize: 16, weight: .regular)
        static let button: UIFont = .systemFont(ofSize: 18, weight: .regular)
    }
    
    struct Spacing {
        static let gutterL: CGFloat = 50
        static let gutterM: CGFloat = 28
        static let xxl: CGFloat = 40
        static let xl: CGFloat = 24
        static let l: CGFloat = 20
        static let m: CGFloat = 16
        static let s: CGFloat = 12
        static let xs: CGFloat = 8
        static let xxs: CGFloat = 5
        static let buttonHeight: CGFloat = 48
        static let bulletHeight: CGFloat = 20
    }
}
