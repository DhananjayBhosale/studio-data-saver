import Foundation

enum SourceCleanupAction: String, Codable, CaseIterable, Identifiable, Sendable {
    case keepOriginals = "Keep originals"
    case deleteAfterSaved = "Delete after save"

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "Delete after save", "Delete after saved":
            self = .deleteAfterSaved
        default:
            self = .keepOriginals
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
