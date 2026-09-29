import Foundation
import Testing
@testable import Finwaze

@MainActor
struct GroupsViewModelTests {
    private let repository = FakeGroupsRepository()

    private let food = GroupWithCategories(
        id: 1, name: "Food", transactionType: .expense, color: "#22C55E",
        categories: [
            .init(id: 10, name: "Groceries", color: nil, transactionsCount: 3),
            .init(id: 11, name: "Snacks", color: nil, transactionsCount: 0),
        ]
    )
    private let salary = GroupWithCategories(id: 2, name: "Salary", transactionType: .income, color: nil, categories: [])

    private final class Calls {
        var groups: [(String, TransactionType, String?)] = []
        var categories: [(String, Int64, String?)] = []
        var changes = 0
    }

    private func makeViewModel(calls: Calls = Calls(), createFails: Bool = false) -> GroupsViewModel {
        GroupsViewModel(
            repository: repository,
            createGroup: { name, type, color in
                if createFails { throw FakeCreateError() }
                calls.groups.append((name, type, color))
            },
            createCategory: { name, groupID, color in calls.categories.append((name, groupID, color)) },
            onChanged: { calls.changes += 1 }
        )
    }

    // MARK: Load and filter (CAT-01, CAT-12)

    @Test func loadsGroups() async {
        repository.setGroups([food, salary])
        let viewModel = makeViewModel()

        await viewModel.refresh()

        #expect(viewModel.state == .loaded([food, salary]))
        #expect(viewModel.visibleGroups == [food, salary])
        #expect(!viewModel.hasNoGroups)
    }

    @Test func failedWhenLoadingErrors() async {
        repository.setLoadFails(true)
        let viewModel = makeViewModel()

        await viewModel.refresh()

        #expect(viewModel.state == .failed)
    }

    @Test func filtersByType() async {
        repository.setGroups([food, salary])
        let viewModel = makeViewModel()
        await viewModel.refresh()

        viewModel.typeFilter = .income
        #expect(viewModel.visibleGroups == [salary])
        #expect(viewModel.newGroupType == .income)

        viewModel.typeFilter = nil
        #expect(viewModel.newGroupType == .expense)
    }

    /// No group at all is the empty state; a filter that hides every group is not.
    @Test func emptyStateOnlyWithoutAnyGroup() async {
        let viewModel = makeViewModel()
        await viewModel.refresh()
        #expect(viewModel.hasNoGroups)

        repository.setGroups([food])
        await viewModel.refresh()
        viewModel.typeFilter = .income

        #expect(viewModel.visibleGroups.isEmpty)
        #expect(!viewModel.hasNoGroups)
    }

    // MARK: Rules (CAT-06, CAT-09)

    @Test func onlyEmptyGroupsAndUnusedCategoriesCanBeDeleted() {
        #expect(!food.canDelete)
        #expect(salary.canDelete)
        #expect(!food.categories[0].canDelete)
        #expect(food.categories[1].canDelete)
    }

    // MARK: Create, edit (CAT-04, CAT-05, CAT-07, CAT-08, CAT-10)

    @Test func createsAGroupAndACategory() async throws {
        let calls = Calls()
        let viewModel = makeViewModel(calls: calls)

        try await viewModel.createGroup(name: "Travel", type: .expense, color: "#3B82F6")
        #expect(viewModel.banner == "groups.groupCreated")
        try await viewModel.createCategory(name: "Hotels", groupID: 1, color: nil)
        #expect(viewModel.banner == "groups.categoryCreated")

        #expect(calls.groups.map(\.0) == ["Travel"])
        #expect(calls.categories.map(\.1) == [1])
    }

    @Test func creationFailureIsThrownToTheDialog() async {
        let viewModel = makeViewModel(createFails: true)

        await #expect(throws: FakeCreateError.self) {
            try await viewModel.createGroup(name: "Travel", type: .expense, color: nil)
        }
        #expect(viewModel.banner == nil)
    }

    @Test func updatesNameAndColorTogetherAndNotifies() async throws {
        let calls = Calls()
        let viewModel = makeViewModel(calls: calls)

        try await viewModel.updateGroup(id: 1, name: "Meals", color: nil)
        try await viewModel.updateCategory(id: 10, name: "Market", color: "#EF4444")

        #expect(repository.updatedGroups == [.init(id: 1, name: "Meals", color: nil)])
        #expect(repository.updatedCategories == [.init(id: 10, name: "Market", color: "#EF4444")])
        #expect(viewModel.banner == "groups.categoryUpdated")
        #expect(calls.changes == 2)
    }

    @Test func updatingSomethingDeletedElsewhereThrowsNotFound() async {
        repository.setMissing(10)
        let calls = Calls()
        let viewModel = makeViewModel(calls: calls)

        await #expect(throws: GroupsViewModel.NotFoundError.self) {
            try await viewModel.updateCategory(id: 10, name: "Market", color: nil)
        }
        // The list reloads, so the gone category disappears.
        #expect(calls.changes == 1)
        #expect(viewModel.banner == nil)
    }

    // MARK: Delete (CAT-06, CAT-09, CAT-11)

    @Test func deletesAnEmptyGroupAndAnUnusedCategory() async {
        let calls = Calls()
        let viewModel = makeViewModel(calls: calls)

        #expect(await viewModel.delete(salary))
        #expect(viewModel.banner == "groups.groupDeleted")
        #expect(await viewModel.delete(food.categories[1]))
        #expect(viewModel.banner == "groups.categoryDeleted")

        #expect(repository.deletedGroupIDs == [2])
        #expect(repository.deletedCategoryIDs == [11])
        #expect(calls.changes == 2)
    }

    @Test func refusesToDeleteWhatIsInUse() async {
        let viewModel = makeViewModel()

        #expect(await viewModel.delete(food) == false)
        #expect(await viewModel.delete(food.categories[0]) == false)

        #expect(repository.deletedGroupIDs.isEmpty)
        #expect(repository.deletedCategoryIDs.isEmpty)
    }

    /// E.g. a category with a planned budget: the server refuses and the screen explains why (`GEN-19`).
    @Test func deletionFailureShowsTheServersExplanation() async {
        repository.setWriteFails(true)
        let calls = Calls()
        let viewModel = makeViewModel(calls: calls)

        #expect(await viewModel.delete(food.categories[1]) == false)

        #expect(viewModel.failure == .init(title: "groups.categoryDeletionFailed", message: "duplicate key value"))
        #expect(viewModel.banner == nil)
        #expect(calls.changes == 0)
        #expect(!viewModel.isDeleting)
    }
}
