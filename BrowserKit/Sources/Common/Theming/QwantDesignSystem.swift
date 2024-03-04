// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

public struct QwantColors {
    public static let grey000 = UIColor(rgb: 0xFFFFFF)
    public static let grey050 = UIColor(rgb: 0xF9FAFB)
    public static let grey100 = UIColor(rgb: 0xF2F4F7)
    public static let grey200 = UIColor(rgb: 0xE6EAEF)
    public static let grey300 = UIColor(rgb: 0xDADFE7)
    public static let grey400 = UIColor(rgb: 0xC1CAD7)
    public static let grey500 = UIColor(rgb: 0xA8B4C7)
    public static let grey600 = UIColor(rgb: 0x8395AF)
    public static let grey700 = UIColor(rgb: 0x647896)
    public static let grey800 = UIColor(rgb: 0x4D596A)
    public static let grey900 = UIColor(rgb: 0x3C4553)
    public static let grey1000 = UIColor(rgb: 0x2D3239)
    public static let grey1050 = UIColor(rgb: 0x282B2F)
    public static let grey1100 = UIColor(rgb: 0x212327)
    public static let grey1200 = UIColor(rgb: 0x131416)

    public static let greyAlpha000 = UIColor(rgba: 0x5D759800)
    public static let greyAlpha100 = UIColor(rgba: 0x5D759814)
    public static let greyAlpha200 = UIColor(rgba: 0x5D759829)
    public static let greyAlpha300 = UIColor(rgba: 0x5D75983D)
    public static let greyAlpha400 = UIColor(rgba: 0x5D759852)
    public static let greyAlpha700 = UIColor(rgba: 0xC8DCF952)
    public static let greyAlpha800 = UIColor(rgba: 0xC8DCF93D)
    public static let greyAlpha900 = UIColor(rgba: 0xC8DCF929)
    public static let greyAlpha1000 = UIColor(rgba: 0xC8DCF914)
    public static let greyAlpha1100 = UIColor(rgba: 0xC8DCF900)
}

public struct QwantUX {
    public struct Font {
        public struct Title {
            /// 28 - bold
            public static let l: UIFont = DefaultDynamicFontHelper
                .preferredBoldFont(withTextStyle: .title1, size: 28)
            /// 22 - bold
            public static let m: UIFont = DefaultDynamicFontHelper
                .preferredBoldFont(withTextStyle: .title2, size: 22)
            /// 20 - bold
            public static let s: UIFont = DefaultDynamicFontHelper
                .preferredBoldFont(withTextStyle: .title3, size: 20)
        }

        public struct Text {
            /// 17 - semibold
            public static let xl: UIFont = DefaultDynamicFontHelper
                .preferredFont(withTextStyle: .headline, size: 17, weight: .semibold)
            /// 17 - regular
            public static let l: UIFont = DefaultDynamicFontHelper
                .preferredFont(withTextStyle: .body, size: 17, weight: .regular)
            /// 15 - regular
            public static let m: UIFont = DefaultDynamicFontHelper
                .preferredFont(withTextStyle: .body, size: 15, weight: .regular)
            /// 12 - regular
            public static let s: UIFont = DefaultDynamicFontHelper
                .preferredFont(withTextStyle: .footnote, size: 12, weight: .regular)
        }
    }

    public struct Spacing {
        /// XXXXXL spacing is 64
        public static let xxxxxl: CGFloat = 64
        /// XXXXL spacing is 50
        public static let xxxxl: CGFloat = 50
        /// XXXL spacing is 40
        public static let xxxl: CGFloat = 40
        /// XXL spacing is 32
        public static let xxl: CGFloat = 32
        /// XL spacing is 24
        public static let xl: CGFloat = 24
        /// L spacing is 20
        public static let l: CGFloat = 20
        /// M spacing is 16
        public static let m: CGFloat = 16
        /// S spacing is 12
        public static let s: CGFloat = 12
        /// XS spacing is 8
        public static let xs: CGFloat = 8
        /// XXS spacing is 5
        public static let xxs: CGFloat = 5
        /// XXXS spacing is 2
        public static let xxxs: CGFloat = 2
    }

    public struct SystemDesign {
        /// Height of a button is 48
        public static let buttonHeight: CGFloat = 48
        /// Height of a bullet is 20
        public static let bulletHeight: CGFloat = 20
        /// Corner radius is 8
        public static let cornerRadius: CGFloat = 8
    }
}
