import Foundation

struct WorkLedgerItem: Codable, Identifiable, Sendable {
    var kind: WorkItemKind
    var sourcePath: String
    var relativePath: String
    var destinationPath: String
    var sourceSize: Int64
    var destinationSize: Int64?
    var status: WorkItemStatus
    var detail: String
    var updatedAt = Date.now

    var id: String {
        "\(kind.rawValue):\(relativePath)"
    }
}
