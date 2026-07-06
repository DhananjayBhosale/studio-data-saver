import SwiftUI

struct ProjectMetadataBlock: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var nameFocused: Bool

    var body: some View {
        @Bindable var store = store

        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(">")
                        .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                    TextField("Project name", text: $store.selectedProjectName)
                        .textFieldStyle(.plain)
                        .font(StudioTypography.monoBody)
                        .bold()
                        .foregroundStyle(StudioPalette.primaryText(colorScheme))
                        .focused($nameFocused)
                }

                MetadataLine(label: "Source", value: store.selectedProject?.sourcePath.isEmpty == false ? store.selectedProject?.sourcePath ?? "" : "Choose a source folder")
                MetadataLine(label: "Work", value: "\(store.selectedSourceLocation.rawValue) / \(store.selectedParallelJobs) video\(store.selectedParallelJobs == 1 ? "" : "s") at a time")
                MetadataLine(label: "Export", value: "\(store.selectedExportResolution.summary) / \(store.selectedExportFrameRate.rawValue) / Compression \(Int(store.selectedQuality.rounded()))")
                MetadataLine(label: "After Saving", value: store.selectedSourceCleanupAction.rawValue)
                MetadataLine(label: "Save To", value: store.selectedDestinationPath.isEmpty ? "Choose a destination folder" : store.selectedDestinationPath)
            }
            .padding(12)
            .background(StudioPalette.terminal(colorScheme))
            .overlay(alignment: .topLeading) {
                Rectangle()
                    .stroke(StudioPalette.border(colorScheme), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                StatusPill(text: store.isRunning ? RunStatus.running.rawValue : "Ready", tint: store.isRunning ? StudioPalette.accent : StudioPalette.cyan)
                Text("Apple Silicon")
                    .font(StudioTypography.monoCaption)
                    .foregroundStyle(StudioPalette.secondaryText(colorScheme))
            }
        }
        .task {
            nameFocused = false
        }
    }
}
