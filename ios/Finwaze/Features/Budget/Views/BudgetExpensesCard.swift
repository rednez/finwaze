import SwiftUI

/// "Most expenses" (`BUD-14`): the month's spending by group — or by category on a group's screen — largest first,
/// each with its change against last month, where growth is bad.
struct BudgetExpensesCard: View {
    let state: CardState<[MonthlyExpense]>
    let currencyCode: String
    let onRetry: () -> Void
    let onAddExpense: () -> Void

    var body: some View {
        ContentCard(title: "budget.expenses.title", subtitle: "budget.expenses.subtitle") {
            CardStateView(state: state, placeholder: MonthlyExpense.placeholders, onRetry: onRetry) { expenses in
                if expenses.isEmpty {
                    CardEmptyState(
                        title: "budget.expenses.empty.title",
                        message: "budget.expenses.empty.message",
                        actionTitle: "budget.expenses.add",
                        action: onAddExpense
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(expenses.enumerated()), id: \.element.id) { index, expense in
                            if index > 0 {
                                Divider()
                            }
                            ExpenseRow(expense: expense, currencyCode: currencyCode)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
}

private struct ExpenseRow: View {
    let expense: MonthlyExpense
    let currencyCode: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: expense.amount.formattedAmount(currencyCode: currencyCode))
                    .font(.headline)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(verbatim: expense.name)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            TrendBadge(trend: expense.trend, showsCaption: false)
        }
        .accessibilityElement(children: .combine)
    }
}

private extension MonthlyExpense {
    /// Skeleton rows while the expenses load (`GEN-23`).
    static let placeholders = [
        MonthlyExpense(id: -1, name: "Groceries", amount: 3500, previousAmount: 3200),
        MonthlyExpense(id: -2, name: "Transport", amount: 1200, previousAmount: 1400),
        MonthlyExpense(id: -3, name: "Entertainment", amount: 640, previousAmount: 640),
    ]
}
