import SwiftUI

struct TerminalTitleBar: View {
    @Environment(\.colorScheme) private var colorScheme
    var title = "Studio Data Saver - Workspace"

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(Color(red: 0.94, green: 0.35, blue: 0.30))
                .frame(width: 10, height: 10)
            Circle().fill(Color(red: 0.95, green: 0.68, blue: 0.28))
                .frame(width: 10, height: 10)
            Circle().fill(Color(red: 0.35, green: 0.78, blue: 0.38))
                .frame(width: 10, height: 10)
            Text(title)
                .font(StudioTypography.monoCaption)
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                .padding(.leading, 10)
                .lineLimit(1)
            Spacer()
        }
        .frame(height: 32)
        .padding(.horizontal, 12)
        .background(StudioPalette.panel(colorScheme))
    }
}
