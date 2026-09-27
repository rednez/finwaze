import SwiftUI

/// The colour mark of a group or category (`TX-02`, `CAT-10`); draws nothing when no colour is set.
struct ColorTag: View {
    let hex: String?

    var body: some View {
        if let color = hex.flatMap(Color.init(hex:)) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .accessibilityHidden(true)
        }
    }
}

extension Color {
    /// A colour from `#RRGGBB`, the palette's format; `nil` for anything else.
    init?(hex: String) {
        let digits = hex.hasPrefix("#") ? hex.dropFirst() : Substring(hex)
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

#Preview {
    HStack {
        ColorTag(hex: "#6366F1")
        ColorTag(hex: "#22C55E")
        ColorTag(hex: nil)
    }
}
