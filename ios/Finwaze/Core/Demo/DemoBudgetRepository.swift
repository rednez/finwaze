import Foundation

/// Demo-mode Budget (`AUTH-10`): the plan from `DemoData.plannedBudgets` against the same demo expenses the
/// Transactions list and the Dashboard show, so all three agree. Saving a plan succeeds without changing it.
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

    // MARK: Plan (BUD-20…26)

    func plan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine] {
        let planned = plannedByCategory(in: month, currencyCode: currencyCode)
        return planLines(month: month, currencyCode: currencyCode) { category, _ in planned[category.id] ?? 0 }
    }

    /// Like the server: last month's plan, else last month's spending, else this month's.
    func generatedPlan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine] {
        planLines(month: month, currencyCode: currencyCode) { _, stats in
            [stats.previousPlanned, stats.previousSpent, stats.spent].first { $0 > 0 } ?? 0
        }
    }

    func categoryStats(month: YearMonth, currencyCode: String, categoryID: Int64) async throws -> BudgetPlanStats {
        stats(month: month, currencyCode: currencyCode)(categoryID)
    }

    /// Nothing is stored (`AUTH-10`).
    func savePlan(month: YearMonth, currencyCode: String, amounts: [Int64: Decimal]) async throws {}

    private func planLines(
        month: YearMonth,
        currencyCode: String,
        amount: (Category, BudgetPlanStats) -> Decimal
    ) -> [BudgetPlanLine] {
        let stats = stats(month: month, currencyCode: currencyCode)
        let lines = DemoData.categories.compactMap { category -> BudgetPlanLine? in
            guard let group = DemoData.groups.first(where: { $0.id == category.groupID }) else { return nil }
            let categoryStats = stats(category.id)
            let planned = amount(category, categoryStats)
            guard planned > 0 else { return nil }
            return BudgetPlanLine(
                categoryID: category.id,
                categoryName: category.name,
                groupID: group.id,
                groupName: group.name,
                planned: planned,
                stats: categoryStats
            )
        }
        // Like the server: largest plan first, then by group and category name.
        return lines.sorted {
            (-$0.planned, $0.groupName, $0.categoryName) < (-$1.planned, $1.groupName, $1.categoryName)
        }
    }

    private func stats(month: YearMonth, currencyCode: String) -> (Int64) -> BudgetPlanStats {
        let previousMonth = month.adding(months: -1)
        let previousPlanned = plannedByCategory(in: previousMonth, currencyCode: currencyCode)
        let spent = spentByCategory(in: month, currencyCode: currencyCode)
        let previousSpent = spentByCategory(in: previousMonth, currencyCode: currencyCode)
        return { id in
            BudgetPlanStats(
                previousPlanned: previousPlanned[id] ?? 0,
                spent: spent[id] ?? 0,
                previousSpent: previousSpent[id] ?? 0
            )
        }
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
        var result: [Int64: Decimal] = [:]
        for transaction in DemoData.transactions(in: month, now: now(), calendar: calendar)
        where transaction.isExpense(by: \.transactionAmount) && transaction.transactionCurrencyCode == currencyCode {
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
