// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

public struct DarkTheme: Theme {
    public var type: ThemeType = .dark
    public var colors: ThemeColourPalette = DarkColourPalette()

    public init() {}
}

private struct DarkColourPalette: ThemeColourPalette {
    // MARK: - Layers
    var layer1: UIColor = FXColors.DarkGrey60
    var layer2: UIColor = FXColors.DarkGrey30
    var layer3: UIColor = FXColors.DarkGrey80
    var layer4: UIColor = FXColors.DarkGrey20.withAlphaComponent(0.7)
    var layer5: UIColor = FXColors.DarkGrey40
    var layer6: UIColor = FXColors.DarkGrey60
    var layer5Hover: UIColor = FXColors.DarkGrey20
    var layerScrim: UIColor = FXColors.DarkGrey90.withAlphaComponent(0.95)
    var layerGradient = Gradient(colors: [FXColors.Violet40, FXColors.Violet70])
    var layerGradientOverlay = Gradient(colors: [FXColors.DarkGrey40.withAlphaComponent(0),
                                                 FXColors.DarkGrey40.withAlphaComponent(0.4)])
    var layerAccentNonOpaque: UIColor = FXColors.Blue20.withAlphaComponent(0.2)
    var layerAccentPrivate: UIColor = FXColors.Purple60
    var layerAccentPrivateNonOpaque: UIColor = FXColors.Purple60.withAlphaComponent(0.3)
    var layerLightGrey30: UIColor = FXColors.LightGrey30
    var layerSepia: UIColor = FXColors.Orange05
    var layerInfo: UIColor = FXColors.Blue60.withAlphaComponent(0.8)
    var layerConfirmation: UIColor = FXColors.Green80
    var layerWarning: UIColor = FXColors.Yellow70.withAlphaComponent(0.77)
    var layerError: UIColor = FXColors.Pink80

    // MARK: - Actions
    var actionPrimary: UIColor = FXColors.Blue30
    var actionPrimaryHover: UIColor = FXColors.Blue20
    var actionSecondary: UIColor = FXColors.LightGrey30
    var actionSecondaryHover: UIColor = FXColors.LightGrey20
    var formSurfaceOff: UIColor = FXColors.DarkGrey05
    var formKnob: UIColor = FXColors.White
    var indicatorActive: UIColor = FXColors.LightGrey90
    var indicatorInactive: UIColor = FXColors.DarkGrey05
    var actionConfirmation: UIColor = FXColors.Green70
    var actionWarning: UIColor = FXColors.Yellow40.withAlphaComponent(0.41)
    var actionError: UIColor = FXColors.Pink70.withAlphaComponent(0.69)

    // MARK: - Text
    var textPrimary: UIColor = FXColors.LightGrey05
    var textSecondary: UIColor = FXColors.LightGrey40
    var textSecondaryAction: UIColor = FXColors.DarkGrey90
    var textDisabled: UIColor = FXColors.LightGrey05.withAlphaComponent(0.4)
    var textWarning: UIColor = FXColors.Red20
    var textAccent: UIColor = FXColors.Blue30
    var textOnDark: UIColor = FXColors.LightGrey05
    var textOnLight: UIColor = FXColors.DarkGrey90
    var textInverted: UIColor = FXColors.DarkGrey90

    // MARK: - Icons
    var iconPrimary: UIColor = FXColors.LightGrey05
    var iconSecondary: UIColor = FXColors.LightGrey40
    var iconDisabled: UIColor = FXColors.LightGrey05.withAlphaComponent(0.4)
    var iconAction: UIColor = FXColors.Blue30
    var iconOnColor: UIColor = FXColors.LightGrey05
    var iconWarning: UIColor = FXColors.Red20
    var iconSpinner: UIColor = FXColors.White
    var iconAccentViolet: UIColor = FXColors.Violet20
    var iconAccentBlue: UIColor = FXColors.Blue30
    var iconAccentPink: UIColor = FXColors.Pink20
    var iconAccentGreen: UIColor = FXColors.Green20
    var iconAccentYellow: UIColor = FXColors.Yellow20

    // MARK: - Border
    var borderPrimary: UIColor = FXColors.DarkGrey05
    var borderAccent: UIColor = FXColors.Blue30
    var borderAccentNonOpaque: UIColor = FXColors.Blue20.withAlphaComponent(0.2)
    var borderAccentPrivate: UIColor = FXColors.Purple60
    var borderInverted: UIColor = FXColors.DarkGrey90

    // MARK: - Shadow
    var shadowDefault: UIColor = FXColors.DarkGrey90.withAlphaComponent(0.16)

    // MARK: - Qwant
    var vip_background: UIColor = .black
    var vip_sectionColor: UIColor = UIColor(rgb: 0x212327)
    var vip_textColor: UIColor = .white
    var vip_subtextColor: UIColor = UIColor(rgb: 0xa7acb4)
    var vip_greenText: UIColor = UIColor(rgb: 0x57c78f)
    var vip_redText: UIColor = UIColor(rgb: 0xff5c5f)
    var vip_blackText: UIColor = UIColor(rgb: 0x050506)
    var vip_horizontalLine: UIColor = UIColor(rgb: 0x4b5058)
    var vip_switchAndButtonTint: UIColor = UIColor(rgb: 0x5c97ff)
    var vip_greenIcon: UIColor = UIColor(rgb: 0x85d6ad)
    var vip_redIcon: UIColor = UIColor(rgb: 0xff999b)
    var vip_grayIcon: UIColor = UIColor(rgb: 0xc8cbd0)
    
    var onboarding_palePink: UIColor = UIColor(rgb: 0xffd6d7)
    var onboarding_paleBlue: UIColor = UIColor(rgb: 0x99beff)
    var onboarding_paleGreen: UIColor = UIColor(rgb: 0xb3e6cc)
    var onboarding_blackText: UIColor = UIColor(rgb: 0x050506)
    var onboarding_whiteText: UIColor = .white

    var omnibar_tableViewSeparator: UIColor = UIColor(rgb: 0x3C3C43).withAlphaComponent(0.36)
    var omnibar_keyboardBackground: UIColor = UIColor(rgb: 0x353539)
    var omnibar_urlBarBorder: UIColor = UIColor(rgba: 0x0c0c0d19)
    var omnibar_blue: UIColor = UIColor(rgb: 0x5C97FF)
    var omnibar_purple: UIColor = UIColor(rgb: 0xAC99FF)
    var omnibar_gray: UIColor = UIColor(rgb: 0x8E8E93)
    func omnibar_tableViewBackground(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? .black : UIColor(rgb: 0x140a3d)
    }
    func omnibar_tableViewCellPrimaryText(_ isPrivate: Bool) -> UIColor { return .white }
    func omnibar_tableViewCellSecondaryText(_ isPrivate: Bool) -> UIColor { return .white }
    func omnibar_tableViewCellBackground(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgb: 0x2C2C2E) : UIColor(rgb: 0x1C0E58)
    }
    func omnibar_tableViewSelectedCellBackground(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgb: 0x1C1C1E) : UIColor(rgb: 0x4D3195)
    }
    func omnibar_qwantLogo(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgb: 0x5C97FF) : UIColor(rgb: 0xAC99FF)
    }
    func omnibar_tintColor(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? omnibar_blue : omnibar_purple
    }
    func omnibar_highlightedTintColor(_ isPrivate: Bool) -> UIColor {
        omnibar_tintColor(isPrivate).withAlphaComponent(0.8)
    }
    func omnibar_borderColor(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgba: 0x0c0c0d19) : omnibar_purple
    }
    func omnibar_urlBarBackground(_ isPrivate: Bool) -> UIColor { return UIColor(rgb: 0x48484A) }
    func omnibar_urlBarText(_ isPrivate: Bool) -> UIColor { return UIColor(rgb: 0xf9f9fb) }
    func omnibar_gray(_ isPrivate: Bool) -> UIColor {
        return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 245.0/255.0, alpha: 0.6)
    }
}
