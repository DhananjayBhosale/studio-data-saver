import Foundation

extension StudioRun {
    var savedBytes: Int64 {
        max(0, sourceBytesDone - outputBytesDone)
    }

    var reductionPercent: Double {
        guard sourceBytesDone > 0 else { return 0 }
        return Double(savedBytes) / Double(sourceBytesDone) * 100
    }

    var reductionLine: String {
        let total = ByteCountText.format(sourceBytesTotal)
        guard sourceBytesDone > 0 else {
            return "No files saved yet - planned \(total)"
        }

        let processed = ByteCountText.format(sourceBytesDone)
        let output = ByteCountText.format(outputBytesDone)
        let saved = ByteCountText.format(savedBytes)
        let percent = reductionPercent.formatted(.number.precision(.fractionLength(1)))

        if sourceBytesDone >= sourceBytesTotal, sourceBytesTotal > 0 {
            return "\(processed) -> \(output) - saved \(saved) (\(percent)%)"
        }

        return "\(processed) of \(total) -> \(output) - saved \(saved) (\(percent)%)"
    }
}
