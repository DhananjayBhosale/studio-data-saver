import SwiftUI

struct ProjectWorkspaceView: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: StudioMetric.gutter) {
            if store.selectedProject == nil {
                ContentUnavailableView("No Project Selected", systemImage: "folder.badge.questionmark")
            } else {
                ProjectHeaderView()
                ProjectSettingsView()
                RunConsoleView()
            }
        }
        .padding(StudioMetric.gutter)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(StudioPalette.appBackground(colorScheme))
    }
}
