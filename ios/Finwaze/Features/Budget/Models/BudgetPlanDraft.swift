import Foundation

/// The plan being edited (`BUD-22…26`): groups with their categories, each with the amount as typed and the reference
/// figures, against the plan last saved. Pure, so the editor's rules are tested without the UI.
nonisolated struct BudgetPlanDraft: Equatable, Sendable {
    /// A category of the plan.
    struct Line: Identifiable, Equatable, Sendable {
        /// The category's id.
        let id: Int64
        /// The server's name, for when the reference data does not know the id.
        let fallbackName: String
        /// The amount as the user typed it.
        var amountText: String
        /// `nil` while loading, or when loading failed: the row shows "—" rather than 0 (`BUD-24`).
        var stats: BudgetPlanStats?

        var amount: Result<Decimal, PositiveAmountInput.Issue> {
            PositiveAmountInput.parse(amountText)
        }
    }

    /// A group of the plan, with its categories in the order they were added.
    struct Section: Identifiable, Equatable, Sendable {
        /// The group's id.
        let id: Int64
        let fallbackName: String
        var lines: [Line]
    }

    /// The four columns of the editor (`BUD-22`).
    struct Totals: Equatable, Sendable {
        var planned: Decimal = 0
        var previousPlanned: Decimal = 0
        var spent: Decimal = 0
        var previousSpent: Decimal = 0
    }

    /// In the server's order — the largest plan first — with groups added here at the end.
    private(set) var sections: [Section]
    /// The plan as last saved: category id → amount.
    private(set) var saved: [Int64: Decimal]

    /// A draft of `lines`, measured against `saved`: the same plan for one loaded from the server, an empty one for a
    /// generated plan, which is not saved yet (`BUD-21`).
    init(lines: [BudgetPlanLine] = [], saved: [Int64: Decimal] = [:]) {
        var sections: [Section] = []
        for line in lines {
            let draftLine = Line(
                id: line.categoryID,
                fallbackName: line.categoryName,
                amountText: Self.text(for: line.planned),
                stats: line.stats
            )
            if let index = sections.firstIndex(where: { $0.id == line.groupID }) {
                sections[index].lines.append(draftLine)
            } else {
                sections.append(Section(id: line.groupID, fallbackName: line.groupName, lines: [draftLine]))
            }
        }
        self.sections = sections
        self.saved = saved
    }

    /// A draft of a plan just loaded from the server: nothing is changed yet.
    static func saved(_ lines: [BudgetPlanLine]) -> BudgetPlanDraft {
        BudgetPlanDraft(lines: lines, saved: Dictionary(lines.map { ($0.categoryID, $0.planned) }, uniquingKeysWith: +))
    }

    var lines: [Line] {
        sections.flatMap(\.lines)
    }

    var isEmpty: Bool {
        sections.isEmpty
    }

    // MARK: Editing (BUD-23, BUD-24)

    /// The expense groups not in the plan yet, as `groups` has them (`BUD-23`, `GEN-05`).
    func availableGroups(_ groups: [CategoryGroup]) -> [CategoryGroup] {
        let used = Set(sections.map(\.id))
        return groups.filter { $0.transactionType == .expense && !used.contains($0.id) }
    }

    /// The group's categories not in the plan yet (`BUD-24`).
    func availableCategories(inGroup groupID: Int64, _ categories: [Category]) -> [Category] {
        let used = Set(lines.map(\.id))
        return categories.filter { $0.groupID == groupID && !used.contains($0.id) }
    }

    /// Adds an empty group at the end.
    mutating func addGroup(id: Int64, name: String) {
        guard !sections.contains(where: { $0.id == id }) else { return }
        sections.append(Section(id: id, fallbackName: name, lines: []))
    }

    mutating func removeGroup(id: Int64) {
        sections.removeAll { $0.id == id }
    }

    /// Adds a category with no amount and no reference figures yet to its group, adding the group if needed.
    mutating func addCategory(_ category: Category, groupName: String) {
        guard !lines.contains(where: { $0.id == category.id }) else { return }
        addGroup(id: category.groupID, name: groupName)
        guard let index = sections.firstIndex(where: { $0.id == category.groupID }) else { return }
        sections[index].lines.append(Line(id: category.id, fallbackName: category.name, amountText: "", stats: nil))
    }

    mutating func removeCategory(id: Int64) {
        for index in sections.indices {
            sections[index].lines.removeAll { $0.id == id }
        }
    }

    mutating func setAmountText(_ text: String, for categoryID: Int64) {
        update(categoryID) { $0.amountText = text }
    }

    /// Ignored when the category is no longer in the plan.
    mutating func setStats(_ stats: BudgetPlanStats, for categoryID: Int64) {
        update(categoryID) { $0.stats = stats }
    }

    func line(_ categoryID: Int64) -> Line? {
        lines.first { $0.id == categoryID }
    }

    private mutating func update(_ categoryID: Int64, _ change: (inout Line) -> Void) {
        for sectionIndex in sections.indices {
            if let lineIndex = sections[sectionIndex].lines.firstIndex(where: { $0.id == categoryID }) {
                change(&sections[sectionIndex].lines[lineIndex])
                return
            }
        }
    }

    // MARK: Totals (BUD-22)

    /// The group's four columns; only valid amounts count towards the plan.
    func totals(ofGroup groupID: Int64) -> Totals {
        Self.totals(sections.first { $0.id == groupID }?.lines ?? [])
    }

    /// The whole plan's four columns.
    var totals: Totals {
        Self.totals(lines)
    }

    private static func totals(_ lines: [Line]) -> Totals {
        lines.reduce(into: Totals()) { totals, line in
            if case .success(let amount) = line.amount {
                totals.planned += amount
            }
            totals.previousPlanned += line.stats?.previousPlanned ?? 0
            totals.spent += line.stats?.spent ?? 0
            totals.previousSpent += line.stats?.previousSpent ?? 0
        }
    }

    // MARK: Validation and saving (BUD-25, BUD-26)

    /// The category's amount issue: empty, zero or below, more than two decimal places (`BUD-25`, `GEN-07`).
    func issue(for categoryID: Int64) -> PositiveAmountInput.Issue? {
        guard let line = line(categoryID), case .failure(let issue) = line.amount else { return nil }
        return issue
    }

    /// The first category with an invalid amount, in the order shown.
    var firstInvalidCategoryID: Int64? {
        lines.first { issue(for: $0.id) != nil }?.id
    }

    /// Category id → amount, while every amount is valid; a group without categories is simply not in it.
    var payload: [Int64: Decimal]? {
        var result: [Int64: Decimal] = [:]
        for line in lines {
            guard case .success(let amount) = line.amount else { return nil }
            result[line.id] = amount
        }
        return result
    }

    /// Whether the amounts differ from the plan last saved; order and collapsed groups do not count, and text that
    /// is not a valid amount is a change (`BUD-26`).
    var isDirty: Bool {
        payload != saved
    }

    /// Saving now would delete a plan that exists (`GEN-22`).
    var deletesSavedPlan: Bool {
        !saved.isEmpty && lines.isEmpty
    }

    /// The amounts now saved become the plan to compare with.
    mutating func markSaved(_ amounts: [Int64: Decimal]) {
        saved = amounts
    }

    /// `250.5` rather than `250,50 ₴`: the field holds a plain number, which the parser reads in any language.
    static func text(for amount: Decimal) -> String {
        "\(amount)"
    }
}
