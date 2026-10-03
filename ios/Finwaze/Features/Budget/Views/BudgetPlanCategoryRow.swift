import SwiftUI

/// A category of the plan (`BUD-22`, `BUD-25`): its name and planned amount, with last month's plan and spending and
/// this month's spending. Two lines on a phone; one line of four columns, like the web, on a wide screen.
struct BudgetPlanCategoryRow: View {
    let name: String
    @Binding var amountText: String
    /// `nil` while loading or when loading failed: "—" rather than 0.
    let stats: BudgetPlanStats?
    let currencyCode: String
    let issue: PositiveAmountInput.Issue?
    let focus: FocusState<Int64?>.Binding
    let categoryID: Int64

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if sizeClass == .regular, !dynamicTypeSize.isAccessibilitySize {
                wide
            } else {
                compact
            }
            if let issue {
                Text(issue.planMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)
            }
        }
        .animation(.default, value: issue == nil)
    }

    private var compact: some View {
        VStack(alignment: .leading, spacing: 4) {
            if dynamicTypeSize.isAccessibilitySize {
                // The name above the field, so neither is squeezed at the largest sizes.
                Text(verbatim: name)
                amountField
            } else {
                HStack(spacing: 12) {
                    Text(verbatim: name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    amountField
                        .frame(maxWidth: 160)
                }
            }
            Text("budget.plan.stats \(amount(\.previousPlanned)) \(amount(\.previousSpent)) \(amount(\.spent))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel(statsAccessibilityLabel)
        }
    }

    private var wide: some View {
        HStack(spacing: 12) {
            Text(verbatim: name)
                .frame(maxWidth: .infinity, alignment: .leading)
            amountField
                .frame(width: BudgetPlanColumns.amountWidth)
            Group {
                Text(verbatim: amount(\.previousPlanned))
                Text(verbatim: amount(\.spent))
                Text(verbatim: amount(\.previousSpent))
            }
            .frame(width: BudgetPlanColumns.figureWidth, alignment: .trailing)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityHint(statsAccessibilityLabel)
    }

    /// The amount with its currency beside it (`GEN-06`).
    private var amountField: some View {
        HStack(spacing: 6) {
            TextField("budget.plan.amountPlaceholder", text: $amountText)
                .keyboardType(.decimalPad)
                .limitsAmountInput($amountText)
                .multilineTextAlignment(.trailing)
                .focused(focus, equals: categoryID)
                .accessibilityLabel(Text("budget.plan.amount.accessibility \(name)"))
                .accessibilityHint(issue.map { Text($0.planMessage) } ?? Text(verbatim: ""))
            Text(verbatim: currencyCode)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.tertiarySystemFill), in: .rect(cornerRadius: 8))
        .overlay {
            if issue != nil {
                RoundedRectangle(cornerRadius: 8).strokeBorder(.red, lineWidth: 1.5)
            }
        }
    }

    private func amount(_ keyPath: KeyPath<BudgetPlanStats, Decimal>) -> String {
        stats.map { $0[keyPath: keyPath].formattedAmount(currencyCode: currencyCode) } ?? "—"
    }

    private var statsAccessibilityLabel: Text {
        guard stats != nil else { return Text("budget.plan.stats.unavailable") }
        return Text(
            "budget.plan.stats.accessibility \(amount(\.previousPlanned)) \(amount(\.previousSpent)) \(amount(\.spent))"
        )
    }
}

/// A group's or the whole plan's four columns (`BUD-22`).
struct BudgetPlanTotalsRow: View {
    let title: LocalizedStringKey
    let totals: BudgetPlanDraft.Totals
    let currencyCode: String

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if sizeClass == .regular, !dynamicTypeSize.isAccessibilitySize {
                HStack(spacing: 12) {
                    Text(title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(verbatim: format(totals.planned))
                        .frame(width: BudgetPlanColumns.amountWidth, alignment: .trailing)
                    Group {
                        Text(verbatim: format(totals.previousPlanned))
                        Text(verbatim: format(totals.spent))
                        Text(verbatim: format(totals.previousSpent))
                    }
                    .frame(width: BudgetPlanColumns.figureWidth, alignment: .trailing)
                    .foregroundStyle(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            Text(title)
                            Spacer()
                            Text(verbatim: format(totals.planned))
                        }
                        VStack(alignment: .leading) {
                            Text(title)
                            Text(verbatim: format(totals.planned))
                        }
                    }
                    Text("budget.plan.stats \(previousPlanned) \(previousSpent) \(spent)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .fontWeight(.semibold)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(
            "budget.plan.totals.accessibility \(format(totals.planned)) \(previousPlanned) \(previousSpent) \(spent)"
        ))
    }

    private var previousPlanned: String {
        format(totals.previousPlanned)
    }

    private var previousSpent: String {
        format(totals.previousSpent)
    }

    private var spent: String {
        format(totals.spent)
    }

    private func format(_ amount: Decimal) -> String {
        amount.formattedAmount(currencyCode: currencyCode)
    }
}

/// The column titles above the wide layout's rows, like the web's table header.
struct BudgetPlanColumnTitles: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("budget.plan.column.category")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("budget.plan.column.planned")
                .frame(width: BudgetPlanColumns.amountWidth, alignment: .trailing)
            Group {
                Text("budget.plan.column.previousPlanned")
                Text("budget.plan.column.spent")
                Text("budget.plan.column.previousSpent")
            }
            .frame(width: BudgetPlanColumns.figureWidth, alignment: .trailing)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.trailing)
        .accessibilityHidden(true)
    }
}

enum BudgetPlanColumns {
    static let amountWidth: CGFloat = 170
    static let figureWidth: CGFloat = 120
}
