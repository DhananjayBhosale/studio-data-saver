import Foundation

struct ResumePlan: Sendable {
    var directFiles: [PlanItem]
    var videos: [PlanItem]
    var directDone: Int
    var videoDone: Int
    var sourceBytesDone: Int64
    var outputBytesDone: Int64
}
