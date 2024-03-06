// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

@available(macOS 13.0, *)
enum InputList: String {
    case standard = "standard_lists"
    case strict = "strict_lists"

    func getDirectory(inputDirectory: URL) -> URL {
        return inputDirectory.appending(path: self.rawValue)
    }
}

struct OutputList {
    let name: String
    let id: Int

    var url: String { return "https://filters.adtidy.org/extension/firefox/filters/\(id)_optimized.txt" }
    var filename: String { return name.alphanumeric }
}

private extension String {
    var alphanumeric: String {
        return self.components(separatedBy: .alphanumerics.inverted).joined().lowercased()
    }
}
