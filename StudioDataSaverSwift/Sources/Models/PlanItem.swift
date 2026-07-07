import Foundation

struct PlanItem: Codable, Sendable {
    var sourcePath: String
    var relativePath: String
    var sourceSize: Int64?

    var sourceURL: URL {
        URL(filePath: sourcePath, directoryHint: .notDirectory)
    }
}
