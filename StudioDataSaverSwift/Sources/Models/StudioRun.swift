import Foundation

struct StudioRun: Codable, Identifiable, Equatable, Sendable {
    var id = UUID()
    var projectID: UUID
    var projectName: String
    var status = RunStatus.queued
    var startedAt = Date.now
    var finishedAt: Date?
    var destinationPath: String
    var directFiles = 0
    var videoFiles = 0
    var directDone = 0
    var videoDone = 0
    var failures = 0
    var sourceBytesTotal: Int64 = 0
    var sourceBytesDone: Int64 = 0
    var outputBytesDone: Int64 = 0

    init(
        id: UUID = UUID(),
        projectID: UUID,
        projectName: String,
        status: RunStatus = .queued,
        startedAt: Date = .now,
        finishedAt: Date? = nil,
        destinationPath: String,
        directFiles: Int = 0,
        videoFiles: Int = 0,
        directDone: Int = 0,
        videoDone: Int = 0,
        failures: Int = 0,
        sourceBytesTotal: Int64 = 0,
        sourceBytesDone: Int64 = 0,
        outputBytesDone: Int64 = 0
    ) {
        self.id = id
        self.projectID = projectID
        self.projectName = projectName
        self.status = status
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.destinationPath = destinationPath
        self.directFiles = directFiles
        self.videoFiles = videoFiles
        self.directDone = directDone
        self.videoDone = videoDone
        self.failures = failures
        self.sourceBytesTotal = sourceBytesTotal
        self.sourceBytesDone = sourceBytesDone
        self.outputBytesDone = outputBytesDone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        projectID = try container.decode(UUID.self, forKey: .projectID)
        projectName = try container.decode(String.self, forKey: .projectName)
        status = try container.decodeIfPresent(RunStatus.self, forKey: .status) ?? .queued
        startedAt = try container.decodeIfPresent(Date.self, forKey: .startedAt) ?? .now
        finishedAt = try container.decodeIfPresent(Date.self, forKey: .finishedAt)
        destinationPath = try container.decode(String.self, forKey: .destinationPath)
        directFiles = try container.decodeIfPresent(Int.self, forKey: .directFiles) ?? 0
        videoFiles = try container.decodeIfPresent(Int.self, forKey: .videoFiles) ?? 0
        directDone = try container.decodeIfPresent(Int.self, forKey: .directDone) ?? 0
        videoDone = try container.decodeIfPresent(Int.self, forKey: .videoDone) ?? 0
        failures = try container.decodeIfPresent(Int.self, forKey: .failures) ?? 0
        sourceBytesTotal = try container.decodeIfPresent(Int64.self, forKey: .sourceBytesTotal) ?? 0
        sourceBytesDone = try container.decodeIfPresent(Int64.self, forKey: .sourceBytesDone) ?? 0
        outputBytesDone = try container.decodeIfPresent(Int64.self, forKey: .outputBytesDone) ?? 0
    }
}
