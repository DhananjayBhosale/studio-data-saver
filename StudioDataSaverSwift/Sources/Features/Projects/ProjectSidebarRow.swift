import SwiftUI

struct ProjectSidebarRow: View {
    @Environment(\.colorScheme) private var colorScheme
    var project: StudioProject
    var selected: Bool
    var queued: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(project.name.isEmpty ? project.sourceName : project.name)
                    .font(.callout)
                    .bold()
                    .foregroundStyle(StudioPalette.primaryText(colorScheme))
                    .lineLimit(1)
                Spacer()
                if queued {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(StudioPalette.cyan)
                        .help("Queued")
                        .accessibilityLabel("Queued")
                }
            }
            Text(project.sourceName)
                .font(StudioTypography.monoCaption)
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selected ? StudioPalette.selectedPanel(colorScheme) : Color.clear)
        .clipShape(.rect(cornerRadius: StudioMetric.cornerRadius))
    }
}
