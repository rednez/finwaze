import Charts
import SwiftUI

/// A ring of amounts with a caption and the total in the middle, beside its legend — or under it when they do not fit
/// side by side (`DASH-05`, `ACC-05`).
struct DonutChart: View {
    let summary: SliceSummary
    let currencyCode: String
    /// Above the total in the middle, e.g. "Total for month".
    let caption: LocalizedStringKey
    /// Each legend row also shows the slice's part of the total, e.g. "42 %".
    var showsShare = false

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 20) {
                ring
                legend
            }
            VStack(spacing: 16) {
                ring
                legend
            }
        }
    }

    private var ring: some View {
        DonutRing(summary: summary, currencyCode: currencyCode, caption: caption)
    }

    private var legend: some View {
        DonutLegend(summary: summary, currencyCode: currencyCode, showsShare: showsShare)
    }
}

private struct DonutRing: View {
    let summary: SliceSummary
    let currencyCode: String
    let caption: LocalizedStringKey

    var body: some View {
        Chart(summary.slices) { slice in
            SectorMark(angle: .value(String(localized: "dashboard.chart.amount"), slice.amount.chartValue),
                       innerRadius: .ratio(0.66),
                       angularInset: 1.5)
                .cornerRadius(3)
                .foregroundStyle(slice.color)
                .accessibilityLabel(Text(verbatim: slice.displayName))
                .accessibilityValue(Text(verbatim: slice.amount.formattedAmount(currencyCode: currencyCode)))
        }
        .chartLegend(.hidden)
        .chartBackground { proxy in
            GeometryReader { geometry in
                if let plotFrame = proxy.plotFrame {
                    let frame = geometry[plotFrame]
                    VStack(spacing: 2) {
                        Text(caption)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        Text(verbatim: summary.total.formattedAmount(currencyCode: currencyCode))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: frame.width * 0.56)
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .frame(width: 160, height: 160)
    }
}

/// The ring's slices with their colours and amounts, largest first.
private struct DonutLegend: View {
    let summary: SliceSummary
    let currencyCode: String
    let showsShare: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(summary.slices) { slice in
                HStack(spacing: 8) {
                    Circle()
                        .fill(slice.color)
                        .frame(width: 10, height: 10)
                        .accessibilityHidden(true)
                    Text(verbatim: slice.displayName)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    if showsShare {
                        Text(verbatim: summary.share(of: slice).formatted(.percent.precision(.fractionLength(0))))
                            .foregroundStyle(.tertiary)
                    }
                    Text(verbatim: slice.amount.formattedAmount(currencyCode: currencyCode))
                        .foregroundStyle(.secondary)
                }
                .monospacedDigit()
                .font(.subheadline)
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private extension ChartSlice {
    /// Tones of the accent colour and neighbouring hues, like the web's `generateAnalogColors`; "Other categories"
    /// is grey.
    private static let palette: [Color] = [.accentColor, .blue, .purple, .indigo, .teal, .pink, .orange]

    var color: Color {
        isOther ? Color(.systemGray3) : Self.palette[id % Self.palette.count]
    }

    var displayName: String {
        name ?? String(localized: "dashboard.budget.other")
    }
}
