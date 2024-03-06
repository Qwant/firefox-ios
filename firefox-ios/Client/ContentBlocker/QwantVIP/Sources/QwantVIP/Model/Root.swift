// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

// MARK: - Welcome
struct Root: Codable {
    let groups: [Group]
    let tags: [Tag]
    let filters: [Filter]
}

// MARK: - Filter
struct Filter: Codable {
    let filterID: Int
    let name, filterDescription: String
    let homepage: String
    let expires, displayNumber, groupID: Int
    let subscriptionURL: String
    let trustLevel: TrustLevel
    let version: String
    let languages: [String]
    let tags: [Int]
    let platformsExcluded: [String]?

    enum CodingKeys: String, CodingKey {
        case filterID = "filterId"
        case name
        case filterDescription = "description"
        case homepage, expires, displayNumber
        case groupID = "groupId"
        case subscriptionURL = "subscriptionUrl"
        case trustLevel, version, languages, tags, platformsExcluded
    }
}

enum TrustLevel: String, Codable {
    case full = "full"
    case high = "high"
    case low = "low"
}

// MARK: - Group
struct Group: Codable {
    let groupID: Int
    let groupName: String
    let displayNumber: Int

    enum CodingKeys: String, CodingKey {
        case groupID = "groupId"
        case groupName, displayNumber
    }
}

// MARK: - Tag
struct Tag: Codable {
    let tagID: Int
    let keyword: String

    enum CodingKeys: String, CodingKey {
        case tagID = "tagId"
        case keyword
    }
}
