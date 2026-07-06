import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            ProjectSidebar()
                .frame(width: StudioMetric.sidebarWidth)

            Divider()
                .overlay(StudioPalette.border(colorScheme))

            ProjectWorkspaceView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .overlay(StudioPalette.border(colorScheme))

            RunListView()
                .frame(width: StudioMetric.runsWidth)
        }
        .background(StudioPalette.appBackground(colorScheme))
    }
}
