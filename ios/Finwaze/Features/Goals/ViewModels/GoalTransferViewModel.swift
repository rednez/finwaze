import Foundation
import Observation

/// "Deposit" into a goal or "Withdraw" from it (`GOAL-13`, `GOAL-14`): a transfer between the goal's account and a
/// regular account in the goal's currency (`GOAL-03`).
@Observable
final class GoalTransferViewModel {
    enum Direction: Equatable, Sendable {
        case deposit, withdraw
    }

    enum AccountIssue: Equatable {
        case required
    }

    enum AmountIssue: Equatable {
        case input(PositiveAmountInput.Issue)
        /// A withdrawal cannot take more than the goal has (`GOAL-14`).
        case exceedsSaved
    }

    enum DateIssue: Equatable {
        /// A transfer cannot be dated in the future (`GEN-13`).
        case inFuture
    }

    let goal: SavingsGoal
    let direction: Direction
    /// The account picked here; see `account`.
    var selectedAccount: Account?
    var amountText = ""
    /// "Now" by default; never later than now (`GEN-13`).
    var transactedAt: Date
    /// The server's explanation of a failed transfer; the entered data stays in the form (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let referenceData: ReferenceDataStore
    private let repository: any TransfersRepository
    private let clock: () -> Date
    /// Runs after the transfer is made, while the button still shows its spinner.
    private let onSaved: () async -> Void

    init(
        goal: SavingsGoal,
        direction: Direction,
        referenceData: ReferenceDataStore,
        repository: any TransfersRepository,
        clock: @escaping () -> Date = { .now },
        onSaved: @escaping () async -> Void
    ) {
        self.goal = goal
        self.direction = direction
        self.referenceData = referenceData
        self.repository = repository
        self.clock = clock
        self.onSaved = onSaved
        transactedAt = clock()
    }

    /// Regular accounts in the goal's currency (`GOAL-03`).
    var accounts: [Account] {
        referenceData.accounts.filter { $0.currencyCode == goal.currencyCode }
    }

    /// The account picked here, or the only one there is.
    var account: Account? {
        if let selectedAccount, accounts.contains(selectedAccount) { return selectedAccount }
        return accounts.count == 1 ? accounts.first : nil
    }

    /// No account in the goal's currency: the form explains it and offers to create one (`Q-04`).
    var needsAccount: Bool {
        accounts.isEmpty
    }

    /// The latest moment the date field accepts (`GEN-13`).
    var latestDate: Date {
        clock()
    }

    // MARK: Validation (GEN-21)

    var accountIssue: AccountIssue? {
        showsValidation && account == nil ? .required : nil
    }

    var amountIssue: AmountIssue? {
        guard showsValidation else { return nil }
        switch PositiveAmountInput.parse(amountText) {
        case .failure(let issue):
            return .input(issue)
        case .success(let amount):
            return direction == .withdraw && amount > goal.accumulatedAmount ? .exceedsSaved : nil
        }
    }

    var dateIssue: DateIssue? {
        showsValidation && transactedAt > clock() ? .inFuture : nil
    }

    // MARK: Submit

    /// Makes the transfer; `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard
            !isSubmitting,
            accountIssue == nil, amountIssue == nil, dateIssue == nil,
            let account,
            let amount = try? PositiveAmountInput.parse(amountText).get()
        else { return false }

        let transfer = NewTransfer(
            fromAccountID: direction == .deposit ? account.id : goal.id,
            toAccountID: direction == .deposit ? goal.id : account.id,
            fromAmount: amount,
            // The same currency on both sides: the server moves exactly this amount (`GOAL-03`).
            toAmount: nil,
            transactedAt: transactedAt,
            localOffset: LocalOffset.current(at: transactedAt)
        )

        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await repository.make(transfer)
        } catch {
            failure = error.localizedDescription
            return false
        }
        await onSaved()
        return true
    }
}
