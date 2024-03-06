// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol QwantVIPParser {
    func parseLists(from rawLists: URL, with lists: [String]) -> [OutputList]
}

// swiftlint:disable force_try
class DefaultQwantVIPParser: QwantVIPParser {
    func parseLists(from rawLists: URL, with lists: [String]) -> [OutputList] {
        let data = try! Data(contentsOf: rawLists)
        let root = try! JSONDecoder().decode(Root.self, from: data)

        return root.filters
            .filter { lists.contains($0.name) }
            .reduce(into: [OutputList]()) { $0.append(OutputList(name: $1.name, id: $1.filterID)) }
    }
}
// swiftlint:enable force_try
