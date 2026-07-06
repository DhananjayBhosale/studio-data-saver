import Foundation

struct VideoWorkResult: Sendable {
    var success: Bool
    var sourceBytes: Int64
    var outputBytes: Int64

    static func failed() -> VideoWorkResult {
        VideoWorkResult(success: false, sourceBytes: 0, outputBytes: 0)
    }

    static func completed(sourceBytes: Int64, outputBytes: Int64) -> VideoWorkResult {
        VideoWorkResult(success: true, sourceBytes: sourceBytes, outputBytes: outputBytes)
    }
}
