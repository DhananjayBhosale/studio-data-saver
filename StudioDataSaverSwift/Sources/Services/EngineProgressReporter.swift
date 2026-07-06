import Foundation

actor EngineProgressReporter {
    private var directDone = 0
    private var videoDone = 0
    private var failures = 0
    private let sourceBytesTotal: Int64
    private var sourceBytesDone: Int64 = 0
    private var outputBytesDone: Int64 = 0
    private let onProgress: (EngineProgress) async -> Void

    init(sourceBytesTotal: Int64, onProgress: @escaping (EngineProgress) async -> Void) {
        self.sourceBytesTotal = sourceBytesTotal
        self.onProgress = onProgress
    }

    func updateDirect(_ update: WorkProgressUpdate) async {
        directDone = update.done
        failures += update.failedIncrement
        sourceBytesDone += update.sourceBytesIncrement
        outputBytesDone += update.outputBytesIncrement
        await emit()
    }

    func updateVideo(_ update: WorkProgressUpdate) async {
        videoDone = update.done
        failures += update.failedIncrement
        sourceBytesDone += update.sourceBytesIncrement
        outputBytesDone += update.outputBytesIncrement
        await emit()
    }

    func current() async -> EngineProgress {
        EngineProgress(
            directDone: directDone,
            videoDone: videoDone,
            failures: failures,
            sourceBytesTotal: sourceBytesTotal,
            sourceBytesDone: sourceBytesDone,
            outputBytesDone: outputBytesDone
        )
    }

    private func emit() async {
        await onProgress(await current())
    }
}
