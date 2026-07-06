import SwiftUI

struct ProjectSettingsView: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        @Bindable var store = store

        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Picker("Source", selection: $store.selectedSourceLocation) {
                    ForEach(SourceLocation.allCases) { location in
                        Text(location.rawValue).tag(location)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)

                Stepper(value: $store.selectedParallelJobs, in: 1...4) {
                    Label("\(store.selectedParallelJobs) video\(store.selectedParallelJobs == 1 ? "" : "s") at a time", systemImage: "rectangle.stack")
                }
                .font(.callout)

                Spacer()
            }

            ProjectExportControls()

            PathPickerRow(title: "Source", icon: "folder", text: $store.selectedSourcePath) {
                store.pickFolder(for: .source)
            }
            PathPickerRow(title: "Destination", icon: "externaldrive", text: $store.selectedDestinationPath) {
                store.pickFolder(for: .destination)
            }
            PathPickerRow(title: "iMac Work Folder", icon: "internaldrive", text: $store.selectedWorkPath) {
                store.pickFolder(for: .work)
            }

            ProjectCleanupControls()

            HStack(spacing: 8) {
                SettingChip(icon: "list.clipboard", text: "Can resume")
                SettingChip(icon: "doc.on.doc", text: "Copies while compressing")
                SettingChip(icon: "bolt.horizontal", text: "Uses less iMac space")
                SettingChip(icon: "shippingbox", text: "Project files saved")
            }

            ProjectCommandBand()
        }
        .padding(StudioMetric.gutter)
        .background(StudioPalette.panel(colorScheme))
        .clipShape(.rect(cornerRadius: StudioMetric.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: StudioMetric.cornerRadius)
                .stroke(StudioPalette.border(colorScheme), lineWidth: 1)
        }
    }
}
