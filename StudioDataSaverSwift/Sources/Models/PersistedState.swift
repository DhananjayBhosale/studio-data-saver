import Foundation

struct PersistedState: Codable, Sendable {
    var projects: [StudioProject] = []
    var runs: [StudioRun] = []
    var queuedProjectIDs: [UUID] = []
    var activeProjectID: UUID?

    init(
        projects: [StudioProject] = [],
        runs: [StudioRun] = [],
        queuedProjectIDs: [UUID] = [],
        activeProjectID: UUID? = nil
    ) {
        self.projects = projects
        self.runs = runs
        self.queuedProjectIDs = queuedProjectIDs
        self.activeProjectID = activeProjectID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        projects = try container.decodeIfPresent([StudioProject].self, forKey: .projects) ?? []
        runs = try container.decodeIfPresent([StudioRun].self, forKey: .runs) ?? []
        queuedProjectIDs = try container.decodeIfPresent([UUID].self, forKey: .queuedProjectIDs) ?? []
        activeProjectID = try container.decodeIfPresent(UUID.self, forKey: .activeProjectID)
    }
}
