import SwiftUI

struct ConsoleEmptyState: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TerminalLine(prefix: "INFO", message: "Waiting for a project to start", tint: StudioPalette.secondaryText(colorScheme))
            TerminalLine(prefix: "INFO", message: "Progress and saved space will appear here", tint: StudioPalette.secondaryText(colorScheme))
            TerminalLine(prefix: "INFO", message: "If the Mac restarts, the app can continue remaining files", tint: StudioPalette.secondaryText(colorScheme))
            Spacer()
        }
        .padding(StudioMetric.gutter)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
