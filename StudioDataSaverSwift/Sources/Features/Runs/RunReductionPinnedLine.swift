import SwiftUI

struct RunReductionPinnedLine: View {
    @Environment(\.colorScheme) private var colorScheme
    var run: StudioRun?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("SAVED")
                .font(StudioTypography.monoCallout)
                .foregroundStyle(StudioPalette.accent)
                .accessibilityHidden(true)

            Text(run?.reductionLine ?? "No files saved yet")
                .font(StudioTypography.monoCallout)
                .foregroundStyle(StudioPalette.primaryText(colorScheme))
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)

            Spacer()
        }
        .padding(.horizontal, StudioMetric.gutter)
        .padding(.vertical, 10)
        .background(StudioPalette.commandBand(colorScheme))
        .accessibilityElement(children: .combine)
    }
}
