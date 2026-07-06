import Foundation

enum ExportFrameRate: String, Codable, CaseIterable, Identifiable, Sendable {
    case matchOriginal = "Match original"
    case fps24 = "24 fps"
    case fps30 = "30 fps"
    case fps60 = "60 fps"

    var id: String { rawValue }

    var handBrakeArguments: [String] {
        switch self {
        case .matchOriginal:
            ["--vfr"]
        case .fps24:
            ["--rate", "24", "--pfr"]
        case .fps30:
            ["--rate", "30", "--pfr"]
        case .fps60:
            ["--rate", "60", "--pfr"]
        }
    }
}
