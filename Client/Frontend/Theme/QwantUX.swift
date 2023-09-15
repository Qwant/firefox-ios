// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

struct QwantUX {
    struct Font {
        struct Title {
            /// 28 - bold
            static let l: UIFont = .systemFont(ofSize: 28, weight: .bold)
            /// 22 - bold
            static let m: UIFont = .systemFont(ofSize: 22, weight: .bold)
            /// 20 - bold
            static let s: UIFont = .systemFont(ofSize: 20, weight: .bold)
        }
        
        struct Text {
            /// 17 - semibold
            static let xl: UIFont = .systemFont(ofSize: 17, weight: .semibold)
            /// 17 - regular
            static let l: UIFont = .systemFont(ofSize: 17, weight: .regular)
            /// 15 - regular
            static let m: UIFont = .systemFont(ofSize: 15, weight: .regular)
            /// 12 - regular
            static let s: UIFont = .systemFont(ofSize: 12, weight: .regular)
        }
    }
    
    struct Spacing {
        /// XXXXXL spacing is 64
        static let xxxxxl: CGFloat = 64
        /// XXXXL spacing is 50
        static let xxxxl: CGFloat = 50
        /// XXXL spacing is 40
        static let xxxl: CGFloat = 40
        /// XXL spacing is 32
        static let xxl: CGFloat = 32
        /// XL spacing is 24
        static let xl: CGFloat = 24
        /// L spacing is 20
        static let l: CGFloat = 20
        /// M spacing is 16
        static let m: CGFloat = 16
        /// S spacing is 12
        static let s: CGFloat = 12
        /// XS spacing is 8
        static let xs: CGFloat = 8
        /// XXS spacing is 5
        static let xxs: CGFloat = 5
        /// XXXS spacing is 2
        static let xxxs: CGFloat = 2
    }
    
    struct SystemDesign {
        /// Height of a button is 48
        static let buttonHeight: CGFloat = 48
        /// Height of a bullet is 20
        static let bulletHeight: CGFloat = 20
        /// Corner radius is 8
        static let cornerRadius: CGFloat = 8
    }
}
