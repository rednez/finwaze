import SwiftUI

/// The figures of a point touched on a chart, above it, like the Health app's: the point's name and a row per series
/// with its colour and amount.
struct ChartCallout: View {
    struct Row: Identifiable {
        let name: String
        let amount: Decimal
        let color: Color

        var id: String { name }
    }

    let title: String
    let rows: [Row]
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(rows) { row in
                HStack(spacing: 6) {
                    Circle()
                        .fill(row.color)
                        .frame(width: 8, height: 8)
                    Text(verbatim: row.amount.formattedAmount(currencyCode: currencyCode))
                        .font(.subheadline.weight(.semibold))
                        .fontDesign(.rounded)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "\(row.name), \(row.amount.formattedAmount(currencyCode: currencyCode))"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }
}
