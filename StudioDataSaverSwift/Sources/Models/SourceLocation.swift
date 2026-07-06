import Foundation

enum SourceLocation: String, Codable, CaseIterable, Identifiable, Sendable {
    case network = "Network Drive"
    case local = "This Mac"

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "Network Drive", "Network/share":
            self = .network
        case "This Mac", "This machine":
            self = .local
        default:
            self = .network
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
