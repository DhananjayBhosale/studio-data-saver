import SwiftUI

struct ProjectHeaderView: View {
    @Environment(StudioStore.self) private var store

    var body: some View {
        TerminalBox(title: "Studio Data Saver - Workspace") {
            VStack(alignment: .leading, spacing: 14) {
                ProjectMetadataBlock()

                if !store.lastNotice.isEmpty {
                    TerminalLine(prefix: "WARN", message: store.lastNotice, tint: StudioPalette.warning)
                }
            }
            .padding(StudioMetric.gutter)
        }
    }
}
