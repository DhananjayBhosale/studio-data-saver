import SwiftUI

struct RunSummaryRow: View {
    @Environment(\.colorScheme) private var colorScheme
    var run: StudioRun

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(run.projectName)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(StudioPalette.primaryText(colorScheme))
                    .lineLimit(1)
                Spacer()
                StatusPill(text: run.status.rawValue, tint: run.status.tint(colorScheme))
            }

            HStack(spacing: 10) {
                Label("\(run.directDone)/\(run.directFiles)", systemImage: "doc")
                Label("\(run.videoDone)/\(run.videoFiles)", systemImage: "video")
                if run.failures > 0 {
                    Label("\(run.failures)", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(StudioPalette.warning)
                }
            }
            .font(StudioTypography.monoCaption)
            .foregroundStyle(StudioPalette.secondaryText(colorScheme))

            Text(run.startedAt.formatted(date: .abbreviated, time: .shortened))
                .font(StudioTypography.monoCaption)
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))
        }
        .padding(.vertical, 9)
    }

}
