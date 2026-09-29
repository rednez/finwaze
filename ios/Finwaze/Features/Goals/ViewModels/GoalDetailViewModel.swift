import Foundation
import Observation

/// A goal's screen (`GOAL-20…26`): loads the goal fresh from the server, edits it and offers "Mark as done",
/// "Mark as cancelled" and "Delete goal" when they apply.
@Observable
final class GoalDetailViewModel {
    let goalID: Int64
    private(set) var state: DetailState<SavingsGoal> = .loading
    /// The goal's fields, filled from the latest copy.
    private(set) var form: GoalFormViewModel?
    /// "Goal updated", shown after a save.
    var showsUpdatedBanner = false
    var cancellationFailure: String?
    var deletionFailure: String?
    private(set) var isCancelling = false
    private(set) var isDeleting = false

    private let referenceData: ReferenceDataStore
    private let repository: any GoalsRepository
    private let transfers: any TransfersRepository
    private let clock: () -> Date
    /// Runs after anything changed, so the other screens follow (`GEN-26`).
    private let onChanged: () async -> Void

    init(
        goalID: Int64,
        referenceData: ReferenceDataStore,
        repository: any GoalsRepository,
        transfers: any TransfersRepository,
        clock: @escaping () -> Date = { .now },
        onChanged: @escaping () async -> Void
    ) {
        self.goalID = goalID
        self.referenceData = referenceData
        self.repository = repository
        self.transfers = transfers
        self.clock = clock
        self.onChanged = onChanged
    }

    var goal: SavingsGoal? {
        state.value
    }

    /// Whether any of the goal's actions applies (`GOAL-23…25`).
    var hasActions: Bool {
        guard let goal else { return false }
        return goal.canMarkDone || goal.canCancel || goal.canDelete
    }

    var isBusy: Bool {
        isCancelling || isDeleting || form?.isSubmitting == true
    }

    // MARK: Load

    /// Loads (or reloads) the goal and fills the form with it.
    func load() async {
        state = .loading
        await reload()
    }

    private func reload() async {
        do {
            guard let goal = try await repository.goal(id: goalID) else {
                state = .notFound
                form = nil
                return
            }
            form = GoalFormViewModel(
                mode: .edit(goal),
                referenceData: referenceData,
                repository: repository,
                clock: clock,
                onSaved: { [weak self] in await self?.saved() }
            )
            state = .loaded(goal)
        } catch {
            state = .failed
        }
    }

    private func saved() async {
        await onChanged()
        await reload()
        showsUpdatedBanner = true
    }

    // MARK: Actions (GOAL-23…25)

    /// "Mark as done", or "Mark as cancelled" with money to move: the sheet that picks the account (`GOAL-23`,
    /// `GOAL-24`).
    func closing(_ kind: GoalClosingViewModel.Kind) -> GoalClosingViewModel? {
        guard let goal else { return nil }
        return GoalClosingViewModel(
            kind: kind,
            goal: goal,
            referenceData: referenceData,
            repository: repository,
            transfers: transfers,
            clock: clock,
            onChanged: onChanged
        )
    }

    /// Whether cancelling moves money back first, and so needs the account sheet rather than a confirmation
    /// (`GOAL-24`).
    var cancellationReturnsMoney: Bool {
        (goal?.accumulatedAmount ?? 0) > 0
    }

    /// Cancels a goal with nothing saved, after the confirmation (`GOAL-24`); `true` on success.
    @discardableResult
    func cancelWithoutTransfer() async -> Bool {
        guard let goal, goal.canCancel, !cancellationReturnsMoney, !isCancelling else { return false }
        isCancelling = true
        defer { isCancelling = false }
        do {
            try await repository.cancel(id: goal.id)
        } catch {
            cancellationFailure = error.localizedDescription
            return false
        }
        await onChanged()
        return true
    }

    /// Deletes a goal that never had money moved, after the confirmation (`GOAL-25`); `true` on success.
    @discardableResult
    func delete() async -> Bool {
        guard let goal, goal.canDelete, !isDeleting else { return false }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await repository.delete(id: goal.id)
        } catch {
            deletionFailure = error.localizedDescription
            return false
        }
        await onChanged()
        return true
    }
}
