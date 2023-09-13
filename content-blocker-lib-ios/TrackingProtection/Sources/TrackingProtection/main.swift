import Foundation
import Cocoa

let fm = FileManager.default
let fallbackPath: String = (#file as NSString).deletingLastPathComponent + "/../.."
// We expect this command to be executed as 'cd <dir of swift package>; swift run', if not, use the fallback path generated from the path to main.swift. Running from an xcodeproj will use fallbackPath.
let execIsFromCorrectDir = fm.fileExists(atPath: fm.currentDirectoryPath + "/Package.swift")
let rootDir = execIsFromCorrectDir ? fm.currentDirectoryPath : fallbackPath
var output = URL(fileURLWithPath: "\(rootDir)/../Lists")
var lists = [String]()

main()

func main() {
    
    // Do cleanup
    try? fm.removeItem(at: output)
    try? fm.createDirectory(at: output, withIntermediateDirectories: false, attributes: nil)

    parseLists()

    let group = DispatchGroup()
    for list in jsonToLists() {
        group.enter()
        URLSession.shared.dataTask(with: URL(string: list.url)!) { (data, _, _) in
            defer {
                group.leave()
            }
            guard let data = data else { return }
            try! data.createOrAppend(at: output.appendingPathComponent(list.filename))
        }.resume()
        group.wait()
    }
}

func parseLists() {
    let standardLists = try? String(contentsOf: URL(fileURLWithPath: "\(rootDir)/../standard_lists"), encoding: .utf8)
    lists.append(contentsOf: standardLists?.split(separator: "\n").map { String(describing: $0) }.dropLast() ?? [])
    let strictLists = try? String(contentsOf: URL(fileURLWithPath: "\(rootDir)/../strict_lists"), encoding: .utf8)
    lists.append(contentsOf: strictLists?.split(separator: "\n").map { String(describing: $0) }.dropLast() ?? [])
}

func jsonToLists() -> [List] {
    let file = URL(fileURLWithPath: "\(rootDir)/../lists.json")
    let data = try! Data(contentsOf: file)
    let root = try! JSONDecoder().decode(Root.self, from: data)
    
    return root.filters
        .filter { lists.contains($0.name) }
        .reduce(into: [List]()) { $0.append(List(name: $1.name, id: $1.filterID)) }
}

private extension Data {
    func createOrAppend(at url: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: url.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
            fileHandle.closeFile()
        } else {
            try String(data: self, encoding: .utf8)?.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
