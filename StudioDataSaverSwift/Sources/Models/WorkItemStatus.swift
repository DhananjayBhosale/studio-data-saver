import Foundation

enum WorkItemStatus: String, Codable, Sendable {
    case planned
    case copying
    case staging
    case compressing
    case done
    case skippedExisting
    case skippedNoSpace
    case failed
    case sourceDeleted
    case sourceDeleteFailed
}
