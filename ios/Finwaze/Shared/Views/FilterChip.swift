import SwiftUI

/// "USD ⌄" behind a banknote: a filter's icon and value on a glass capsule, short enough for
/// several to share a row on a phone. The filter's name is its spoken label.
struct FilterChip: View {
    let systemImage: String
    let value: Text

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            value
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}
