import SwiftUI

struct StatusPill: View {
    var text: String
    var tint: Color

    var body: some View {
        Label(text, systemImage: symbolName)
            .labelStyle(.titleAndIcon)
            .font(StudioTypography.monoCaption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.16))
            .foregroundStyle(tint)
            .clipShape(.rect(cornerRadius: 6))
            .accessibilityLabel(text)
    }

    private var symbolName: String {
        switch text {
        case RunStatus.complete.rawValue:
            "checkmark.circle.fill"
        case RunStatus.failed.rawValue:
            "xmark.circle.fill"
        case RunStatus.running.rawValue:
            "play.circle.fill"
        case RunStatus.stopped.rawValue:
            "pause.circle.fill"
        default:
            "circle"
        }
    }
}
