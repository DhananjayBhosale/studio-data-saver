import Foundation

struct NativeArchiveEngine: Sendable {
    private let finder = ExecutableFinder()
    private let runner = ProcessRunner()

    func run(
        project: StudioProject,
        runID: UUID,
        ledgerURL: URL,
        onEvent: @escaping (RunEvent) async -> Void,
        onProgress: @escaping (EngineProgress) async -> Void
    ) async throws {
        try Task.checkCancellation()

        let sourceRoot = URL(fileURLWithPath: project.sourcePath, isDirectory: true)
        let destinationBase = URL(fileURLWithPath: project.destinationPath, isDirectory: true)
        let workBase = URL(fileURLWithPath: project.workPath, isDirectory: true)
        let destinationRoot = destinationBase.appendingPathComponent(project.sourceName, isDirectory: true)

        try ensureDirectory(destinationRoot)
        try ensureDirectory(workBase)
        try await recoverPartialFiles(in: destinationRoot, runID: runID, onEvent: onEvent)
        try await recoverStaleWorkFolders(in: workBase, currentRunID: runID, onEvent: onEvent)

        await onEvent(RunEvent(runID: runID, type: "plan", path: sourceRoot.path, detail: "Checking files"))
        let plan = try makePlan(sourceRoot: sourceRoot)
        let ledgerItems = makeLedgerItems(plan: plan, destinationRoot: destinationRoot)
        let plannedSourceBytes = ledgerItems.reduce(Int64(0)) { $0 + $1.sourceSize }
        let ledger = try WorkLedgerRecorder(url: ledgerURL, projectID: project.id, runID: runID, sourceRoot: sourceRoot, destinationRoot: destinationRoot)
        try await ledger.mergePlan(ledgerItems)
        await onEvent(RunEvent(runID: runID, type: "plan_ready", path: destinationRoot.path, detail: "\(countText(plan.directFiles.count, "file")), \(countText(plan.videos.count, "video"))"))
        await onEvent(RunEvent(runID: runID, type: "resume_ready", path: ledgerURL.path, detail: "Resume ready"))

        let progress = EngineProgressReporter(sourceBytesTotal: plannedSourceBytes, onProgress: onProgress)
        await onProgress(await progress.current())

        async let directTask: Void = copyDirectFiles(
            plan.directFiles,
            project: project,
            sourceRoot: sourceRoot,
            destinationRoot: destinationRoot,
            ledger: ledger,
            runID: runID,
            onEvent: onEvent,
            onProgress: { update in
                await progress.updateDirect(update)
            }
        )

        async let videoTask: Void = processVideos(
            plan.videos,
            project: project,
            sourceRoot: sourceRoot,
            destinationRoot: destinationRoot,
            workBase: workBase,
            ledger: ledger,
            runID: runID,
            onEvent: onEvent,
            onProgress: { update in
                await progress.updateVideo(update)
            }
        )

        _ = try await (directTask, videoTask)
        await onProgress(await progress.current())
        await onEvent(RunEvent(runID: runID, type: "complete", path: destinationRoot.path, detail: "Project complete"))
    }

    func makePlan(sourceRoot: URL) throws -> Plan {
        var plan = Plan()
        try scan(sourceRoot: sourceRoot, folder: sourceRoot, inProjectFiles: false, plan: &plan)
        return plan
    }

    private func scan(sourceRoot: URL, folder: URL, inProjectFiles: Bool, plan: inout Plan) throws {
        let children = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ).sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }

        for child in children {
            try Task.checkCancellation()
            let values = try child.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true {
                let name = child.lastPathComponent

                if ArchiveRule.isProxiesFolder(name) || ArchiveRule.isAdobeCacheFolder(name) {
                    continue
                }

                if ArchiveRule.isAutoSaveFolder(name) {
                    if inProjectFiles {
                        try addTreeToDirectPlan(sourceRoot: sourceRoot, folder: child, plan: &plan)
                    }
                    continue
                }

                if ArchiveRule.isExportFolder(name) {
                    try addExportsFolder(sourceRoot: sourceRoot, folder: child, plan: &plan)
                    try addExportSubfolders(sourceRoot: sourceRoot, folder: child, inProjectFiles: inProjectFiles, plan: &plan)
                    continue
                }

                let enteringProjectFiles = !inProjectFiles && ArchiveRule.isProjectFilesFolder(name)
                if enteringProjectFiles {
                    try addProjectFilesFolder(sourceRoot: sourceRoot, folder: child, plan: &plan)
                    continue
                }

                try scan(sourceRoot: sourceRoot, folder: child, inProjectFiles: inProjectFiles, plan: &plan)
            } else {
                let ext = child.pathExtension.lowercased()
                if ext == "zip" {
                    continue
                }
                try addFileToPlan(sourceRoot: sourceRoot, file: child, plan: &plan)
            }
        }
    }

    private func addTreeToDirectPlan(sourceRoot: URL, folder: URL, plan: inout Plan) throws {
        let children = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        for child in children {
            try Task.checkCancellation()
            let values = try child.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true {
                try addTreeToDirectPlan(sourceRoot: sourceRoot, folder: child, plan: &plan)
            } else if child.pathExtension.lowercased() != "zip" {
                try addDirectFile(sourceRoot: sourceRoot, file: child, plan: &plan)
            }
        }
    }

    private func addExportsFolder(sourceRoot: URL, folder: URL, plan: inout Plan) throws {
        let files = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ).filter { url in
            (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) != true
        }

        let finals = files.filter { ArchiveRule.isFinalFile($0.lastPathComponent) }
        if let final = finals.sorted(by: newestFirst).first {
            try addDirectFile(sourceRoot: sourceRoot, file: final, plan: &plan)
        } else {
            for file in files where file.pathExtension.lowercased() != "zip" {
                try addFileToPlan(sourceRoot: sourceRoot, file: file, plan: &plan)
            }
        }
    }

    private func addExportSubfolders(sourceRoot: URL, folder: URL, inProjectFiles: Bool, plan: inout Plan) throws {
        let children = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        for child in children {
            let values = try child.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true {
                try scan(sourceRoot: sourceRoot, folder: child, inProjectFiles: inProjectFiles, plan: &plan)
            }
        }
    }

    private func addProjectFilesFolder(sourceRoot: URL, folder: URL, plan: inout Plan) throws {
        var prprojFiles: [URL] = []
        var aepFiles: [URL] = []
        var otherFiles: [URL] = []
        var videoFiles: [URL] = []

        try collectProjectFiles(folder: folder, prprojFiles: &prprojFiles, aepFiles: &aepFiles, otherFiles: &otherFiles, videoFiles: &videoFiles)

        for file in prprojFiles + aepFiles {
            try addDirectFile(sourceRoot: sourceRoot, file: file, plan: &plan)
        }
        for file in otherFiles where file.pathExtension.lowercased() != "zip" {
            try addDirectFile(sourceRoot: sourceRoot, file: file, plan: &plan)
        }
        for file in videoFiles {
            try addVideoFile(sourceRoot: sourceRoot, file: file, plan: &plan)
        }
    }

    private func collectProjectFiles(
        folder: URL,
        prprojFiles: inout [URL],
        aepFiles: inout [URL],
        otherFiles: inout [URL],
        videoFiles: inout [URL]
    ) throws {
        let children = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        for child in children {
            try Task.checkCancellation()
            let values = try child.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true {
                let name = child.lastPathComponent
                if ArchiveRule.isProxiesFolder(name) || ArchiveRule.isAdobeCacheFolder(name) {
                    continue
                }
                if ArchiveRule.isAutoSaveFolder(name) {
                    try addAutoSaveTree(folder: child, otherFiles: &otherFiles)
                    continue
                }
                try collectProjectFiles(folder: child, prprojFiles: &prprojFiles, aepFiles: &aepFiles, otherFiles: &otherFiles, videoFiles: &videoFiles)
            } else {
                let ext = child.pathExtension.lowercased()
                if ext == "prproj" {
                    prprojFiles.append(child)
                } else if ext == "aep" {
                    aepFiles.append(child)
                } else if ArchiveRule.isVideoFile(child) {
                    videoFiles.append(child)
                } else {
                    otherFiles.append(child)
                }
            }
        }
    }

    private func addAutoSaveTree(folder: URL, otherFiles: inout [URL]) throws {
        let children = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        for child in children {
            let values = try child.resourceValues(forKeys: [.isDirectoryKey])
            if values.isDirectory == true {
                try addAutoSaveTree(folder: child, otherFiles: &otherFiles)
            } else if child.pathExtension.lowercased() != "zip" {
                otherFiles.append(child)
            }
        }
    }

    private func addFileToPlan(sourceRoot: URL, file: URL, plan: inout Plan) throws {
        if ArchiveRule.isVideoFile(file) {
            try addVideoFile(sourceRoot: sourceRoot, file: file, plan: &plan)
        } else {
            try addDirectFile(sourceRoot: sourceRoot, file: file, plan: &plan)
        }
    }

    private func addDirectFile(sourceRoot: URL, file: URL, plan: inout Plan) throws {
        plan.directFiles.append(PlanItem(sourcePath: file.path, relativePath: relativePath(from: sourceRoot, to: file)))
    }

    private func addVideoFile(sourceRoot: URL, file: URL, plan: inout Plan) throws {
        plan.videos.append(PlanItem(sourcePath: file.path, relativePath: relativePath(from: sourceRoot, to: file)))
    }

    private func copyDirectFiles(
        _ items: [PlanItem],
        project: StudioProject,
        sourceRoot: URL,
        destinationRoot: URL,
        ledger: WorkLedgerRecorder,
        runID: UUID,
        onEvent: @escaping (RunEvent) async -> Void,
        onProgress: @escaping (WorkProgressUpdate) async -> Void
    ) async throws {
        var done = 0
        var failed = 0

        for item in items {
            try Task.checkCancellation()
            let destination = destinationRoot.appendingPathComponent(item.relativePath, isDirectory: false)
            do {
                let size = try fileSize(item.sourceURL)
                if alreadyCopied(source: item.sourceURL, destination: destination, size: size) {
                    await ledger.mark(item: item, kind: .direct, status: .skippedExisting, destination: destination, sourceSize: size, destinationSize: size, detail: "Already saved")
                    await deleteOriginalIfNeeded(item: item, kind: .direct, project: project, destination: destination, ledger: ledger, runID: runID, onEvent: onEvent)
                    done += 1
                    await onEvent(RunEvent(runID: runID, type: "copy_skip", path: item.relativePath, detail: "Already saved"))
                    await onProgress(WorkProgressUpdate(done: done, failedIncrement: 0, sourceBytesIncrement: size, outputBytesIncrement: size))
                    continue
                }
                if fileExists(destination) && !project.replaceProblemDestinationFiles {
                    await ledger.mark(item: item, kind: .direct, status: .failed, destination: destination, sourceSize: size, detail: "Destination already has a file")
                    failed += 1
                    await onEvent(RunEvent(runID: runID, type: "destination_keep", path: item.relativePath, detail: "Destination already has a file. Kept it."))
                    await onProgress(WorkProgressUpdate(done: done, failedIncrement: 1, sourceBytesIncrement: 0, outputBytesIncrement: 0))
                    continue
                }
                guard hasAvailableSpace(near: destinationRoot, requiredBytes: size) else {
                    await ledger.mark(item: item, kind: .direct, status: .skippedNoSpace, destination: destination, sourceSize: size, detail: "Not enough destination space")
                    failed += 1
                    await onEvent(RunEvent(runID: runID, type: "copy_skip_space", path: item.relativePath, detail: "Not enough destination space"))
                    await onProgress(WorkProgressUpdate(done: done, failedIncrement: 1, sourceBytesIncrement: 0, outputBytesIncrement: 0))
                    continue
                }

                await ledger.mark(item: item, kind: .direct, status: .copying, destination: destination, sourceSize: size, detail: "Saving")
                try copyFileAtomically(from: item.sourceURL, to: destination)
                let destinationSize = try fileSize(destination)
                await ledger.mark(item: item, kind: .direct, status: .done, destination: destination, sourceSize: size, destinationSize: destinationSize, detail: "Saved")
                await deleteOriginalIfNeeded(item: item, kind: .direct, project: project, destination: destination, ledger: ledger, runID: runID, onEvent: onEvent)
                done += 1
                if done == 1 || done % 25 == 0 || done == items.count {
                    await onEvent(RunEvent(runID: runID, type: "copy", path: item.relativePath, detail: "\(done) of \(items.count) files saved"))
                }
                await onProgress(WorkProgressUpdate(done: done, failedIncrement: 0, sourceBytesIncrement: size, outputBytesIncrement: destinationSize))
            } catch {
                await ledger.mark(item: item, kind: .direct, status: .failed, destination: destination, detail: error.localizedDescription)
                failed += 1
                await onEvent(RunEvent(runID: runID, type: "copy_fail", path: item.relativePath, detail: error.localizedDescription))
                await onProgress(WorkProgressUpdate(done: done, failedIncrement: 1, sourceBytesIncrement: 0, outputBytesIncrement: 0))
            }
        }
    }

    private func processVideos(
        _ items: [PlanItem],
        project: StudioProject,
        sourceRoot: URL,
        destinationRoot: URL,
        workBase: URL,
        ledger: WorkLedgerRecorder,
        runID: UUID,
        onEvent: @escaping (RunEvent) async -> Void,
        onProgress: @escaping (WorkProgressUpdate) async -> Void
    ) async throws {
        guard !items.isEmpty else { return }

        let handBrake = try finder.find(["HandBrakeCLI", "handbrakecli"])
        let ffprobe = try? finder.find(["ffprobe"])
        let queue = VideoWorkQueue(items)
        let jobs = max(1, min(project.parallelJobs, items.count))
        let runWorkRoot = workBase.appendingPathComponent("StudioDataSaver-\(runID.uuidString)", isDirectory: true)
        try ensureDirectory(runWorkRoot)

        await onEvent(RunEvent(runID: runID, type: "video_start", path: destinationRoot.path, detail: "Compressing \(jobs) video\(jobs == 1 ? "" : "s") at a time"))

        let counter = VideoProgressCounter()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for workerIndex in 0..<jobs {
                group.addTask {
                    while let item = await queue.next() {
                        try Task.checkCancellation()
                        let result = await compressVideo(
                            item,
                            project: project,
                            sourceRoot: sourceRoot,
                            destinationRoot: destinationRoot,
                            runWorkRoot: runWorkRoot,
                            ledger: ledger,
                            handBrake: handBrake,
                            ffprobe: ffprobe,
                            workerIndex: workerIndex,
                            runID: runID,
                            onEvent: onEvent
                        )
                        await onProgress(await counter.record(result))
                    }
                }
            }

            for try await _ in group {
            }
        }

        if project.deleteWorkCopiesAfterSave {
            try? FileManager.default.removeItem(at: runWorkRoot)
        } else {
            await onEvent(RunEvent(runID: runID, type: "work_keep", path: runWorkRoot.path, detail: "Kept iMac temp copies"))
        }
        await onEvent(RunEvent(runID: runID, type: "video_done", path: destinationRoot.path, detail: "\(countText(items.count, "video")) finished"))
    }

    private func compressVideo(
        _ item: PlanItem,
        project: StudioProject,
        sourceRoot: URL,
        destinationRoot: URL,
        runWorkRoot: URL,
        ledger: WorkLedgerRecorder,
        handBrake: String,
        ffprobe: String?,
        workerIndex: Int,
        runID: UUID,
        onEvent: @escaping (RunEvent) async -> Void
    ) async -> VideoWorkResult {
        let destination = finalVideoURL(for: item, destinationRoot: destinationRoot)
        let tempDestination = destination.deletingLastPathComponent()
            .appendingPathComponent(".\(destination.lastPathComponent).tmp_compressed.mp4")

        do {
            try ensureDirectory(destination.deletingLastPathComponent())
            let size = try fileSize(item.sourceURL)

            if destinationExistsAndLooksUsable(source: item.sourceURL, destination: destination, ffprobe: ffprobe) {
                let destinationSize = (try? fileSize(destination)) ?? 0
                await ledger.mark(item: item, kind: .video, status: .skippedExisting, destination: destination, sourceSize: size, destinationSize: destinationSize, detail: "Already saved")
                await deleteOriginalIfNeeded(item: item, kind: .video, project: project, destination: destination, ledger: ledger, runID: runID, onEvent: onEvent)
                await onEvent(RunEvent(runID: runID, type: "video_skip", path: item.relativePath, detail: "Already saved"))
                return .completed(sourceBytes: size, outputBytes: destinationSize)
            }
            if fileExists(destination) && !project.replaceProblemDestinationFiles {
                await ledger.mark(item: item, kind: .video, status: .failed, destination: destination, sourceSize: size, detail: "Destination already has a file")
                await onEvent(RunEvent(runID: runID, type: "destination_keep", path: item.relativePath, detail: "Destination already has a file. Kept it."))
                return .failed()
            }

            guard hasAvailableSpace(near: destinationRoot, requiredBytes: max(size / 2, 512 * 1024 * 1024)) else {
                await ledger.mark(item: item, kind: .video, status: .skippedNoSpace, destination: destination, sourceSize: size, detail: "Not enough destination space")
                await onEvent(RunEvent(runID: runID, type: "video_skip_space", path: item.relativePath, detail: "Not enough destination space"))
                return .failed()
            }

            let handbrakeSource: URL
            if project.sourceLocation == .network {
                guard hasAvailableSpace(near: runWorkRoot, requiredBytes: size + 512 * 1024 * 1024) else {
                    await ledger.mark(item: item, kind: .video, status: .skippedNoSpace, destination: destination, sourceSize: size, detail: "Not enough iMac space")
                    await onEvent(RunEvent(runID: runID, type: "stage_skip_space", path: item.relativePath, detail: "Not enough iMac space for this video"))
                    return .failed()
                }
                let staged = runWorkRoot
                    .appendingPathComponent("worker-\(workerIndex)", isDirectory: true)
                    .appendingPathComponent(item.relativePath, isDirectory: false)
                try? FileManager.default.removeItem(at: staged)
                await ledger.mark(item: item, kind: .video, status: .staging, destination: destination, sourceSize: size, detail: "Copying video to iMac")
                try copyFileAtomically(from: item.sourceURL, to: staged)
                handbrakeSource = staged
                await onEvent(RunEvent(runID: runID, type: "stage", path: item.relativePath, detail: "Copied video to iMac"))
            } else {
                handbrakeSource = item.sourceURL
            }

            try? FileManager.default.removeItem(at: tempDestination)
            await ledger.mark(item: item, kind: .video, status: .compressing, destination: destination, sourceSize: size, detail: "Compressing")
            await onEvent(RunEvent(runID: runID, type: "encode_start", path: item.relativePath, detail: "Encoding video"))
            var arguments = [
                "-i", handbrakeSource.path,
                "-o", tempDestination.path,
                "--encoder", "x265",
                "--quality", project.quality.formatted(.number.precision(.fractionLength(1))),
                "--format", "av_mp4",
                "--crop-mode", "none"
            ]
            arguments.append(contentsOf: resolutionArguments(for: project.exportResolution, source: handbrakeSource, ffprobe: ffprobe))
            arguments.append(contentsOf: project.exportFrameRate.handBrakeArguments)
            let status = await runner.run(
                handBrake,
                arguments: arguments,
                watchdog: ProcessWatchdog(
                    monitoredFile: tempDestination,
                    warningAfterSeconds: 10 * 60,
                    stopAfterSeconds: 30 * 60
                ),
                onWatchdogEvent: { event in
                    switch event {
                    case .warning(let inactiveSeconds, let cpuPercent):
                        await onEvent(RunEvent(
                            runID: runID,
                            type: "handbrake_stall",
                            path: item.relativePath,
                            detail: "HandBrake looks stuck: low CPU\(cpuText(cpuPercent)) and no output change for \(minutesText(inactiveSeconds))"
                        ))
                    case .stopped(let inactiveSeconds, let cpuPercent):
                        await onEvent(RunEvent(
                            runID: runID,
                            type: "handbrake_stopped",
                            path: item.relativePath,
                            detail: "Stopped frozen HandBrake job after \(minutesText(inactiveSeconds)) with low CPU\(cpuText(cpuPercent))"
                        ))
                    }
                }
            )

            if project.sourceLocation == .network && project.deleteWorkCopiesAfterSave {
                try? FileManager.default.removeItem(at: handbrakeSource)
            }

            guard status == 0, fileExists(tempDestination), (try? fileSize(tempDestination)) ?? 0 > 0 else {
                try? FileManager.default.removeItem(at: tempDestination)
                await ledger.mark(item: item, kind: .video, status: .failed, destination: destination, sourceSize: size, detail: "Compression failed")
                await onEvent(RunEvent(runID: runID, type: "video_fail", path: item.relativePath, detail: "Compression failed"))
                return .failed()
            }

            if !durationLooksValid(source: item.sourceURL, destination: tempDestination, ffprobe: ffprobe) {
                try? FileManager.default.removeItem(at: tempDestination)
                await ledger.mark(item: item, kind: .video, status: .failed, destination: destination, sourceSize: size, detail: "Saved video did not pass check")
                await onEvent(RunEvent(runID: runID, type: "video_fail", path: item.relativePath, detail: "Saved video did not pass check"))
                return .failed()
            }

            if fileExists(destination) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: tempDestination, to: destination)
            let destinationSize = try fileSize(destination)
            await ledger.mark(item: item, kind: .video, status: .done, destination: destination, sourceSize: size, destinationSize: destinationSize, detail: "Saved")
            await deleteOriginalIfNeeded(item: item, kind: .video, project: project, destination: destination, ledger: ledger, runID: runID, onEvent: onEvent)
            await onEvent(RunEvent(runID: runID, type: "video", path: item.relativePath, detail: "Saved as \(destination.lastPathComponent)"))
            return .completed(sourceBytes: size, outputBytes: destinationSize)
        } catch {
            try? FileManager.default.removeItem(at: tempDestination)
            await ledger.mark(item: item, kind: .video, status: .failed, destination: destination, detail: error.localizedDescription)
            await onEvent(RunEvent(runID: runID, type: "video_fail", path: item.relativePath, detail: error.localizedDescription))
            return .failed()
        }
    }

    private func recoverPartialFiles(
        in folder: URL,
        runID: UUID,
        onEvent: @escaping (RunEvent) async -> Void
    ) async throws {
        let subpaths = (try? FileManager.default.subpathsOfDirectory(atPath: folder.path)) ?? []
        for subpath in subpaths where subpath.hasSuffix(".tmp_compressed.mp4") || URL(fileURLWithPath: subpath).lastPathComponent.contains(".copying-") {
            let url = folder.appendingPathComponent(subpath)
            try? FileManager.default.removeItem(at: url)
            await onEvent(RunEvent(runID: runID, type: "cleanup", path: url.path, detail: "Removed unfinished file"))
        }
    }

    private func recoverStaleWorkFolders(
        in folder: URL,
        currentRunID: UUID,
        onEvent: @escaping (RunEvent) async -> Void
    ) async throws {
        let currentName = "StudioDataSaver-\(currentRunID.uuidString)"
        let children = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isDirectoryKey])) ?? []
        for child in children where child.lastPathComponent.hasPrefix("StudioDataSaver-") && child.lastPathComponent != currentName {
            try? FileManager.default.removeItem(at: child)
            await onEvent(RunEvent(runID: currentRunID, type: "cleanup", path: child.path, detail: "Cleaned old iMac temp files"))
        }
    }

    private func deleteOriginalIfNeeded(
        item: PlanItem,
        kind: WorkItemKind,
        project: StudioProject,
        destination: URL,
        ledger: WorkLedgerRecorder,
        runID: UUID,
        onEvent: @escaping (RunEvent) async -> Void
    ) async {
        guard project.sourceCleanupAction == .deleteAfterSaved else { return }
        guard item.sourceURL.standardizedFileURL.path != destination.standardizedFileURL.path else { return }
        guard fileExists(item.sourceURL) else { return }

        do {
            let sourceSize = (try? fileSize(item.sourceURL)) ?? 0
            let destinationSize = try? fileSize(destination)
            try FileManager.default.removeItem(at: item.sourceURL)
            await ledger.mark(
                item: item,
                kind: kind,
                status: .sourceDeleted,
                destination: destination,
                sourceSize: sourceSize,
                destinationSize: destinationSize,
                detail: "Original deleted after saving"
            )
            await onEvent(RunEvent(runID: runID, type: "source_delete", path: item.relativePath, detail: "Deleted original after saving"))
        } catch {
            await ledger.mark(
                item: item,
                kind: kind,
                status: .sourceDeleteFailed,
                destination: destination,
                detail: error.localizedDescription
            )
            await onEvent(RunEvent(runID: runID, type: "source_delete_fail", path: item.relativePath, detail: error.localizedDescription))
        }
    }

    private func makeLedgerItems(plan: Plan, destinationRoot: URL) -> [WorkLedgerItem] {
        let directItems = plan.directFiles.map { item in
            WorkLedgerItem(
                kind: .direct,
                sourcePath: item.sourcePath,
                relativePath: item.relativePath,
                destinationPath: destinationRoot.appendingPathComponent(item.relativePath).path,
                sourceSize: (try? fileSize(item.sourceURL)) ?? 0,
                status: .planned,
                detail: "Waiting"
            )
        }
        let videoItems = plan.videos.map { item in
            WorkLedgerItem(
                kind: .video,
                sourcePath: item.sourcePath,
                relativePath: item.relativePath,
                destinationPath: finalVideoURL(for: item, destinationRoot: destinationRoot).path,
                sourceSize: (try? fileSize(item.sourceURL)) ?? 0,
                status: .planned,
                detail: "Waiting"
            )
        }
        return directItems + videoItems
    }

    private func finalVideoURL(for item: PlanItem, destinationRoot: URL) -> URL {
        let source = item.sourceURL
        let sourceExtension = source.pathExtension.lowercased()
        let baseName = source.deletingPathExtension().lastPathComponent
        let relativeDirectory = (item.relativePath as NSString).deletingLastPathComponent
        let destinationFolder = relativeDirectory.isEmpty || relativeDirectory == "."
            ? destinationRoot
            : destinationRoot.appendingPathComponent(relativeDirectory, isDirectory: true)
        let defaultName = "\(baseName).mp4"

        if sourceExtension != "mp4", hasSiblingVideoConflict(source) {
            return destinationFolder.appendingPathComponent("\(baseName)_\(sourceExtension.isEmpty ? "video" : sourceExtension).mp4", isDirectory: false)
        }
        return destinationFolder.appendingPathComponent(defaultName, isDirectory: false)
    }

    private func hasSiblingVideoConflict(_ source: URL) -> Bool {
        let folder = source.deletingLastPathComponent()
        guard let siblings = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return false
        }
        let stem = source.deletingPathExtension().lastPathComponent
        return siblings.contains { sibling in
            sibling != source
                && sibling.deletingPathExtension().lastPathComponent == stem
                && ArchiveRule.isVideoFile(sibling)
        }
    }

    private func destinationExistsAndLooksUsable(source: URL, destination: URL, ffprobe: String?) -> Bool {
        guard fileExists(destination), ((try? fileSize(destination)) ?? 0) > 0 else {
            return false
        }
        return durationLooksValid(source: source, destination: destination, ffprobe: ffprobe)
    }

    private func durationLooksValid(source: URL, destination: URL, ffprobe: String?) -> Bool {
        guard let ffprobe else { return true }
        let sourceDuration = duration(url: source, ffprobe: ffprobe)
        let destinationDuration = duration(url: destination, ffprobe: ffprobe)
        guard let sourceDuration, let destinationDuration else { return true }
        return abs(sourceDuration - destinationDuration) <= 1.5
    }

    private func duration(url: URL, ffprobe: String) -> Double? {
        let output = runner.capture(ffprobe, arguments: [
            "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            url.path
        ])
        return Double(output.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func resolutionArguments(for resolution: ExportResolution, source: URL, ffprobe: String?) -> [String] {
        switch resolution {
        case .matchOriginal:
            return []
        case .p1080:
            return targetResolutionArguments(width: 1920, height: 1080, source: source, ffprobe: ffprobe)
        case .p4K:
            return targetResolutionArguments(width: 3840, height: 2160, source: source, ffprobe: ffprobe)
        }
    }

    private func targetResolutionArguments(width: Int, height: Int, source: URL, ffprobe: String?) -> [String] {
        guard let dimensions = videoDimensions(url: source, ffprobe: ffprobe) else {
            return ["--maxWidth", "\(width)", "--maxHeight", "\(height)"]
        }

        if dimensions.width >= dimensions.height {
            return ["--height", "\(height)", "--keep-display-aspect"]
        }
        return ["--width", "\(height)", "--keep-display-aspect"]
    }

    private func videoDimensions(url: URL, ffprobe: String?) -> (width: Int, height: Int)? {
        guard let ffprobe else { return nil }
        let output = runner.capture(ffprobe, arguments: [
            "-v", "error",
            "-select_streams", "v:0",
            "-show_entries", "stream=width,height",
            "-of", "csv=p=0:s=x",
            url.path
        ])
        let parts = output.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "x")
        guard parts.count == 2,
              let width = Int(parts[0]),
              let height = Int(parts[1]) else {
            return nil
        }
        return (width, height)
    }

    private func alreadyCopied(source: URL, destination: URL, size: Int64) -> Bool {
        guard fileExists(destination), let destinationSize = try? fileSize(destination) else {
            return false
        }
        return destinationSize == size
            && source.lastPathComponent == destination.lastPathComponent
            && filesMatch(source: source, destination: destination, expectedSize: size)
    }

    private func filesMatch(source: URL, destination: URL, expectedSize: Int64) -> Bool {
        guard let sourceHandle = try? FileHandle(forReadingFrom: source),
              let destinationHandle = try? FileHandle(forReadingFrom: destination) else {
            return false
        }
        defer {
            try? sourceHandle.close()
            try? destinationHandle.close()
        }

        let chunkSize = 8 * 1024 * 1024
        var remaining = expectedSize
        while remaining > 0 {
            let readSize = min(chunkSize, Int(remaining))
            let sourceChunk = sourceHandle.readData(ofLength: readSize)
            let destinationChunk = destinationHandle.readData(ofLength: readSize)
            if sourceChunk.count != readSize || sourceChunk != destinationChunk {
                return false
            }
            remaining -= Int64(readSize)
        }

        return true
    }

    private func copyFileAtomically(from source: URL, to destination: URL) throws {
        try ensureDirectory(destination.deletingLastPathComponent())
        let temp = destination.deletingLastPathComponent()
            .appendingPathComponent(".\(destination.lastPathComponent).copying-\(UUID().uuidString)")
        try? FileManager.default.removeItem(at: temp)
        try FileManager.default.copyItem(at: source, to: temp)
        if fileExists(destination) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: temp, to: destination)
    }

    private func hasAvailableSpace(near url: URL, requiredBytes: Int64) -> Bool {
        let folder = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        guard let available = availableSpace(near: folder) else {
            return true
        }
        return available > requiredBytes
    }

    private func availableSpace(near folder: URL) -> Int64? {
        guard let values = try? folder.resourceValues(forKeys: [
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeAvailableCapacityForOpportunisticUsageKey,
            .volumeAvailableCapacityKey
        ]) else {
            return nil
        }

        let options = [
            values.volumeAvailableCapacityForImportantUsage,
            values.volumeAvailableCapacityForOpportunisticUsage,
            values.volumeAvailableCapacity.map(Int64.init)
        ].compactMap { $0 }.filter { $0 > 0 }

        return options.max()
    }

    private func ensureDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func fileExists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    private func fileSize(_ url: URL) throws -> Int64 {
        let values = try url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(values.fileSize ?? 0)
    }

    private func countText(_ count: Int, _ word: String) -> String {
        "\(count) \(word)\(count == 1 ? "" : "s")"
    }

    private func minutesText(_ seconds: TimeInterval) -> String {
        let minutes = max(1, Int(seconds / 60))
        return "\(minutes) minute\(minutes == 1 ? "" : "s")"
    }

    private func cpuText(_ cpuPercent: Double?) -> String {
        guard let cpuPercent else { return "" }
        return " (\(cpuPercent.formatted(.number.precision(.fractionLength(1))))%)"
    }

    private func relativePath(from root: URL, to file: URL) -> String {
        let rootPath = root.standardizedFileURL.path
        let filePath = file.standardizedFileURL.path
        if filePath.hasPrefix(rootPath + "/") {
            return String(filePath.dropFirst(rootPath.count + 1))
        }
        return file.lastPathComponent
    }

    private func newestFirst(_ lhs: URL, _ rhs: URL) -> Bool {
        let left = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
        let right = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
        return left > right
    }
}
