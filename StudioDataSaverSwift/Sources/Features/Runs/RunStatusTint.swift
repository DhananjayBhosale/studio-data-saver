import SwiftUI

extension RunStatus {
    func tint(_ colorScheme: ColorScheme) -> Color {
        switch self {
        case .complete:
            StudioPalette.accent
        case .failed:
            StudioPalette.danger
        case .running:
            StudioPalette.cyan
        case .stopped:
            StudioPalette.warning
        case .queued:
            StudioPalette.secondaryText(colorScheme)
        }
    }
}
