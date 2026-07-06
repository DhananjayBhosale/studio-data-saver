import SwiftUI

struct RunListView: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("Runs", systemImage: "clock")
                    .font(.headline)
                    .foregroundStyle(StudioPalette.primaryText(colorScheme))
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal, StudioMetric.gutter)
            .padding(.bottom, StudioMetric.compactGutter)

            if store.runs.isEmpty {
                RunsEmptyState()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(store.runs) { run in
                            Button {
                                store.selectedRunID = run.id
                            } label: {
                                RunSummaryRow(run: run)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                }
            }
        }
        .background(StudioPalette.sidebar(colorScheme))
    }
}
