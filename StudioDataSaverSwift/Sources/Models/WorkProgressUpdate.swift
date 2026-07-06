import Foundation

struct WorkProgressUpdate: Sendable {
    var done: Int
    var failedIncrement: Int
    var sourceBytesIncrement: Int64
    var outputBytesIncrement: Int64
}
