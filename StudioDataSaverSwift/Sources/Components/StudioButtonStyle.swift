import SwiftUI

struct StudioButtonStyle: ButtonStyle {
    enum Role {
        case primary
        case secondary
        case destructive
    }

    var role = Role.secondary
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .bold(role == .primary)
            .padding(.horizontal, compact ? StudioMetric.compactGutter : StudioMetric.gutter)
            .padding(.vertical, compact ? 7 : 10)
            .foregroundStyle(foreground)
            .background(background.opacity(configuration.isPressed ? 0.72 : 1))
            .clipShape(.rect(cornerRadius: StudioMetric.cornerRadius))
    }

    private var background: Color {
        switch role {
        case .primary:
            StudioPalette.accent
        case .secondary:
            StudioPalette.selectedPanel(.dark)
        case .destructive:
            StudioPalette.danger
        }
    }

    private var foreground: Color {
        switch role {
        case .primary:
            .black
        case .secondary, .destructive:
            .white
        }
    }
}
