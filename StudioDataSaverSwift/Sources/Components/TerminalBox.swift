import SwiftUI

struct TerminalBox<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var title = "Studio Data Saver - Workspace"
    var showsTitleBar = true
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsTitleBar {
                TerminalTitleBar(title: title)
            }
            content
        }
        .background(StudioPalette.terminal(colorScheme))
        .clipShape(.rect(cornerRadius: StudioMetric.terminalRadius))
        .overlay {
            RoundedRectangle(cornerRadius: StudioMetric.terminalRadius)
                .stroke(StudioPalette.border(colorScheme), lineWidth: 1)
        }
    }
}
