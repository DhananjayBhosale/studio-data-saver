import Foundation

enum StudioError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let value):
            value
        }
    }
}
