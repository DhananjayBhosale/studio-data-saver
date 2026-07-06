import SwiftUI

struct ProjectList: View {
    @Environment(StudioStore.self) private var store

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(store.projects) { project in
                    Button {
                        store.selectedProjectID = project.id
                    } label: {
                        ProjectSidebarRow(
                            project: project,
                            selected: store.selectedProjectID == project.id,
                            queued: store.queuedProjectIDs.contains(project.id)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
    }
}
