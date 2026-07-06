import SwiftUI

struct PathPickerRow: View {
    @Environment(\.colorScheme) private var colorScheme
    var title: String
    var icon: String
    @Binding var text: String
    var choose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Label(title, systemImage: icon)
                .font(.callout.weight(.semibold))
                .foregroundStyle(StudioPalette.primaryText(colorScheme))
                .frame(width: 130, alignment: .leading)

            TextField(title, text: $text)
                .textFieldStyle(.plain)
                .font(StudioTypography.monoCallout)
                .textSelection(.enabled)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(StudioPalette.terminal(colorScheme))
                .clipShape(.rect(cornerRadius: 6))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(StudioPalette.border(colorScheme), lineWidth: 1)
                }

            Button(action: choose) {
                Label("Choose", systemImage: "folder.badge.plus")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(StudioButtonStyle(compact: true))
            .help("Choose \(title.lowercased())")
        }
    }
}
