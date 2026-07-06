import Foundation

struct AppPaths: Sendable {
    let supportURL: URL
    let stateURL: URL
    let runsURL: URL
    let ledgersURL: URL

    static var live: AppPaths {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.homeDirectoryForCurrentUser
        let support = base.appendingPathComponent("Studio Data Saver", isDirectory: true)
        return AppPaths(
            supportURL: support,
            stateURL: support.appendingPathComponent("projects.json"),
            runsURL: support.appendingPathComponent("runs", isDirectory: true),
            ledgersURL: support.appendingPathComponent("ledgers", isDirectory: true)
        )
    }

    func ledgerURL(for projectID: UUID) -> URL {
        ledgersURL.appendingPathComponent("\(projectID.uuidString).json")
    }
}
