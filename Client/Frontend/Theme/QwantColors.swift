// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension UIColor {
    struct Qwant {
        struct Theme {
            static let PaleViolet = UIColor(rgb: 0xDED6FF)
            static let PaleGreen = UIColor(rgb: 0xB3E6CC)
            static let Red60 = UIColor(rgb: 0xe22850)
            static let Green60 = UIColor(rgb: 0x2ac3a2)
        }
        
        struct Light {
            static let TextColor = UIColor(rgb: 0x000000)
            static let TextBackground = UIColor(rgb: 0xFFFFFF)
            static let BorderColor = UIColor(rgb: 0x676E79)
            static let BorderShadow = UIColor(rgb: 0xC8CBD0)
        }
        
        struct Dark {
            static let TextColor = UIColor(rgb: 0xFFFFFF)
            static let TextBackground = UIColor(rgb: 0x131416)
            static let BorderColor = UIColor(rgb: 0x676E79)
            static let BorderShadow = UIColor(rgb: 0x4B5058)
        }
    }
}
