import SwiftUI

struct ProjectCommandBand: View {
    @Environment(StudioStore.self) private var store
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            Text(">")
                .font(StudioTypography.monoCallout)
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))

            Text("Selected project")
                .font(StudioTypography.monoCallout)
                .foregroundStyle(StudioPalette.primaryText(colorScheme))

            Spacer()

            Button(store.selectedProjectActionTitle, systemImage: store.selectedProjectActionIcon, action: store.addSelectedToQueue)
                .buttonStyle(StudioButtonStyle(role: .primary, compact: true))

            Button(store.allProjectsActionTitle, systemImage: store.allProjectsActionIcon, action: store.queueAllProjects)
                .buttonStyle(StudioButtonStyle(compact: true))

            if store.isRunning {
                Button("Stop", systemImage: "stop.fill", action: store.stopQueue)
                    .buttonStyle(StudioButtonStyle(role: .destructive, compact: true))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(StudioPalette.commandBand(colorScheme))
        .clipShape(.rect(cornerRadius: 6))
    }
}
