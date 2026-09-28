import Foundation
import Testing
@testable import Finwaze

/// The plan editor's data: the mapper, the request body and the draft's rules (`BUD-20…26`).
struct BudgetPlanDraftTests {
    private static let food = CategoryGroup(id: 1, name: "Food", transactionType: .expense, color: nil)
    private static let housing = CategoryGroup(id: 4, name: "Housing", transactionType: .expense, color: nil)
    private static let salary = CategoryGroup(id: 5, name: "Salary", transactionType: .income, color: nil)
    private static let groceries = Finwaze.Category(id: 1, name: "Groceries", groupID: 1, color: nil)
    private static let restaurants = Finwaze.Category(id: 2, name: "Restaurants", groupID: 1, color: nil)
    private static let rent = Finwaze.Category(id: 7, name: "Rent", groupID: 4, color: nil)

    private let rentLine = BudgetPlanLine(
        categoryID: 7, categoryName: "Rent", groupID: 4, groupName: "Housing", planned: 1200,
        stats: BudgetPlanStats(previousPlanned: 1200, spent: 1200, previousSpent: 1100)
    )
    private let groceriesLine = BudgetPlanLine(
        categoryID: 1, categoryName: "Groceries", groupID: 1, groupName: "Food", planned: Decimal(string: "250.5")!,
        stats: BudgetPlanStats(previousPlanned: 250, spent: 150, previousSpent: 205)
    )

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    // MARK: Mapper

    @Test func planKeepsOnlyPlannedCategories() throws {
        let dtos = try decode([MonthlyBudgetDetailedDto].self, """
            [{"category_id": 7, "category_name": "Rent", "group_id": 4, "group_name": "Housing",
              "planned_amount": 1200, "previous_planned_amount": null, "spent_amount": 1200.5,
              "previous_spent_amount": -1100, "is_unplanned": false},
             {"category_id": 2, "category_name": "Restaurants", "group_id": 1, "group_name": "Food",
              "planned_amount": 0, "previous_planned_amount": 0, "spent_amount": 45,
              "previous_spent_amount": 85, "is_unplanned": true}]
            """)

        let plan = BudgetMapper.toPlan(dtos)

        #expect(plan == [
            BudgetPlanLine(
                categoryID: 7, categoryName: "Rent", groupID: 4, groupName: "Housing", planned: 1200,
                stats: BudgetPlanStats(previousPlanned: 0, spent: Decimal(string: "1200.5")!, previousSpent: 1100)
            ),
        ])
    }

    @Test func statsDefaultToZero() throws {
        let dto = try decode(CategoryBudgetStatsDto.self, """
            {"previous_planned_amount": 60, "spent_amount": null, "previous_spent_amount": 33.25}
            """)

        #expect(BudgetMapper.toStats(dto) == BudgetPlanStats(previousPlanned: 60, spent: 0,
                                                             previousSpent: Decimal(string: "33.25")!))
        #expect(BudgetMapper.toStats(nil) == .zero)
    }

    /// `p_categories` carries the amounts exactly (`GEN-09`).
    @Test func encodesAmountsExactly() throws {
        let amounts = BudgetMapper.toPlanAmounts([7: Decimal(string: "1234.56")!, 1: Decimal(string: "0.1")!])

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = try #require(String(data: encoder.encode(amounts), encoding: .utf8))

        #expect(json == #"[{"category_id":1,"planned_amount":0.1},{"category_id":7,"planned_amount":1234.56}]"#)
    }

    // MARK: Building

    @Test func groupsKeepTheServersOrder() {
        let draft = BudgetPlanDraft.saved([rentLine, groceriesLine])

        #expect(draft.sections.map(\.id) == [4, 1])
        #expect(draft.line(1)?.amountText == "250.5")
        #expect(draft.line(7)?.stats == rentLine.stats)
        #expect(!draft.isDirty)
    }

    @Test func generatedPlanIsNotSaved() {
        let draft = BudgetPlanDraft(lines: [rentLine])

        #expect(draft.isDirty)
        #expect(draft.payload == [7: 1200])
    }

    // MARK: Editing (BUD-23, BUD-24)

    @Test func offersExpenseGroupsNotInThePlan() {
        let draft = BudgetPlanDraft.saved([rentLine])

        #expect(draft.availableGroups([Self.food, Self.housing, Self.salary]) == [Self.food])
    }

    @Test func offersTheGroupsCategoriesNotInThePlan() {
        let draft = BudgetPlanDraft.saved([groceriesLine])

        #expect(draft.availableCategories(inGroup: 1, [Self.groceries, Self.restaurants, Self.rent])
            == [Self.restaurants])
    }

    @Test func addedGroupGoesLastAndEmptyGroupIsNotSaved() {
        var draft = BudgetPlanDraft.saved([rentLine])

        draft.addGroup(id: 1, name: "Food")

        #expect(draft.sections.map(\.id) == [4, 1])
        #expect(draft.payload == [7: 1200])
        #expect(!draft.isDirty)
    }

    @Test func addedCategoryHasNoAmountOrFigures() {
        var draft = BudgetPlanDraft.saved([rentLine])

        draft.addCategory(Self.restaurants, groupName: "Food")

        #expect(draft.sections.map(\.id) == [4, 1])
        #expect(draft.line(2)?.amountText == "")
        #expect(draft.line(2)?.stats == nil)
        #expect(draft.issue(for: 2) == .required)
        #expect(draft.payload == nil)
        #expect(draft.isDirty)

        draft.setStats(BudgetPlanStats(previousPlanned: 0, spent: 45, previousSpent: 85), for: 2)
        #expect(draft.line(2)?.stats?.spent == 45)
    }

    @Test func removingCategoryAndGroup() {
        var draft = BudgetPlanDraft.saved([rentLine, groceriesLine])

        draft.removeCategory(id: 1)
        #expect(draft.payload == [7: 1200])
        #expect(draft.sections.map(\.id) == [4, 1])

        draft.removeGroup(id: 4)
        #expect(draft.payload == [:])
        #expect(draft.deletesSavedPlan)
    }

    // MARK: Totals (BUD-22)

    @Test func totalsCountOnlyValidAmounts() {
        var draft = BudgetPlanDraft.saved([rentLine, groceriesLine])
        draft.addCategory(Self.restaurants, groupName: "Food")
        draft.setAmountText("abc", for: 2)

        #expect(draft.totals(ofGroup: 1) == BudgetPlanDraft.Totals(
            planned: Decimal(string: "250.5")!, previousPlanned: 250, spent: 150, previousSpent: 205
        ))
        #expect(draft.totals == BudgetPlanDraft.Totals(
            planned: Decimal(string: "1450.5")!, previousPlanned: 1450, spent: 1350, previousSpent: 1305
        ))
    }

    // MARK: Validation and changes (BUD-25, BUD-26)

    @Test(arguments: [
        ("", PositiveAmountInput.Issue.required),
        ("0", .notPositive),
        ("-5", .notPositive),
        ("12.345", .tooPrecise),
    ])
    func invalidAmountBlocksSaving(text: String, issue: PositiveAmountInput.Issue) {
        var draft = BudgetPlanDraft.saved([rentLine, groceriesLine])

        draft.setAmountText(text, for: 1)

        #expect(draft.issue(for: 1) == issue)
        #expect(draft.firstInvalidCategoryID == 1)
        #expect(draft.payload == nil)
    }

    @Test func changingAndRestoringAnAmountIsNotAChange() {
        var draft = BudgetPlanDraft.saved([rentLine])

        draft.setAmountText("1300", for: 7)
        #expect(draft.isDirty)

        draft.setAmountText("1 200,00", for: 7)
        #expect(!draft.isDirty)
    }

    @Test func savedAmountsBecomeTheNewBaseline() {
        var draft = BudgetPlanDraft.saved([rentLine])
        draft.setAmountText("1300", for: 7)

        draft.markSaved([7: 1300])

        #expect(!draft.isDirty)
        #expect(!draft.deletesSavedPlan)
    }
}
