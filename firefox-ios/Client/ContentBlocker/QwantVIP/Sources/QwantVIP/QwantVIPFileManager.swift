// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol QwantVIPFileManager {
    func getLists() -> [String]
    func downloadSubscriptionSkeleton() async throws -> URL?
    func write(_ data: Data, named name: String) throws
}

@available(macOS 13.0, *)
class DefaultQwantVIPFileManager: QwantVIPFileManager {
    private let fileManager: FileManager
    private let fallbackPath: String = (#file as NSString).deletingLastPathComponent + "/../.."
    private let rootDirectory: String
    private let inputDirectory: URL
    private let outputDirectory: URL

    private let listsUrl = "https://f.qwant.com/tracking-protection/firefox_filters.json"

    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager

        let execIsFromCorrectDir = fileManager.fileExists(atPath: fileManager.currentDirectoryPath + "/Package.swift")
        self.rootDirectory = execIsFromCorrectDir ? fileManager.currentDirectoryPath : fallbackPath
        self.inputDirectory = URL(fileURLWithPath: "\(rootDirectory)/../QwantVIP_Lists/")
        self.outputDirectory = URL(fileURLWithPath: "\(rootDirectory)/../Lists/")

        self.createDirectory()
    }

    /// Remove and create the output dir
    private func createDirectory() {
        try? self.fileManager.removeItem(at: self.outputDirectory)
        do {
            try self.fileManager.createDirectory(at: self.outputDirectory,
                                                 withIntermediateDirectories: false,
                                                 attributes: nil)
        } catch {
            fatalError("Could not create directory at \(self.outputDirectory)")
        }
    }

    func getLists() -> [String] {
        let standardListUrl = InputList.standard.getDirectory(inputDirectory: self.inputDirectory)
        let standardLists = try? String(contentsOf: standardListUrl, encoding: .utf8)

        let strictListUrl = InputList.strict.getDirectory(inputDirectory: self.inputDirectory)
        let strictLists = try? String(contentsOf: strictListUrl, encoding: .utf8)

        return [standardLists, strictLists].flatMap {
            $0?.split(separator: "\n")
                .map { String(describing: $0) }
                .dropLast() ?? []
        }
    }

    func downloadSubscriptionSkeleton() async throws -> URL? {
        let sourceURL = URL(string: self.listsUrl)!
        let outputFile = self.inputDirectory.appending(component: "lists.json")
        do {
            let (data, _) = try await URLSession.shared.data(from: sourceURL)
            try data.write(to: outputFile)
            return outputFile
        } catch {
            return nil
        }
    }

    func write(_ data: Data, named name: String) throws {
        let url = self.outputDirectory.appending(path: name)
        if let fileHandle = FileHandle(forWritingAtPath: url.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            try String(data: data, encoding: .utf8)?.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
