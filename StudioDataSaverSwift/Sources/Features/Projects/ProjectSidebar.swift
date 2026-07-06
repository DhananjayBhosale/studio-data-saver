import SwiftUI

struct ProjectSidebar: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            SidebarTitleBar()
            ProjectSidebarHeader()
            ProjectList()
            ProjectSidebarFooter()
        }
        .background(StudioPalette.sidebar(colorScheme))
    }
}
