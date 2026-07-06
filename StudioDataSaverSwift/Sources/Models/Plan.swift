import Foundation

struct Plan: Codable, Sendable {
    var directFiles: [PlanItem] = []
    var videos: [PlanItem] = []
}
