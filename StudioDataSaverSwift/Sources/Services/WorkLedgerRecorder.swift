import Foundation

actor WorkLedgerRecorder {
    private let url: URL
    private var ledger: WorkLedger
    private var unsavedChanges = 0
    private var lastSave = Date.distantPast

    init(url: URL, projectID: UUID, runID: UUID, sourceRoot: URL, destinationRoot: URL) throws {
        self.url = url
        if let data = try? Data(contentsOf: url),
           var existing = try? JSONCoding.decoder.decode(WorkLedger.self, from: data) {
            existing.runID = runID
            existing.sourceRoot = sourceRoot.path
            existing.destinationRoot = destinationRoot.path
            existing.updatedAt = .now
            ledger = existing
        } else {
            ledger = WorkLedger(projectID: projectID, runID: runID, sourceRoot: sourceRoot.path, destinationRoot: destinationRoot.path)
        }
    }

    func mergePlan(_ plannedItems: [WorkLedgerItem]) throws {
        let plannedIDs = Set(plannedItems.map(\.id))
        for var item in plannedItems {
            if var existing = ledger.items[item.id] {
                existing.sourcePath = item.sourcePath
                existing.destinationPath = item.destinationPath
                existing.sourceSize = item.sourceSize
                existing.updatedAt = .now
                if existing.status != .done && existing.status != .skippedExisting && existing.status != .sourceDeleted {
                    existing.status = .planned
                    existing.detail = "Ready to continue"
                }
                ledger.items[item.id] = existing
            } else {
                item.status = .planned
                item.detail = "Waiting"
                item.updatedAt = .now
                ledger.items[item.id] = item
            }
        }
        ledger.items = ledger.items.filter { _, value in
            plannedIDs.contains(value.id) || value.status == .sourceDeleted
        }
        try save()
    }

    func resumePlan(directFiles: [PlanItem], videos: [PlanItem]) -> ResumePlan {
        let directRemaining = remainingItems(directFiles, kind: .direct)
        let videoRemaining = remainingItems(videos, kind: .video)
        let directDone = directFiles.count - directRemaining.count
        let videoDone = videos.count - videoRemaining.count
        let completedItems = (directFiles.map { ($0, WorkItemKind.direct) } + videos.map { ($0, WorkItemKind.video) })
            .compactMap { item, kind -> WorkLedgerItem? in
                let id = "\(kind.rawValue):\(item.relativePath)"
                guard let ledgerItem = ledger.items[id], ledgerItem.status.isResumeComplete else { return nil }
                return ledgerItem
            }
        let sourceBytesDone = completedItems.reduce(Int64(0)) { $0 + $1.sourceSize }
        let outputBytesDone = completedItems.reduce(Int64(0)) { $0 + ($1.destinationSize ?? $1.sourceSize) }
        return ResumePlan(
            directFiles: directRemaining,
            videos: videoRemaining,
            directDone: directDone,
            videoDone: videoDone,
            sourceBytesDone: sourceBytesDone,
            outputBytesDone: outputBytesDone
        )
    }

    func mark(
        item: PlanItem,
        kind: WorkItemKind,
        status: WorkItemStatus,
        destination: URL,
        sourceSize: Int64? = nil,
        destinationSize: Int64? = nil,
        detail: String
    ) async {
        var entry = ledger.items["\(kind.rawValue):\(item.relativePath)"] ?? WorkLedgerItem(
            kind: kind,
            sourcePath: item.sourcePath,
            relativePath: item.relativePath,
            destinationPath: destination.path,
            sourceSize: sourceSize ?? 0,
            status: status,
            detail: detail
        )
        entry.sourcePath = item.sourcePath
        entry.destinationPath = destination.path
        if let sourceSize {
            entry.sourceSize = sourceSize
        }
        entry.destinationSize = destinationSize
        entry.status = status
        entry.detail = detail
        entry.updatedAt = .now
        ledger.items[entry.id] = entry
        try? saveIfNeeded(for: status)
    }

    func flush() throws {
        try save()
    }

    private func save() throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        ledger.updatedAt = .now
        let data = try JSONCoding.encoder.encode(ledger)
        try data.write(to: url, options: .atomic)
        unsavedChanges = 0
        lastSave = .now
    }

    private func saveIfNeeded(for status: WorkItemStatus) throws {
        unsavedChanges += 1
        if status.shouldSaveImmediately || unsavedChanges >= 100 || Date.now.timeIntervalSince(lastSave) >= 5 {
            try save()
        }
    }

    private func remainingItems(_ items: [PlanItem], kind: WorkItemKind) -> [PlanItem] {
        items.filter { item in
            let id = "\(kind.rawValue):\(item.relativePath)"
            return ledger.items[id]?.status.isResumeComplete != true
        }
    }
}
