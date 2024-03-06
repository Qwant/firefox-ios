// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common

struct QwantVIPInformationVM {
    var title: String {
        return .QwantVIP.Information
    }

    func cellType(for row: Int) -> InformationCellType? {
        return InformationCellType(rawValue: row)
    }
}

enum InformationCellType: Int {
    case information
    case developper

    var title: String {
        switch self {
        case .information: return .QwantVIP.GetToKnow
        case .developper: return .QwantVIP.DeveloperNotes
        }
    }

    var accessoryView: UIView? {
        return UIImageView(image: UIImage(named: "icon_www_external"))
    }

    var url: URL? {
        switch self {
        case .information: return URL(string: "https://about.qwant.com/extension/")
        case .developper: return URL(string: "https://github.com/Qwant/qwant-viprivacy#readme")
        }
    }
}
