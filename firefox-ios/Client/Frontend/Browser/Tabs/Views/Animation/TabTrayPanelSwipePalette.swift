// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

struct TabTrayPanelSwipePalette: ThemeColourPalette {
    private let base: ThemeColourPalette
    private let partialOverrides: PartialOverrides

    // MARK: Overridden colors
    var layer1: UIColor {
        return partialOverrides.layer1
    }

    var iconPrimary: UIColor {
        return partialOverrides.iconPrimary
    }

    var textPrimary: UIColor {
        return partialOverrides.textPrimary
    }

    var actionSecondary: UIColor {
        return partialOverrides.actionSecondary
    }

    var layerScrim: UIColor {
        return partialOverrides.layerScrim
    }

    var layer3: UIColor {
        return partialOverrides.layer3
    }

    var textOnDark: UIColor {
        return partialOverrides.textOnDark
    }

    var borderPrimary: UIColor {
        return partialOverrides.borderPrimary
    }

    var borderAccent: UIColor {
        return partialOverrides.borderAccent
    }

    var borderAccentPrivate: UIColor {
        return partialOverrides.borderAccentPrivate
    }

    var shadowDefault: UIColor {
        return partialOverrides.shadowDefault
    }

    var iconDisabled: UIColor {
        return partialOverrides.iconDisabled
    }

    struct PartialOverrides {
        var layer1: UIColor
        var iconPrimary: UIColor
        var textPrimary: UIColor
        var actionSecondary: UIColor
        var layerScrim: UIColor
        var layer3: UIColor
        var textOnDark: UIColor
        var borderPrimary: UIColor
        var borderAccent: UIColor
        var borderAccentPrivate: UIColor
        var shadowDefault: UIColor
        var iconDisabled: UIColor
    }

    var layer2: UIColor { base.layer2 }
    var layer4: UIColor { base.layer4 }
    var layer5: UIColor { base.layer5 }
    var layer5Hover: UIColor { base.layer5Hover }
    var layerGradient: Gradient { base.layerGradient }
    var layerGradientOverlay: Gradient { base.layerGradientOverlay }
    var layerAccentNonOpaque: UIColor { base.layerAccentNonOpaque }
    var layerAccentPrivate: UIColor { base.layerAccentPrivate }
    var layerAccentPrivateNonOpaque: UIColor { base.layerAccentPrivateNonOpaque }
    var layerSepia: UIColor { base.layerSepia }
    var layerHomepage: Gradient { base.layerHomepage }
    var layerInformation: UIColor { base.layerInformation }
    var layerSuccess: UIColor { base.layerSuccess }
    var layerWarning: UIColor { base.layerWarning }
    var layerCritical: UIColor { base.layerCritical }
    var layerSelectedText: UIColor { base.layerSelectedText }
    var layerAutofillText: UIColor { base.layerAutofillText }
    var layerSearch: UIColor { base.layerSearch }
    var layerGradientURL: Gradient { base.layerGradientURL }

    var layerRatingA: UIColor { base.layerRatingA }
    var layerRatingASubdued: UIColor { base.layerRatingASubdued }
    var layerRatingB: UIColor { base.layerRatingB }
    var layerRatingBSubdued: UIColor { base.layerRatingBSubdued }
    var layerRatingC: UIColor { base.layerRatingC }
    var layerRatingCSubdued: UIColor { base.layerRatingCSubdued }
    var layerRatingD: UIColor { base.layerRatingD }
    var layerRatingDSubdued: UIColor { base.layerRatingDSubdued }
    var layerRatingF: UIColor { base.layerRatingF }
    var layerRatingFSubdued: UIColor { base.layerRatingFSubdued }

    var actionPrimary: UIColor { base.actionPrimary }
    var actionPrimaryHover: UIColor { base.actionPrimaryHover }
    var actionPrimaryDisabled: UIColor { base.actionPrimaryDisabled }
    var actionSecondaryHover: UIColor { base.actionSecondaryHover }
    var formSurfaceOff: UIColor { base.formSurfaceOff }
    var formKnob: UIColor { base.formKnob }
    var indicatorActive: UIColor { base.indicatorActive }
    var indicatorInactive: UIColor { base.indicatorInactive }
    var actionSuccess: UIColor { base.actionSuccess }
    var actionWarning: UIColor { base.actionWarning }
    var actionCritical: UIColor { base.actionCritical }
    var actionInformation: UIColor { base.actionInformation }
    var actionTabActive: UIColor { base.actionTabActive }
    var actionTabInactive: UIColor { base.actionTabInactive }

    var textSecondary: UIColor { base.textSecondary }
    var textDisabled: UIColor { base.textDisabled }
    var textCritical: UIColor { base.textCritical }
    var textAccent: UIColor { base.textAccent }
    var textOnLight: UIColor { base.textOnLight }
    var textInverted: UIColor { base.textInverted }
    var textInvertedDisabled: UIColor { base.textInvertedDisabled }

    var iconSecondary: UIColor { base.iconSecondary }
    var iconAccent: UIColor { base.iconAccent }
    var iconOnColor: UIColor { base.iconOnColor }
    var iconCritical: UIColor { base.iconCritical }
    var iconSpinner: UIColor { base.iconSpinner }
    var iconAccentViolet: UIColor { base.iconAccentViolet }
    var iconAccentBlue: UIColor { base.iconAccentBlue }
    var iconAccentPink: UIColor { base.iconAccentPink }
    var iconAccentGreen: UIColor { base.iconAccentGreen }
    var iconAccentYellow: UIColor { base.iconAccentYellow }
    var iconRatingNeutral: UIColor { base.iconRatingNeutral }

    var borderAccentNonOpaque: UIColor { base.borderAccentNonOpaque }
    var borderInverted: UIColor { base.borderInverted }
    var borderToolbarDivider: UIColor { base.borderToolbarDivider }

    var shadowSubtle: UIColor { base.shadowSubtle }
    var shadowStrong: UIColor { base.shadowStrong }

    // MARK: - Qwant Omnibar
    var omnibar_tableViewSeparator = UIColor(rgb: 0x3C3C43).withAlphaComponent(0.36)
    var omnibar_keyboardBackground = UIColor(rgb: 0xD2D4DA)
    var omnibar_blue = QwantColors.grey1100
    var omnibar_purple = UIColor(rgb: 0x7B5CFF)
    var omnibar_gray = UIColor(rgb: 0x8E8E93)
    func omnibar_tableViewBackground(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgb: 0xF4F5F6) : UIColor(rgb: 0x140a3d)
    }
    func omnibar_tableViewCellPrimaryText(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? .black : .white
    }
    func omnibar_tableViewCellSecondaryText(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgb: 0x636366) : .white
    }
    func omnibar_tableViewCellBackground(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? .white : UIColor(rgb: 0x1C0E58)
    }
    func omnibar_tableViewSelectedCellBackground(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgb: 0xC7C7CC) : UIColor(rgb: 0x4D3195)
    }
    func omnibar_qwantLogo(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? QwantColors.grey1100 : omnibar_purple
    }
    func omnibar_qwantLogoTint(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? QwantColors.grey000 : QwantColors.grey1100
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
    func omnibar_urlBarBackground(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? .white : UIColor(rgb: 0x48484a)
    }
    func omnibar_urlBarText(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor(rgb: 0x2a2a2e) : UIColor(rgb: 0xf9f9fb)
    }
    func omnibar_gray(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ?
        UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.6) :
        UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 245.0/255.0, alpha: 0.6)
    }
    init(base: ThemeColourPalette, overrides: PartialOverrides) {
        self.base = base
        self.partialOverrides = overrides
    }
}
