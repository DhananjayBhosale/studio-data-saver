import SwiftUI

struct TerminalLine: View {
    @Environment(\.colorScheme) private var colorScheme
    var prefix: String
    var message: String
    var tint = StudioPalette.secondaryText(.dark)

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(prefix)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(message)
                .foregroundStyle(StudioPalette.primaryText(colorScheme))
                .textSelection(.enabled)
        }
        .font(StudioTypography.monoCallout)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
