import Foundation

struct WorkLedger: Codable, Sendable {
    var schema = 1
    var projectID: UUID
    var runID: UUID
    var sourceRoot: String
    var destinationRoot: String
    var createdAt = Date.now
    var updatedAt = Date.now
    var items: [String: WorkLedgerItem] = [:]
}
