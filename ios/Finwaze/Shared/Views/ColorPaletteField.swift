import SwiftUI

/// Picks a colour from the fixed palette or none (`CAT-10`): a grid of 24 swatches and "No colour".
struct ColorPaletteField: View {
    @Binding var selection: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("colorPalette.label")
                .font(.subheadline.weight(.medium))
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(ColorPalette.colors.enumerated()), id: \.element) { index, hex in
                        Swatch(hex: hex, isSelected: selection == hex) { selection = hex }
                            .accessibilityLabel(Text("colorPalette.option \(index + 1)"))
                    }
                }

                Button {
                    selection = nil
                } label: {
                    Label("colorPalette.none", systemImage: selection == nil ? "checkmark.circle.fill" : "circle.slash")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .foregroundStyle(selection == nil ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                .accessibilityAddTraits(selection == nil ? .isSelected : [])
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("colorPalette.label"))
    }
}

private struct Swatch: View {
    let hex: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: hex) ?? .clear)
                .frame(width: 32, height: 32)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 1)
                    }
                }
                .padding(3)
                .overlay {
                    Circle().strokeBorder(isSelected ? AnyShapeStyle(.primary) : AnyShapeStyle(.clear), lineWidth: 2)
                }
                .frame(maxWidth: .infinity)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selection: String? = ColorPalette.colors[3]
    ColorPaletteField(selection: $selection)
        .padding()
        .background(Color(.systemGroupedBackground))
}
