import Foundation
import Observation

/// "Mark as done" (`GOAL-23`), or "Mark as cancelled" with money saved (`GOAL-24`): moves everything saved to a
/// regular account in the goal's currency, then marks the goal.
///
/// Like the web, these are two requests, not one transaction. If the second fails, "Try again" repeats only it:
/// moving the money again would fail, and after the first step the goal no longer qualifies as reached. See
/// `ios/docs/TECH_DEBT.md`.
@Observable
final class GoalClosingViewModel: Identifiable {
    enum Kind: Equatable, Sendable {
        case complete, cancel
    }

    enum AccountIssue: Equatable {
        case required
    }

    let kind: Kind
    let goal: SavingsGoal
    /// The account picked here; see `account`.
    var selectedAccount: Account?
    /// The server's explanation of a failed step (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// The money has been moved; only marking the goal is left.
    private(set) var hasMovedMoney = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let referenceData: ReferenceDataStore
    private let repository: any GoalsRepository
    private let transfers: any TransfersRepository
    private let clock: () -> Date
    private let onChanged: () async -> Void

    init(
        kind: Kind,
        goal: SavingsGoal,
        referenceData: ReferenceDataStore,
        repository: any GoalsRepository,
        transfers: any TransfersRepository,
        clock: @escaping () -> Date = { .now },
        onChanged: @escaping () async -> Void
    ) {
        self.kind = kind
        self.goal = goal
        self.referenceData = referenceData
        self.repository = repository
        self.transfers = transfers
        self.clock = clock
        self.onChanged = onChanged
    }

    var id: Kind { kind }

    /// Everything saved goes back (`GOAL-23`, `GOAL-24`).
    var amount: Decimal {
        goal.accumulatedAmount
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

    /// No account in the goal's currency: the sheet explains it and offers to create one (`Q-04`).
    var needsAccount: Bool {
        accounts.isEmpty && !hasMovedMoney
    }

    var accountIssue: AccountIssue? {
        showsValidation && !hasMovedMoney && account == nil ? .required : nil
    }

    /// Moves the money, unless already moved, then marks the goal; `true` on success. Ignored while a request is
    /// running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard !isSubmitting, accountIssue == nil else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        if !hasMovedMoney, amount > 0 {
            guard let account else { return false }
            let now = clock()
            let transfer = NewTransfer(
                fromAccountID: goal.id,
                toAccountID: account.id,
                fromAmount: amount,
                toAmount: nil,
                transactedAt: now,
                localOffset: LocalOffset.current(at: now)
            )
            do {
                try await transfers.make(transfer)
            } catch {
                failure = error.localizedDescription
                return false
            }
            hasMovedMoney = true
        }

        do {
            switch kind {
            case .complete: try await repository.markDone(id: goal.id)
            case .cancel: try await repository.cancel(id: goal.id)
            }
        } catch {
            failure = error.localizedDescription
            // The money has moved: the balances elsewhere should show it.
            await onChanged()
            return false
        }
        await onChanged()
        return true
    }
}
