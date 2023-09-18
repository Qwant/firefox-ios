// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIColor {
    
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }

    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0

        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )

        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }

    func lighter(componentDelta: CGFloat = 0.8) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }

    func darker(componentDelta: CGFloat = 0.8) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
}
