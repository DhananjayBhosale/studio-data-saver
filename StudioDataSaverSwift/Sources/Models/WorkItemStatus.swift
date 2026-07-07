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

extension WorkItemStatus {
    var shouldSaveImmediately: Bool {
        switch self {
        case .skippedExisting:
            false
        case .planned, .copying, .staging, .compressing, .done, .skippedNoSpace, .failed, .sourceDeleted, .sourceDeleteFailed:
            true
        }
    }

    var isResumeComplete: Bool {
        switch self {
        case .done, .skippedExisting, .sourceDeleted:
            true
        case .planned, .copying, .staging, .compressing, .skippedNoSpace, .failed, .sourceDeleteFailed:
            false
        }
    }
}
