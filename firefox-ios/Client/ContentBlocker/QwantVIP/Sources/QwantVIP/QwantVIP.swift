// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

@available(macOS 13.0, *)
@main
public struct QwantVIP {
    static let shared = QwantVIP()

    public static func main() async {
        do {
            try await shared.parseLists()
        } catch { }
    }

    private let fileManager: QwantVIPFileManager
    private let parser: QwantVIPParser

    init(fileManager: QwantVIPFileManager = DefaultQwantVIPFileManager(),
         parser: QwantVIPParser = DefaultQwantVIPParser()) {
        self.fileManager = fileManager
        self.parser = parser
    }

    private func parseLists() async throws {
        let selectedLists = self.fileManager.getLists()
        let skeletonURL = try await self.fileManager.downloadSubscriptionSkeleton()

        guard let skeletonURL = skeletonURL else { fatalError("Failed to download skeleton") }
        let lists = self.parser.parseLists(from: skeletonURL, with: selectedLists)

        await withTaskGroup(of: Void.self) { group in
            for list in lists {
                group.addTask {
                    do {
                        let url = URL(string: list.url)!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        try self.fileManager.write(data, named: list.filename)
                    } catch {
                        // Handle errors if needed
                        print("Error for request \(list.url): \(error)")
                    }
                }
            }
        }
    }
}
