import SwiftUI

struct RunsEmptyState: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TerminalLine(prefix: "RUN", message: "No runs yet", tint: StudioPalette.secondaryText(colorScheme))
            TerminalLine(prefix: "RUN", message: "Add a project to the queue", tint: StudioPalette.secondaryText(colorScheme))
            Spacer()
        }
        .padding(StudioMetric.gutter)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
