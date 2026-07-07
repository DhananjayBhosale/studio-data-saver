import Foundation

struct StudioProject: Codable, Identifiable, Equatable, Sendable {
    var id = UUID()
    var name: String
    var sourcePath: String
    var destinationPath: String
    var workPath: String
    var sourceLocation = SourceLocation.network
    var parallelJobs = 2
    var quality = 30.0
    var exportResolution = ExportResolution.matchOriginal
    var exportFrameRate = ExportFrameRate.matchOriginal
    var sourceCleanupAction = SourceCleanupAction.keepOriginals
    var deleteSourceClutterAfterSave = false
    var deleteWorkCopiesAfterSave = true
    var replaceProblemDestinationFiles = true
    var createdAt = Date.now
    var updatedAt = Date.now

    init(
        id: UUID = UUID(),
        name: String,
        sourcePath: String,
        destinationPath: String,
        workPath: String,
        sourceLocation: SourceLocation = .network,
        parallelJobs: Int = 2,
        quality: Double = 30,
        exportResolution: ExportResolution = .matchOriginal,
        exportFrameRate: ExportFrameRate = .matchOriginal,
        sourceCleanupAction: SourceCleanupAction = .keepOriginals,
        deleteSourceClutterAfterSave: Bool = false,
        deleteWorkCopiesAfterSave: Bool = true,
        replaceProblemDestinationFiles: Bool = true,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
        self.workPath = workPath
        self.sourceLocation = sourceLocation
        self.parallelJobs = parallelJobs
        self.quality = quality
        self.exportResolution = exportResolution
        self.exportFrameRate = exportFrameRate
        self.sourceCleanupAction = sourceCleanupAction
        self.deleteSourceClutterAfterSave = deleteSourceClutterAfterSave
        self.deleteWorkCopiesAfterSave = deleteWorkCopiesAfterSave
        self.replaceProblemDestinationFiles = replaceProblemDestinationFiles
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        sourcePath = try container.decode(String.self, forKey: .sourcePath)
        destinationPath = try container.decode(String.self, forKey: .destinationPath)
        workPath = try container.decode(String.self, forKey: .workPath)
        sourceLocation = try container.decodeIfPresent(SourceLocation.self, forKey: .sourceLocation) ?? .network
        parallelJobs = try container.decodeIfPresent(Int.self, forKey: .parallelJobs) ?? 2
        quality = try container.decodeIfPresent(Double.self, forKey: .quality) ?? 30
        exportResolution = try container.decodeIfPresent(ExportResolution.self, forKey: .exportResolution) ?? .matchOriginal
        exportFrameRate = try container.decodeIfPresent(ExportFrameRate.self, forKey: .exportFrameRate) ?? .matchOriginal
        sourceCleanupAction = try container.decodeIfPresent(SourceCleanupAction.self, forKey: .sourceCleanupAction) ?? .keepOriginals
        deleteSourceClutterAfterSave = try container.decodeIfPresent(Bool.self, forKey: .deleteSourceClutterAfterSave) ?? false
        deleteWorkCopiesAfterSave = try container.decodeIfPresent(Bool.self, forKey: .deleteWorkCopiesAfterSave) ?? true
        replaceProblemDestinationFiles = try container.decodeIfPresent(Bool.self, forKey: .replaceProblemDestinationFiles) ?? true
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? .now
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .now
    }

    var sourceName: String {
        let url = URL(fileURLWithPath: sourcePath)
        return url.lastPathComponent.isEmpty ? name : url.lastPathComponent
    }
}
