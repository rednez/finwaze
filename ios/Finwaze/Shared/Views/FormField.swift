import SwiftUI

/// A labelled input with an optional validation message below it.
struct FormField<Input: View>: View {
    let label: LocalizedStringKey
    let error: LocalizedStringResource?
    var isFocused = false
    @ViewBuilder let input: Input

    private let shape = RoundedRectangle(cornerRadius: 16)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .accessibilityHidden(true)

            input
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                // White in light mode, elevated grey in dark mode — stands out from the page background.
                .background(Color(.secondarySystemGroupedBackground), in: shape)
                .overlay {
                    shape.strokeBorder(borderStyle, lineWidth: isFocused || error != nil ? 1.5 : 1)
                }
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                .accessibilityLabel(Text(label))

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 8)
            }
        }
        .animation(.default, value: error == nil)
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    private var borderStyle: AnyShapeStyle {
        if error != nil { return AnyShapeStyle(.red) }
        if isFocused { return AnyShapeStyle(.tint) }
        return AnyShapeStyle(Color(.separator))
    }
}
