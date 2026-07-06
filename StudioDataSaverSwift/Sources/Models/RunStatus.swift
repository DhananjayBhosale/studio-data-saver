import Foundation

enum RunStatus: String, Codable, CaseIterable, Sendable {
    case queued = "Queued"
    case running = "Running"
    case failed = "Failed"
    case complete = "Complete"
    case stopped = "Stopped"
}
