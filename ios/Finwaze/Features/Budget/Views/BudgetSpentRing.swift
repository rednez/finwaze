import Charts
import SwiftUI

/// "Spent of planned" as a ring with the share and the amount spent in the middle (`BUD-12`). Spending past the plan,
/// or without one (`BUD-05`), fills the ring in the colour of overspending.
struct BudgetSpentRing: View {
    let planned: Decimal
    let spent: Decimal
    let currencyCode: String

    private struct Segment: Identifiable {
        let id: Int
        let value: Decimal
        let color: Color
    }

    var body: some View {
        Chart(segments) { segment in
            SectorMark(
                angle: .value(String(localized: "budget.chart.amount"), segment.value.chartValue),
                innerRadius: .ratio(0.8),
                angularInset: 1
            )
            .cornerRadius(3)
            .foregroundStyle(segment.color)
        }
        .chartLegend(.hidden)
        .chartBackground { proxy in
            GeometryReader { geometry in
                if let plotFrame = proxy.plotFrame {
                    let frame = geometry[plotFrame]
                    VStack(spacing: 2) {
                        share
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(verbatim: spent.formattedAmount(currencyCode: currencyCode))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: frame.width * 0.7)
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .frame(width: 128, height: 128)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var isOverspent: Bool {
        planned <= 0 || spent > planned
    }

    private var segments: [Segment] {
        if isOverspent {
            return [Segment(id: 0, value: 1, color: .red.opacity(0.7))]
        }
        return [
            Segment(id: 0, value: spent, color: .accentColor),
            Segment(id: 1, value: planned - spent, color: Color(.systemGray5)),
        ]
        .filter { $0.value > 0 }
    }

    /// "88 % spent", or "Unplanned" without a plan.
    private var share: Text {
        guard let percent else { return Text("budget.unplanned") }
        return Text("budget.spentShare \(percent)")
    }

    /// Spent as a whole percentage of the plan, e.g. "110 %"; `nil` without a plan.
    private var percent: String? {
        guard planned > 0 else { return nil }
        return (spent / planned).formatted(.percent.precision(.fractionLength(0)))
    }

    private var accessibilityText: Text {
        let spentText = spent.formattedAmount(currencyCode: currencyCode)
        guard let percent else { return Text("budget.ring.unplanned.accessibility \(spentText)") }
        let plannedText = planned.formattedAmount(currencyCode: currencyCode)
        return Text("budget.ring.accessibility \(spentText) \(plannedText) \(percent)")
    }
}
