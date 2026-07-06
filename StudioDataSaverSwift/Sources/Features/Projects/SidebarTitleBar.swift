import SwiftUI

struct SidebarTitleBar: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            Text("Project Queue")
                .font(StudioTypography.monoCaption)
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))
            Spacer()
            Image(systemName: "sidebar.leading")
                .font(.callout)
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                .accessibilityHidden(true)
        }
        .frame(height: 48)
        .padding(.horizontal, StudioMetric.gutter)
        .background(StudioPalette.sidebar(colorScheme))
    }
}
