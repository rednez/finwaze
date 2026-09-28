import SwiftUI

/// "↑ 12.5 % vs last month", green when the change is good and red when bad (`DASH-03`, `BUD-14`). The arrow and the
/// spoken label carry the direction, not only the colour. Without the caption where the context already says what it
/// compares, e.g. a row of Budget's "Most expenses".
struct TrendBadge: View {
    let trend: TrendChange
    var showsCaption = true

    var body: some View {
        Group {
            if showsCaption {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) {
                        badge
                        caption
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        badge
                        caption
                    }
                }
            } else {
                badge
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var badge: some View {
        HStack(spacing: 2) {
            if let arrow {
                Image(systemName: arrow)
                    .font(.caption.weight(.bold))
            }
            Text(verbatim: trend.formattedRatio())
                .monospacedDigit()
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(color.opacity(0.15), in: .capsule)
    }

    private var caption: some View {
        Text("dashboard.vsLastMonth")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }

    private var arrow: String? {
        switch trend.direction {
        case .up: "arrow.up"
        case .down: "arrow.down"
        case .flat: nil
        }
    }

    private var color: Color {
        switch trend.assessment {
        case .good: .green
        case .bad: .red
        case .neutral: .secondary
        }
    }

    private var accessibilityText: Text {
        let ratio = trend.formattedRatio()
        return switch trend.direction {
        case .up: Text("dashboard.trend.up \(ratio)")
        case .down: Text("dashboard.trend.down \(ratio)")
        case .flat: Text("dashboard.trend.flat")
        }
    }
}
