import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class StudioStore {
    var projects: [StudioProject] = []
    var runs: [StudioRun] = []
    var selectedProjectID: UUID?
    var selectedRunID: UUID?
    var eventsByRun: [UUID: [RunEvent]] = [:]
    var queuedProjectIDs: [UUID] = []
    var activeProjectID: UUID?
    var isRunning = false
    var lastNotice = ""

    private let paths = AppPaths.live
    private let engine = NativeArchiveEngine()
    private var workerTask: Task<Void, Never>?

    init() {
        load()
        if projects.isEmpty {
            addProject()
        } else if selectedProjectID == nil {
            selectedProjectID = projects.first?.id
        }
        selectedRunID = runs.first?.id
        recoverInterruptedWork()
    }

    var selectedProjectName: String {
        get { selectedProject?.name ?? "" }
        set { updateSelectedProject { $0.name = newValue } }
    }

    var selectedSourcePath: String {
        get { selectedProject?.sourcePath ?? "" }
        set { updateSelectedProject { $0.sourcePath = newValue } }
    }

    var selectedDestinationPath: String {
        get { selectedProject?.destinationPath ?? "" }
        set { updateSelectedProject { $0.destinationPath = newValue } }
    }

    var selectedWorkPath: String {
        get { selectedProject?.workPath ?? "" }
        set { updateSelectedProject { $0.workPath = newValue } }
    }

    var selectedSourceLocation: SourceLocation {
        get { selectedProject?.sourceLocation ?? .network }
        set { updateSelectedProject { $0.sourceLocation = newValue } }
    }

    var selectedParallelJobs: Int {
        get { selectedProject?.parallelJobs ?? 2 }
        set { updateSelectedProject { $0.parallelJobs = min(4, max(1, newValue)) } }
    }

    var selectedQuality: Double {
        get { selectedProject?.quality ?? 30 }
        set { updateSelectedProject { $0.quality = min(40, max(18, newValue)) } }
    }

    var selectedExportResolution: ExportResolution {
        get { selectedProject?.exportResolution ?? .matchOriginal }
        set { updateSelectedProject { $0.exportResolution = newValue } }
    }

    var selectedExportFrameRate: ExportFrameRate {
        get { selectedProject?.exportFrameRate ?? .matchOriginal }
        set { updateSelectedProject { $0.exportFrameRate = newValue } }
    }

    var selectedSourceCleanupAction: SourceCleanupAction {
        get { selectedProject?.sourceCleanupAction ?? .keepOriginals }
        set { updateSelectedProject { $0.sourceCleanupAction = newValue } }
    }

    var selectedDeleteSourceClutterAfterSave: Bool {
        get { selectedProject?.deleteSourceClutterAfterSave ?? false }
        set { updateSelectedProject { $0.deleteSourceClutterAfterSave = newValue } }
    }

    var selectedDeleteWorkCopiesAfterSave: Bool {
        get { selectedProject?.deleteWorkCopiesAfterSave ?? true }
        set { updateSelectedProject { $0.deleteWorkCopiesAfterSave = newValue } }
    }

    var selectedReplaceProblemDestinationFiles: Bool {
        get { selectedProject?.replaceProblemDestinationFiles ?? true }
        set { updateSelectedProject { $0.replaceProblemDestinationFiles = newValue } }
    }

    var selectedProject: StudioProject? {
        guard let selectedProjectID else { return nil }
        return projects.first { $0.id == selectedProjectID }
    }

    var selectedRun: StudioRun? {
        guard let selectedRunID else { return runs.first }
        return runs.first { $0.id == selectedRunID }
    }

    var selectedRunEvents: [RunEvent] {
        guard let run = selectedRun else { return [] }
        return eventsByRun[run.id, default: []]
    }

    var queueCountText: String {
        queuedProjectIDs.isEmpty ? "Queue empty" : "\(queuedProjectIDs.count) queued"
    }

    var selectedProjectActionTitle: String {
        isRunning || !queuedProjectIDs.isEmpty ? "Queue" : "Start"
    }

    var selectedProjectActionIcon: String {
        isRunning || !queuedProjectIDs.isEmpty ? "text.badge.plus" : "play.fill"
    }

    var allProjectsActionTitle: String {
        isRunning || !queuedProjectIDs.isEmpty ? "Queue All" : "Start All"
    }

    var allProjectsActionIcon: String {
        isRunning || !queuedProjectIDs.isEmpty ? "list.bullet.rectangle" : "play.fill"
    }

    func addProject() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let project = StudioProject(
            name: "New Project",
            sourcePath: "",
            destinationPath: home.appendingPathComponent("Desktop").path,
            workPath: home.appendingPathComponent("Studio Data Saver Work", isDirectory: true).path
        )
        projects.insert(project, at: 0)
        selectedProjectID = project.id
        save()
    }

    func duplicateSelectedProject() {
        guard var project = selectedProject else { return }
        project.id = UUID()
        project.name += " Copy"
        project.createdAt = .now
        project.updatedAt = .now
        projects.insert(project, at: 0)
        selectedProjectID = project.id
        save()
    }

    func removeSelectedProject() {
        guard let selectedProjectID else { return }
        projects.removeAll { $0.id == selectedProjectID }
        queuedProjectIDs.removeAll { $0 == selectedProjectID }
        self.selectedProjectID = projects.first?.id
        save()
    }

    func pickFolder(for field: PathField) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        if panel.runModal() == .OK, let url = panel.url {
            switch field {
            case .source:
                selectedSourcePath = url.path
                if selectedProjectName == "New Project" || selectedProjectName.isEmpty {
                    selectedProjectName = url.lastPathComponent
                }
            case .destination:
                selectedDestinationPath = url.path
            case .work:
                selectedWorkPath = url.path
            }
        }
    }

    func addSelectedToQueue() {
        guard let project = selectedProject, validate(project: project) else { return }
        if !queuedProjectIDs.contains(project.id) {
            queuedProjectIDs.append(project.id)
        }
        save()
        startQueue()
    }

    func queueAllProjects() {
        for project in projects where validate(project: project) {
            if !queuedProjectIDs.contains(project.id) {
                queuedProjectIDs.append(project.id)
            }
        }
        save()
        startQueue()
    }

    func stopQueue() {
        workerTask?.cancel()
        workerTask = nil
        isRunning = false
        lastNotice = "Stopping after the current file"
        save()
    }

    func events(for run: StudioRun) -> [RunEvent] {
        eventsByRun[run.id, default: []]
    }

    func matchOriginalExportSettings() {
        updateSelectedProject { project in
            project.exportResolution = .matchOriginal
            project.exportFrameRate = .matchOriginal
        }
    }

    private func startQueue() {
        guard workerTask == nil else { return }
        isRunning = true
        workerTask = Task { [weak self] in
            await self?.processQueue()
        }
    }

    private func processQueue() async {
        defer {
            workerTask = nil
            isRunning = false
        }

        while !Task.isCancelled, let nextID = queuedProjectIDs.first {
            queuedProjectIDs.removeFirst()
            save()
            guard let project = projects.first(where: { $0.id == nextID }) else {
                continue
            }
            guard validate(project: project) else {
                continue
            }
            guard let runProject = destructiveCleanupApprovedProject(project) else {
                continue
            }
            activeProjectID = project.id
            save()
            await run(project: runProject)
        }
    }

    private func destructiveCleanupApprovedProject(_ project: StudioProject) -> StudioProject? {
        var runProject = project

        if project.sourceCleanupAction == .deleteAfterSaved {
            let alert = NSAlert()
            alert.messageText = "Delete originals after saving?"
            alert.informativeText = "Files are deleted from the source folder only after they are safely saved to the destination."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Delete Originals")
            alert.addButton(withTitle: "Keep Originals")
            alert.addButton(withTitle: "Skip Project")

            switch alert.runModal() {
            case .alertFirstButtonReturn:
                break
            case .alertSecondButtonReturn:
                runProject.sourceCleanupAction = .keepOriginals
            default:
                lastNotice = "Skipped \(project.name)"
                return nil
            }
        }

        if project.deleteSourceClutterAfterSave {
            let alert = NSAlert()
            alert.messageText = "Delete source cleanup items after saving?"
            alert.informativeText = "This removes ZIP files, Auto Save folders, and Premiere/After Effects project files outside Project Files folders from the source folder."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Delete Cleanup Items")
            alert.addButton(withTitle: "Keep Cleanup Items")
            alert.addButton(withTitle: "Skip Project")

            switch alert.runModal() {
            case .alertFirstButtonReturn:
                break
            case .alertSecondButtonReturn:
                runProject.deleteSourceClutterAfterSave = false
            default:
                lastNotice = "Skipped \(project.name)"
                return nil
            }
        }

        return runProject
    }

    private func run(project: StudioProject) async {
        var run = StudioRun(projectID: project.id, projectName: project.name, status: .running, destinationPath: project.destinationPath)
        runs.insert(run, at: 0)
        selectedRunID = run.id
        eventsByRun[run.id] = []
        save()
        defer {
            if activeProjectID == project.id {
                activeProjectID = nil
            }
            save()
        }

        do {
            try await engine.run(
                project: project,
                runID: run.id,
                ledgerURL: paths.ledgerURL(for: project.id),
                onEvent: { [weak self] event in
                    await self?.record(event)
                },
                onProgress: { [weak self] progress in
                    await MainActor.run {
                        self?.updateRun(run.id) { storedRun in
                            storedRun.directDone = progress.directDone
                            storedRun.videoDone = progress.videoDone
                            storedRun.failures = progress.failures
                            storedRun.sourceBytesTotal = progress.sourceBytesTotal
                            storedRun.sourceBytesDone = progress.sourceBytesDone
                            storedRun.outputBytesDone = progress.outputBytesDone
                        }
                    }
                }
            )
            run.status = .complete
            run.finishedAt = .now
            updateRun(run.id) { storedRun in
                storedRun.status = .complete
                storedRun.finishedAt = .now
            }
        } catch is CancellationError {
            updateRun(run.id) { storedRun in
                storedRun.status = .stopped
                storedRun.finishedAt = .now
            }
            await record(RunEvent(runID: run.id, type: "stopped", path: project.sourcePath, detail: "Stopped"))
        } catch {
            updateRun(run.id) { storedRun in
                storedRun.status = .failed
                storedRun.finishedAt = .now
                storedRun.failures += 1
            }
            await record(RunEvent(runID: run.id, type: "error", path: project.sourcePath, detail: error.localizedDescription))
        }
        save()
    }

    private func record(_ event: RunEvent) async {
        eventsByRun[event.runID, default: []].append(event)
        appendEventToDisk(event)
        if event.type == "plan_ready" {
            updateRun(event.runID) { run in
                let counts = event.detail
                    .split(separator: ",")
                    .map(String.init)
                if let direct = counts.first?.split(separator: " ").first.flatMap({ Int($0) }) {
                    run.directFiles = direct
                }
                if counts.count > 1,
                   let videos = counts[1].trimmingCharacters(in: .whitespaces).split(separator: " ").first.flatMap({ Int($0) }) {
                    run.videoFiles = videos
                }
            }
        }
    }

    private func updateRun(_ id: UUID, mutate: (inout StudioRun) -> Void) {
        guard let index = runs.firstIndex(where: { $0.id == id }) else { return }
        mutate(&runs[index])
        save()
    }

    private func updateSelectedProject(_ mutate: (inout StudioProject) -> Void) {
        guard let selectedProjectID,
              let index = projects.firstIndex(where: { $0.id == selectedProjectID }) else { return }
        mutate(&projects[index])
        projects[index].updatedAt = .now
        save()
    }

    private func validate(project: StudioProject) -> Bool {
        guard !project.sourcePath.isEmpty, FileManager.default.fileExists(atPath: project.sourcePath) else {
            lastNotice = "Choose a source folder first"
            return false
        }
        guard !project.destinationPath.isEmpty else {
            lastNotice = "Choose a destination folder first"
            return false
        }
        guard !project.workPath.isEmpty else {
            lastNotice = "Choose an iMac work folder first"
            return false
        }
        return true
    }

    private func load() {
        do {
            try FileManager.default.createDirectory(at: paths.supportURL, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: paths.runsURL, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: paths.ledgersURL, withIntermediateDirectories: true)
            guard FileManager.default.fileExists(atPath: paths.stateURL.path) else { return }
            let data = try Data(contentsOf: paths.stateURL)
            let state = try JSONCoding.decoder.decode(PersistedState.self, from: data)
            projects = state.projects
            runs = state.runs
            queuedProjectIDs = state.queuedProjectIDs
            activeProjectID = state.activeProjectID
            loadRunEvents()
        } catch {
            lastNotice = error.localizedDescription
        }
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(at: paths.supportURL, withIntermediateDirectories: true)
            let state = PersistedState(projects: projects, runs: Array(runs.prefix(50)), queuedProjectIDs: queuedProjectIDs, activeProjectID: activeProjectID)
            let data = try JSONCoding.encoder.encode(state)
            try data.write(to: paths.stateURL, options: .atomic)
        } catch {
            lastNotice = error.localizedDescription
        }
    }

    private func appendEventToDisk(_ event: RunEvent) {
        do {
            let folder = paths.runsURL.appendingPathComponent(event.runID.uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let line = try JSONCoding.encoder.encode(event)
            let file = folder.appendingPathComponent("events.jsonl")
            if !FileManager.default.fileExists(atPath: file.path) {
                FileManager.default.createFile(atPath: file.path, contents: nil)
            }
            let handle = try FileHandle(forWritingTo: file)
            try handle.seekToEnd()
            try handle.write(contentsOf: line)
            try handle.write(contentsOf: Data("\n".utf8))
            try handle.close()
        } catch {
            lastNotice = error.localizedDescription
        }
    }

    private func loadRunEvents() {
        for run in runs.prefix(20) {
            let file = paths.runsURL
                .appendingPathComponent(run.id.uuidString, isDirectory: true)
                .appendingPathComponent("events.jsonl")
            guard let text = try? String(contentsOf: file, encoding: .utf8) else { continue }
            eventsByRun[run.id] = text
                .split(separator: "\n")
                .compactMap { line in
                    try? JSONCoding.decoder.decode(RunEvent.self, from: Data(line.utf8))
            }
        }
    }

    private func recoverInterruptedWork() {
        var changed = false
        for index in runs.indices where runs[index].status == .running {
            runs[index].status = .stopped
            runs[index].finishedAt = .now
            changed = true
        }

        if let activeProjectID,
           !queuedProjectIDs.contains(activeProjectID),
           let project = projects.first(where: { $0.id == activeProjectID }),
           validate(project: project) {
            queuedProjectIDs.insert(activeProjectID, at: 0)
            lastNotice = "Recovered and queued \(project.name)"
            changed = true
        }

        if changed {
            save()
        }
        if !queuedProjectIDs.isEmpty {
            startQueue()
        }
    }
}
