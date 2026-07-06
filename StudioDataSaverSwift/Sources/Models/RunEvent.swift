import Foundation

struct RunEvent: Codable, Sendable {
    var at = Date.now
    var runID: UUID
    var type: String
    var path: String
    var detail: String
}
