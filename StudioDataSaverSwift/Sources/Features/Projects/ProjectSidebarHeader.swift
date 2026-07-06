import SwiftUI

struct ProjectSidebarHeader: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Studio Data Saver")
                        .font(.headline)
                        .foregroundStyle(StudioPalette.primaryText(colorScheme))
                    Text(store.queueCountText)
                        .font(StudioTypography.monoCaption)
                        .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                }
                Spacer()
                Button("New Project", systemImage: "plus", action: store.addProject)
                    .labelStyle(.iconOnly)
                    .buttonStyle(StudioButtonStyle(compact: true))
                    .help("New project")
            }

            HStack(spacing: 8) {
                Button(store.selectedProjectActionTitle, systemImage: store.selectedProjectActionIcon, action: store.addSelectedToQueue)
                    .buttonStyle(StudioButtonStyle(role: .primary, compact: true))
                    .disabled(store.selectedProject == nil)

                Button(store.allProjectsActionTitle, systemImage: store.allProjectsActionIcon, action: store.queueAllProjects)
                    .labelStyle(.iconOnly)
                    .buttonStyle(StudioButtonStyle(compact: true))
                    .help(store.allProjectsActionTitle)
            }
        }
        .padding(StudioMetric.gutter)
    }
}
