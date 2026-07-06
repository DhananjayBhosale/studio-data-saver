import Foundation

actor VideoProgressCounter {
    private var done = 0
    private var failures = 0

    func record(_ result: VideoWorkResult) -> WorkProgressUpdate {
        done += 1
        if result.success {
            return WorkProgressUpdate(
                done: done,
                failedIncrement: 0,
                sourceBytesIncrement: result.sourceBytes,
                outputBytesIncrement: result.outputBytes
            )
        }
        failures += 1
        return WorkProgressUpdate(done: done, failedIncrement: 1, sourceBytesIncrement: 0, outputBytesIncrement: 0)
    }
}
