import Foundation

struct EngineProgress: Sendable {
    var directDone: Int
    var videoDone: Int
    var failures: Int
    var sourceBytesTotal: Int64 = 0
    var sourceBytesDone: Int64 = 0
    var outputBytesDone: Int64 = 0

    var savedBytes: Int64 {
        max(0, sourceBytesDone - outputBytesDone)
    }
}
