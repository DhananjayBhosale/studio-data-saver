import SwiftUI

struct RunConsoleView: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TerminalBox(title: "Studio Data Saver - Run Log") {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Label(store.selectedRun?.projectName ?? "Console", systemImage: "terminal")
                        .font(.callout)
                        .bold()
                        .foregroundStyle(StudioPalette.primaryText(colorScheme))
                    Spacer()
                    if let run = store.selectedRun {
                        StatusPill(text: run.status.rawValue, tint: run.status.tint(colorScheme))
                    }
                }
                .padding(StudioMetric.gutter)

                Divider()
                    .overlay(StudioPalette.border(colorScheme))

                RunReductionPinnedLine(run: store.selectedRun)
                Divider()
                    .overlay(StudioPalette.border(colorScheme))

                if store.selectedRunEvents.isEmpty {
                    ConsoleEmptyState()
                } else {
                    RunEventList(events: store.selectedRunEvents)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
