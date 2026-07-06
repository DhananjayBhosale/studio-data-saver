import SwiftUI

struct ProjectExportControls: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme
    @State private var isEditing = false

    var body: some View {
        @Bindable var store = store

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Export", systemImage: "slider.horizontal.3")
                    .font(.callout)
                    .bold()
                    .foregroundStyle(StudioPalette.primaryText(colorScheme))

                Spacer()

                Button(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark" : "slider.horizontal.3", action: toggleEditing)
                    .buttonStyle(StudioButtonStyle(compact: true))
            }

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Compression \(compressionText)")
                        .font(StudioTypography.monoBody)
                        .bold()
                        .foregroundStyle(StudioPalette.primaryText(colorScheme))
                    Text(compressionMeaning)
                        .font(StudioTypography.monoCaption)
                        .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                }
                .frame(width: 190, alignment: .leading)

                VStack(alignment: .leading, spacing: 6) {
                    Slider(value: $store.selectedQuality, in: 18...40, step: 0.5)
                        .help("Move left for better quality. Move right for smaller files.")

                    HStack {
                        Text("Best quality")
                        Spacer()
                        Text("Smallest files")
                    }
                    .font(StudioTypography.monoCaption)
                    .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                }
            }

            HStack(spacing: 8) {
                Label(store.selectedExportResolution.summary, systemImage: "rectangle.inset.filled")
                Label(store.selectedExportFrameRate.rawValue, systemImage: "speedometer")
            }
            .font(StudioTypography.monoCaption)
            .foregroundStyle(StudioPalette.secondaryText(colorScheme))

            if isEditing {
                Divider()
                    .overlay(StudioPalette.border(colorScheme))

                Button("Match Original Video", systemImage: "arrow.triangle.2.circlepath", action: store.matchOriginalExportSettings)
                    .buttonStyle(StudioButtonStyle(role: .primary, compact: true))

                Picker("Resolution", selection: $store.selectedExportResolution) {
                    ForEach(ExportResolution.allCases) { resolution in
                        Text(resolution.rawValue).tag(resolution)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Frame Rate", selection: $store.selectedExportFrameRate) {
                    ForEach(ExportFrameRate.allCases) { frameRate in
                        Text(frameRate.rawValue).tag(frameRate)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(12)
        .background(StudioPalette.terminal(colorScheme))
        .clipShape(.rect(cornerRadius: 6))
    }

    private var compressionText: String {
        if store.selectedQuality.rounded() == store.selectedQuality {
            return "\(Int(store.selectedQuality))"
        }
        return store.selectedQuality.formatted(.number.precision(.fractionLength(1)))
    }

    private var compressionMeaning: String {
        switch store.selectedQuality {
        case ...23:
            "Light compression, biggest files"
        case ...28:
            "Balanced quality and size"
        case 29...31:
            "Good starting point"
        case ...34:
            "More space saving"
        default:
            "Strong compression, lower quality"
        }
    }

    private func toggleEditing() {
        isEditing.toggle()
    }
}
