import Foundation

enum ExportResolution: String, Codable, CaseIterable, Identifiable, Sendable {
    case matchOriginal = "Match original"
    case p1080 = "1080p"
    case p4K = "4K"

    var id: String { rawValue }

    var summary: String {
        switch self {
        case .matchOriginal:
            "Same resolution"
        case .p1080:
            "Convert to 1080p"
        case .p4K:
            "Upscale to 4K"
        }
    }
}
