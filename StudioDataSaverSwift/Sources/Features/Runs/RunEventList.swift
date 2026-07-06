import SwiftUI

struct RunEventList: View {
    var events: [RunEvent]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                        TerminalLine(prefix: event.typeLabel, message: event.consoleMessage, tint: event.tint)
                            .id(index)
                    }
                }
                .padding(StudioMetric.gutter)
            }
            .onChange(of: events.count) { _, count in
                guard count > 0 else { return }
                withAnimation(.easeOut(duration: 0.18)) {
                    proxy.scrollTo(count - 1, anchor: .bottom)
                }
            }
        }
    }
}
