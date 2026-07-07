import Darwin
import Foundation

struct ProcessWatchdog: Sendable {
    var monitoredFile: URL
    var warningAfterSeconds: TimeInterval
    var stopAfterSeconds: TimeInterval
    var minimumCPUPercent: Double = 5
    var pollSeconds: UInt64 = 30
}

enum ProcessWatchdogEvent: Sendable {
    case warning(inactiveSeconds: TimeInterval, cpuPercent: Double?)
    case stopped(inactiveSeconds: TimeInterval, cpuPercent: Double?)
}

struct ProcessRunner: Sendable {
    func run(_ executable: String, arguments: [String]) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus
        } catch {
            return -1
        }
    }

    func run(
        _ executable: String,
        arguments: [String],
        watchdog: ProcessWatchdog,
        onWatchdogEvent: @escaping @Sendable (ProcessWatchdogEvent) async -> Void
    ) async -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            return -1
        }

        let watchdogTask = Task {
            await watch(process: process, watchdog: watchdog, onWatchdogEvent: onWatchdogEvent)
        }
        process.waitUntilExit()
        watchdogTask.cancel()
        return process.terminationStatus
    }

    func capture(_ executable: String, arguments: [String]) -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self)
        } catch {
            return ""
        }
    }

    private func watch(
        process: Process,
        watchdog: ProcessWatchdog,
        onWatchdogEvent: @escaping @Sendable (ProcessWatchdogEvent) async -> Void
    ) async {
        var lastSize = fileSize(watchdog.monitoredFile)
        var lastHealthy = Date.now
        var sentWarning = false

        while !Task.isCancelled, process.isRunning {
            try? await Task.sleep(for: .seconds(watchdog.pollSeconds))
            guard !Task.isCancelled, process.isRunning else { break }

            let currentSize = fileSize(watchdog.monitoredFile)
            let currentCPU = cpuPercent(processID: process.processIdentifier)
            let isUsingCPU = (currentCPU ?? 0) >= watchdog.minimumCPUPercent
            if currentSize != lastSize || isUsingCPU {
                lastSize = currentSize
                lastHealthy = .now
                sentWarning = false
                continue
            }

            let inactiveSeconds = Date.now.timeIntervalSince(lastHealthy)
            if !sentWarning, inactiveSeconds >= watchdog.warningAfterSeconds {
                sentWarning = true
                await onWatchdogEvent(.warning(inactiveSeconds: inactiveSeconds, cpuPercent: currentCPU))
            }

            if inactiveSeconds >= watchdog.stopAfterSeconds {
                await onWatchdogEvent(.stopped(inactiveSeconds: inactiveSeconds, cpuPercent: currentCPU))
                process.terminate()
                try? await Task.sleep(for: .seconds(5))
                if process.isRunning {
                    kill(process.processIdentifier, SIGKILL)
                }
                break
            }
        }
    }

    private func fileSize(_ url: URL) -> Int64 {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(values?.fileSize ?? 0)
    }

    private func cpuPercent(processID: Int32) -> Double? {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-p", "\(processID)", "-o", "%cpu="]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let text = String(decoding: data, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return Double(text)
        } catch {
            return nil
        }
    }
}
