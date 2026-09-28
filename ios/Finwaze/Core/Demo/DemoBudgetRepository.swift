import Foundation

/// Demo-mode Budget (`AUTH-10`): the plan from `DemoData.plannedBudgets` against the same demo expenses the
/// Transactions list and the Dashboard show, so all three agree. Nothing here writes.
nonisolated struct DemoBudgetRepository: BudgetRepository {
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    /// A plan or spending in one category.
    private struct Line {
        let category: Category
        let planned: Decimal
        let spent: Decimal
    }

    func budgets(_ query: BudgetQuery) async throws -> [BudgetItem] {
        let lines = lines(in: query.month, query)
        let items: [BudgetItem]
        if query.groupID == nil {
            items = Dictionary(grouping: lines, by: \.category.groupID).compactMap { groupID, lines in
                guard let group = DemoData.groups.first(where: { $0.id == groupID }) else { return nil }
                let planned = lines.reduce(Decimal(0)) { $0 + $1.planned }
                return BudgetItem(
                    id: group.id,
                    name: group.name,
                    planned: planned,
                    spent: lines.reduce(0) { $0 + $1.spent },
                    categoriesCount: lines.count,
                    isUnplanned: planned == 0
                )
            }
        } else {
            items = lines.map { line in
                BudgetItem(
                    id: line.category.id,
                    name: line.category.name,
                    planned: line.planned,
                    spent: line.spent,
                    categoriesCount: nil,
                    isUnplanned: line.planned == 0
                )
            }
        }
        // Like the server: planned ones first, largest plan first, then by name.
        return items.sorted { ($0.isUnplanned ? 1 : 0, -$0.planned, $0.name) < ($1.isUnplanned ? 1 : 0, -$1.planned, $1.name) }
    }

    func totals(_ query: BudgetQuery) async throws -> BudgetTotals {
        let lines = lines(in: query.month, query)
        return BudgetTotals(
            planned: lines.reduce(0) { $0 + $1.planned },
            spent: lines.reduce(0) { $0 + $1.spent }
        )
    }

    func expenses(_ query: BudgetQuery) async throws -> [MonthlyExpense] {
        let current = spending(in: query.month, query)
        let previous = spending(in: query.month.adding(months: -1), query)
        return current
            .map { id, amount in
                MonthlyExpense(id: id, name: name(of: id, query), amount: amount, previousAmount: previous[id] ?? 0)
            }
            .sorted { ($1.amount, $0.name) < ($0.amount, $1.name) }
    }

    /// The month's plan and spending per category within the query's group, if any.
    private func lines(in month: YearMonth, _ query: BudgetQuery) -> [Line] {
        let spent = spentByCategory(in: month, currencyCode: query.currencyCode)
        let planned = plannedByCategory(in: month, currencyCode: query.currencyCode)
        return DemoData.categories.compactMap { category in
            guard query.groupID == nil || category.groupID == query.groupID else { return nil }
            let line = Line(category: category, planned: planned[category.id] ?? 0, spent: spent[category.id] ?? 0)
            return line.planned > 0 || line.spent > 0 ? line : nil
        }
    }

    /// The month's spending by group — or by the query's group's categories.
    private func spending(in month: YearMonth, _ query: BudgetQuery) -> [Int64: Decimal] {
        var result: [Int64: Decimal] = [:]
        for (categoryID, amount) in spentByCategory(in: month, currencyCode: query.currencyCode) {
            guard let category = DemoData.categories.first(where: { $0.id == categoryID }) else { continue }
            if let groupID = query.groupID {
                if category.groupID == groupID { result[categoryID, default: 0] += amount }
            } else {
                result[category.groupID, default: 0] += amount
            }
        }
        return result
    }

    private func name(of id: Int64, _ query: BudgetQuery) -> String {
        if query.groupID == nil {
            DemoData.groups.first { $0.id == id }?.name ?? ""
        } else {
            DemoData.categories.first { $0.id == id }?.name ?? ""
        }
    }

    /// Expenses in the purchase currency, as positive amounts (`BUD-02`).
    private func spentByCategory(in month: YearMonth, currencyCode: String) -> [Int64: Decimal] {
        guard let start = month.start(in: calendar) else { return [:] }
        var result: [Int64: Decimal] = [:]
        for transaction in DemoData.transactions(inMonthOf: start, now: now(), calendar: calendar)
        where transaction.type == .expense && transaction.transactionCurrencyCode == currencyCode {
            result[transaction.category.id, default: 0] += abs(transaction.transactionAmount)
        }
        return result
    }

    /// The same plan every month up to the current one; none in a later month.
    private func plannedByCategory(in month: YearMonth, currencyCode: String) -> [Int64: Decimal] {
        guard
            currencyCode == DemoData.budgetCurrencyCode,
            let start = month.start(in: calendar),
            start <= now()
        else { return [:] }
        return Dictionary(DemoData.plannedBudgets.map { ($0.categoryID, $0.amount) }, uniquingKeysWith: +)
    }
}
