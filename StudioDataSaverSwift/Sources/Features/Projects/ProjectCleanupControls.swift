import SwiftUI

struct ProjectCleanupControls: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        @Bindable var store = store

        VStack(alignment: .leading, spacing: 10) {
            Label("After Saving", systemImage: "checkmark.seal")
                .font(.callout)
                .bold()
                .foregroundStyle(StudioPalette.primaryText(colorScheme))

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Original files")
                        .font(StudioTypography.monoCaption)
                        .foregroundStyle(StudioPalette.secondaryText(colorScheme))

                    Picker("Original files", selection: $store.selectedSourceCleanupAction) {
                        ForEach(SourceCleanupAction.allCases) { action in
                            Text(action.rawValue).tag(action)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 320)
                    .help("What happens to source files after they are saved.")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Delete previews, ZIPs, autosaves, old project files", isOn: $store.selectedDeleteSourceClutterAfterSave)
                        .toggleStyle(.checkbox)
                        .help("After saving, delete preview/cache folders, ZIP files, Auto Save folders, and .prproj/.aep files outside Project Files folders.")

                    Toggle("Delete iMac temp copies", isOn: $store.selectedDeleteWorkCopiesAfterSave)
                        .toggleStyle(.checkbox)
                        .help("Delete temporary files from the work folder after processing.")

                    Toggle("Replace bad destination files", isOn: $store.selectedReplaceProblemDestinationFiles)
                        .toggleStyle(.checkbox)
                        .help("Replace incomplete or bad destination files when re-running.")
                }
            }

            Text("Destination files stay. Deleting originals or cleanup items always asks first.")
                .font(StudioTypography.monoCaption)
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                .lineLimit(2)
        }
        .padding(12)
        .background(StudioPalette.terminal(colorScheme))
        .clipShape(.rect(cornerRadius: 6))
    }
}
