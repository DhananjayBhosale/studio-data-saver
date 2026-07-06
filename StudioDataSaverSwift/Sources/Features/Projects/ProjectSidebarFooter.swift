import SwiftUI

struct ProjectSidebarFooter: View {
    @Environment(StudioStore.self) private var store

    var body: some View {
        HStack(spacing: 8) {
            Button("Duplicate", systemImage: "plus.square.on.square", action: store.duplicateSelectedProject)
                .labelStyle(.iconOnly)
                .buttonStyle(StudioButtonStyle(compact: true))
                .help("Duplicate project")
                .disabled(store.selectedProject == nil)

            Button("Delete", systemImage: "trash", action: store.removeSelectedProject)
                .labelStyle(.iconOnly)
                .buttonStyle(StudioButtonStyle(role: .destructive, compact: true))
                .help("Delete project")
                .disabled(store.selectedProject == nil)

            Spacer()

            if store.isRunning {
                Button("Stop", systemImage: "stop.fill", action: store.stopQueue)
                    .buttonStyle(StudioButtonStyle(role: .destructive, compact: true))
            }
        }
        .padding(StudioMetric.gutter)
    }
}
