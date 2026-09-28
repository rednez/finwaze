import Foundation
import Testing
@testable import Finwaze

/// The plan editor (`BUD-20…26`).
@MainActor
struct BudgetPlanViewModelTests {
    private let repository = FakeBudgetRepository()
    private let september = YearMonth(year: 2026, month: 9)

    private static let food = CategoryGroup(id: 1, name: "Food", transactionType: .expense, color: nil)
    private static let housing = CategoryGroup(id: 4, name: "Housing", transactionType: .expense, color: nil)
    private static let groceries = Finwaze.Category(id: 1, name: "Groceries", groupID: 1, color: nil)
    private static let restaurants = Finwaze.Category(id: 2, name: "Restaurants", groupID: 1, color: nil)
    private static let rent = Finwaze.Category(id: 7, name: "Rent", groupID: 4, color: nil)

    private let rentLine = BudgetPlanLine(
        categoryID: 7, categoryName: "Rent", groupID: 4, groupName: "Housing", planned: 1200,
        stats: BudgetPlanStats(previousPlanned: 1200, spent: 1200, previousSpent: 1100)
    )
    private let groceriesLine = BudgetPlanLine(
        categoryID: 1, categoryName: "Groceries", groupID: 1, groupName: "Food", planned: 250,
        stats: BudgetPlanStats(previousPlanned: 250, spent: 150, previousSpent: 205)
    )

    private final class SaveCounter {
        var count = 0
    }

    private let savedCounter = SaveCounter()

    private func makeViewModel(plan: [BudgetPlanLine] = []) async throws -> BudgetPlanViewModel {
        repository.setPlan(plan)
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository(
            groups: [Self.food, Self.housing],
            categories: [Self.groceries, Self.restaurants, Self.rent]
        ))
        let counter = savedCounter
        return BudgetPlanViewModel(
            month: september,
            currencyCode: "USD",
            repository: repository,
            referenceData: referenceData,
            onSaved: { counter.count += 1 }
        )
    }

    // MARK: Opening (BUD-20, BUD-21)

    @Test func savedPlanOpensTheEditor() async throws {
        let viewModel = try await makeViewModel(plan: [rentLine, groceriesLine])

        await viewModel.load()

        #expect(viewModel.state == .editing)
        #expect(viewModel.draft.sections.map(\.id) == [4, 1])
        #expect(!viewModel.canSave)
    }

    @Test func noPlanShowsTheEmptyState() async throws {
        let viewModel = try await makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .empty)
    }

    @Test func loadFailureCanBeRetried() async throws {
        let viewModel = try await makeViewModel(plan: [rentLine])
        repository.setFails(.plan)

        await viewModel.load()
        #expect(viewModel.state == .failed)

        repository.setFails(.plan, false)
        await viewModel.load()
        #expect(viewModel.state == .editing)
    }

    @Test func generatedPlanIsAnUnsavedDraft() async throws {
        let viewModel = try await makeViewModel()
        repository.setGeneratedPlan([rentLine, groceriesLine])
        await viewModel.load()

        await viewModel.generate()

        #expect(viewModel.state == .editing)
        #expect(viewModel.draft.payload == [7: 1200, 1: 250])
        #expect(viewModel.canSave)
        #expect(viewModel.hasUnsavedChanges)
        #expect(repository.savedPlans.isEmpty)
    }

    @Test func nothingToGenerateStaysEmpty() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load()

        await viewModel.generate()

        #expect(viewModel.state == .empty)
        #expect(viewModel.showsNothingToGenerate)
    }

    @Test func manualStartIsEmptyAndUnchanged() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load()

        viewModel.startManually()

        #expect(viewModel.state == .editing)
        #expect(viewModel.draft.isEmpty)
        #expect(!viewModel.canSave)
        #expect(viewModel.availableGroups == [Self.food, Self.housing])
    }

    // MARK: Adding (BUD-23, BUD-24)

    @Test func addedCategoryGetsItsFigures() async throws {
        let viewModel = try await makeViewModel(plan: [groceriesLine])
        let stats = BudgetPlanStats(previousPlanned: 0, spent: 45, previousSpent: 85)
        repository.setStats(stats, for: 2)
        await viewModel.load()
        #expect(viewModel.availableCategories(inGroup: 1) == [Self.restaurants])

        await viewModel.addCategory(Self.restaurants)

        #expect(viewModel.draft.line(2)?.stats == stats)
        #expect(viewModel.availableCategories(inGroup: 1).isEmpty)
    }

    @Test func failedFiguresStayUnknown() async throws {
        let viewModel = try await makeViewModel(plan: [groceriesLine])
        repository.setFails(.stats)
        await viewModel.load()

        await viewModel.addCategory(Self.restaurants)

        #expect(viewModel.draft.line(2) != nil)
        #expect(viewModel.draft.line(2)?.stats == nil)
    }

    @Test func namesFollowTheReferenceData() async throws {
        let renamed = BudgetPlanLine(
            categoryID: 7, categoryName: "Old rent", groupID: 4, groupName: "Old housing", planned: 1200,
            stats: .zero
        )
        let viewModel = try await makeViewModel(plan: [renamed])
        await viewModel.load()

        let section = try #require(viewModel.draft.sections.first)
        #expect(viewModel.name(ofGroup: section) == "Housing")
        #expect(viewModel.name(ofCategory: try #require(section.lines.first)) == "Rent")
    }

    // MARK: Saving (BUD-25, BUD-26)

    @Test(arguments: ["", "0", "12.345"])
    func invalidAmountBlocksSaving(text: String) async throws {
        let viewModel = try await makeViewModel(plan: [rentLine, groceriesLine])
        await viewModel.load()
        viewModel.setAmountText(text, for: 1)
        #expect(viewModel.issue(for: 1) == nil)

        let outcome = await viewModel.save()

        #expect(outcome == .invalid(firstCategoryID: 1))
        #expect(viewModel.issue(for: 1) != nil)
        #expect(repository.savedPlans.isEmpty)
    }

    @Test func changingAndRestoringIsNotAChange() async throws {
        let viewModel = try await makeViewModel(plan: [rentLine])
        await viewModel.load()

        viewModel.setAmountText("1300", for: 7)
        #expect(viewModel.canSave)
        viewModel.setAmountText("1200", for: 7)
        #expect(!viewModel.canSave)
    }

    @Test func savingSendsTheWholePlan() async throws {
        let viewModel = try await makeViewModel(plan: [rentLine, groceriesLine])
        await viewModel.load()
        viewModel.setAmountText("300", for: 1)
        viewModel.removeCategory(id: 7)

        let outcome = await viewModel.save()

        #expect(outcome == .saved)
        #expect(repository.savedPlans == [[1: 300]])
        #expect(!viewModel.canSave)
        #expect(viewModel.didSave)
        #expect(savedCounter.count == 1)
        // The editor stays open with the saved plan.
        #expect(viewModel.state == .editing)
    }

    @Test func emptyingASavedPlanAsksFirst() async throws {
        let viewModel = try await makeViewModel(plan: [rentLine])
        await viewModel.load()
        viewModel.removeGroup(id: 4)

        #expect(await viewModel.save() == .needsConfirmation)
        #expect(repository.savedPlans.isEmpty)

        #expect(await viewModel.save(confirmed: true) == .saved)
        #expect(repository.savedPlans == [[:]])
    }

    @Test func failedSaveKeepsTheDraft() async throws {
        let viewModel = try await makeViewModel(plan: [rentLine])
        repository.setFails(.save)
        await viewModel.load()
        viewModel.setAmountText("1300", for: 7)

        let outcome = await viewModel.save()

        #expect(outcome == .notSaved)
        #expect(viewModel.saveFailure == "duplicate key value")
        #expect(viewModel.draft.line(7)?.amountText == "1300")
        #expect(viewModel.canSave)
        #expect(savedCounter.count == 0)
    }

    // MARK: Collapsing

    @Test func collapseAndExpandAll() async throws {
        let viewModel = try await makeViewModel(plan: [rentLine, groceriesLine])
        await viewModel.load()

        viewModel.collapseAll()
        #expect(viewModel.collapsedGroupIDs == [4, 1])

        viewModel.toggleGroup(4)
        #expect(viewModel.collapsedGroupIDs == [1])

        viewModel.expandAll()
        #expect(viewModel.collapsedGroupIDs.isEmpty)
    }
}
