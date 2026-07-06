import Foundation

struct ExecutableFinder: Sendable {
    func find(_ candidates: [String]) throws -> String {
        for candidate in candidates {
            if candidate.contains("/"), FileManager.default.isExecutableFile(atPath: candidate) {
                return candidate
            }

            if !candidate.contains("/") {
                for folder in searchFolders {
                    let path = "\(folder)/\(candidate)"
                    if FileManager.default.isExecutableFile(atPath: path) {
                        return path
                    }
                }
            }
        }

        throw StudioError.message("Required tool not found: \(candidates.first ?? "tool")")
    }

    private var searchFolders: [String] {
        ["/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin", "/usr/sbin", "/sbin"]
    }
}
