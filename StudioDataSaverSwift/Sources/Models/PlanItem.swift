import Foundation

struct PlanItem: Codable, Sendable {
    var sourcePath: String
    var relativePath: String

    var sourceURL: URL {
        URL(filePath: sourcePath, directoryHint: .notDirectory)
    }
}
