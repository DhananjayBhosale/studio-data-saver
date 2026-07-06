import SwiftUI

struct SettingChip: View {
    @Environment(\.colorScheme) private var colorScheme
    var icon: String
    var text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(StudioTypography.monoCaption)
            .foregroundStyle(StudioPalette.secondaryText(colorScheme))
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(StudioPalette.terminal(colorScheme))
            .clipShape(.rect(cornerRadius: 6))
            .lineLimit(1)
    }
}
