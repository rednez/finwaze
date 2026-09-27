import Foundation
import Observation

/// "Groups & categories" (`CAT-01…12`): the user's groups with their categories, the type filter, and creating,
/// editing and deleting both. Every change reloads what other screens show (`GEN-26`).
@Observable
final class GroupsViewModel {
    enum State: Equatable {
        case loading
        case loaded([GroupWithCategories])
        case failed
    }

    /// A failed deletion: which action failed and the server's explanation (`CAT-11`, `GEN-19`). Creating and
    /// editing report failures inside their own dialog, which keeps the entered name.
    struct Failure: Equatable {
        let title: LocalizedStringResource
        let message: String
    }

    /// The group or category was deleted elsewhere while the dialog was open.
    struct NotFoundError: LocalizedError {
        var errorDescription: String? {
            String(localized: "groups.notFound")
        }
    }

    private(set) var state: State = .loading
    /// `nil` shows all groups (`CAT-01`).
    var typeFilter: TransactionType?
    /// A short success message; the screen shows it as a banner that clears this itself (`CAT-11`).
    var banner: LocalizedStringResource?
    var failure: Failure?
    private(set) var isDeleting = false

    private let repository: any GroupsRepository
    private let createGroupAction: (_ name: String, _ type: TransactionType, _ color: String?) async throws -> Void
    private let createCategoryAction: (_ name: String, _ groupID: Int64, _ color: String?) async throws -> Void
    private let onChanged: () async -> Void

    init(
        repository: any GroupsRepository,
        createGroup: @escaping (_ name: String, _ type: TransactionType, _ color: String?) async throws -> Void,
        createCategory: @escaping (_ name: String, _ groupID: Int64, _ color: String?) async throws -> Void,
        onChanged: @escaping () async -> Void
    ) {
        self.repository = repository
        createGroupAction = createGroup
        createCategoryAction = createCategory
        self.onChanged = onChanged
    }

    /// Groups of the filtered type, or all of them.
    var visibleGroups: [GroupWithCategories] {
        guard case .loaded(let groups) = state else { return [] }
        guard let typeFilter else { return groups }
        return groups.filter { $0.transactionType == typeFilter }
    }

    /// No group at all, whatever the filter — the empty state (`CAT-12`). A filter that hides every group shows an
    /// empty list with the filter instead.
    var hasNoGroups: Bool {
        state == .loaded([])
    }

    /// The type a new group starts with: the filtered one, or an expense.
    var newGroupType: TransactionType {
        typeFilter ?? .expense
    }

    /// Loads the groups. A reload keeps the list on screen until the new one arrives (`GEN-26`).
    func load() async {
        if case .failed = state {
            state = .loading
        }
        do {
            state = .loaded(try await repository.groups())
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed
        }
    }

    // MARK: Create (CAT-04, CAT-07)

    /// Throws so the dialog keeps the name and shows the server's explanation (`GEN-19`).
    func createGroup(name: String, type: TransactionType, color: String?) async throws {
        try await createGroupAction(name, type, color)
        banner = "groups.groupCreated"
    }

    func createCategory(name: String, groupID: Int64, color: String?) async throws {
        try await createCategoryAction(name, groupID, color)
        banner = "groups.categoryCreated"
    }

    // MARK: Edit (CAT-05, CAT-08, CAT-10)

    func updateGroup(id: Int64, name: String, color: String?) async throws {
        guard try await repository.updateGroup(id: id, name: name, color: color) else {
            await onChanged()
            throw NotFoundError()
        }
        banner = "groups.groupUpdated"
        await onChanged()
    }

    func updateCategory(id: Int64, name: String, color: String?) async throws {
        guard try await repository.updateCategory(id: id, name: name, color: color) else {
            await onChanged()
            throw NotFoundError()
        }
        banner = "groups.categoryUpdated"
        await onChanged()
    }

    // MARK: Delete (CAT-06, CAT-09)

    /// Deletes a group without categories; the screen confirms first (`GEN-22`).
    @discardableResult
    func delete(_ group: GroupWithCategories) async -> Bool {
        guard group.canDelete else { return false }
        return await performDeletion(success: "groups.groupDeleted", failure: "groups.groupDeletionFailed") {
            try await repository.deleteGroup(id: group.id)
        }
    }

    /// Deletes a category without transactions; the screen confirms first (`GEN-22`).
    @discardableResult
    func delete(_ category: GroupWithCategories.Item) async -> Bool {
        guard category.canDelete else { return false }
        return await performDeletion(success: "groups.categoryDeleted", failure: "groups.categoryDeletionFailed") {
            try await repository.deleteCategory(id: category.id)
        }
    }

    private func performDeletion(
        success: LocalizedStringResource,
        failure failureTitle: LocalizedStringResource,
        _ action: () async throws -> Void
    ) async -> Bool {
        guard !isDeleting else { return false }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await action()
        } catch {
            failure = Failure(title: failureTitle, message: error.localizedDescription)
            return false
        }
        banner = success
        await onChanged()
        return true
    }
}
