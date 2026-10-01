import SwiftUI

/// A group's or category's budget (`BUD-12`, `BUD-17`): the ring, what is left of the plan and the status. A group's
/// card leads to its categories.
struct BudgetItemCard: View {
    let item: BudgetItem
    let currencyCode: String
    /// "N categories →"; `nil` on a category's card.
    var onOpen: (() -> Void)?

    var body: some View {
        ContentCard(verbatim: item.name, action: action) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) {
                    ring
                    summary
                }
                VStack(alignment: .leading, spacing: 16) {
                    ring
                    summary
                }
            }
        }
    }

    private var action: ContentCardAction? {
        guard let onOpen, let count = item.categoriesCount else { return nil }
        return .init(title: "budget.categories \(count)", perform: onOpen)
    }

    private var ring: some View {
        BudgetSpentRing(planned: item.planned, spent: item.spent, currencyCode: currencyCode, tint: item.status.color)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 12) {
            BudgetRemaining(remaining: item.remaining, planned: item.planned, currencyCode: currencyCode)
            BudgetStatusBadge(status: item.status)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// "Left 500,00 ₴ / 4 000 ₴" (`BUD-03`, `BUD-12`); what is left may be negative.
struct BudgetRemaining: View {
    let remaining: Decimal
    let planned: Decimal
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("budget.left")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(verbatim: remaining.formattedAmount(currencyCode: currencyCode))
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)
                .foregroundStyle(remaining < 0 ? .red : .primary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(verbatim: "/ \(planned.formattedAmount(currencyCode: currencyCode))")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.tint)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: Text {
        let remainingText = remaining.formattedAmount(currencyCode: currencyCode)
        let plannedText = planned.formattedAmount(currencyCode: currencyCode)
        return Text("budget.left.accessibility \(remainingText) \(plannedText)")
    }
}

extension BudgetItem {
    /// Skeleton cards while the budget loads (`GEN-23`).
    static let placeholders = [
        BudgetItem(id: -1, name: "Groceries", planned: 4000, spent: 3500, categoriesCount: 3, isUnplanned: false),
        BudgetItem(id: -2, name: "Transport", planned: 1500, spent: 400, categoriesCount: 2, isUnplanned: false),
    ]
}
