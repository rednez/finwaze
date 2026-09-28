import SwiftUI

/// "On track", "Attention" or "Over budget" (`BUD-04`): an icon and a word as well as the colour, so the status reads
/// without it.
struct BudgetStatusBadge: View {
    let status: BudgetStatus

    var body: some View {
        Label(status.title, systemImage: status.systemImage)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(status.color)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.15), in: .capsule)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("budget.status.accessibility \(Text(status.title))"))
    }
}

extension BudgetStatus {
    var title: LocalizedStringKey {
        switch self {
        case .onTrack: "budget.status.onTrack"
        case .attention: "budget.status.attention"
        case .overBudget: "budget.status.overBudget"
        }
    }

    var systemImage: String {
        switch self {
        case .onTrack: "checkmark.circle.fill"
        case .attention: "exclamationmark.triangle.fill"
        case .overBudget: "xmark.octagon.fill"
        }
    }

    var color: Color {
        switch self {
        case .onTrack: .green
        case .attention: .orange
        case .overBudget: .red
        }
    }
}
