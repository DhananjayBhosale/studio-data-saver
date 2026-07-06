import SwiftUI

struct MetadataLine: View {
    @Environment(\.colorScheme) private var colorScheme
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(label):")
                .foregroundStyle(StudioPalette.secondaryText(colorScheme))
                .frame(width: 72, alignment: .leading)
            Text(value)
                .foregroundStyle(StudioPalette.primaryText(colorScheme))
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
        .font(StudioTypography.monoCaption)
    }
}
