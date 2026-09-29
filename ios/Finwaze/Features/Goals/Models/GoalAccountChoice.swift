import Foundation

/// The regular account a goal's money moves to or from (`GOAL-03`), shared by "Deposit", "Withdraw" and closing.
enum GoalAccountChoice {
    /// Regular accounts in the goal's currency (`GOAL-03`).
    static func accounts(for goal: SavingsGoal, in referenceData: ReferenceDataStore) -> [Account] {
        referenceData.accounts.filter { $0.currencyCode == goal.currencyCode }
    }

    /// The account picked, or the only one there is.
    static func account(selected: Account?, among accounts: [Account]) -> Account? {
        if let selected, accounts.contains(selected) { return selected }
        return accounts.count == 1 ? accounts.first : nil
    }
}
