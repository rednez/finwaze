import Foundation

/// A goal's status (`GOAL-02`): the first two follow the saved amount, the last two are set by the user.
nonisolated enum SavingsGoalStatus: String, Decodable, CaseIterable, Sendable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case done
    case cancelled
}

/// A savings goal with its own account; saved = that account's balance (`GOAL-01`).
nonisolated struct SavingsGoal: Identifiable, Equatable, Sendable {
    /// The goal's account id.
    let id: Int64
    let name: String
    let currencyCode: String
    /// A calendar day, at midnight in the device's time zone.
    let targetDate: Date
    let status: SavingsGoalStatus
    let targetAmount: Decimal
    let accumulatedAmount: Decimal
    /// Whether money was ever paid in or taken out; only a goal without such transfers can be deleted (`GOAL-25`).
    let hasTransfers: Bool

    /// Saved share of the target, rounded down, like the web: 5 800 of 10 000 → 58. Not capped, so an exceeded
    /// target shows over 100 %.
    var progressPercent: Int {
        guard targetAmount > 0, accumulatedAmount > 0 else { return 0 }
        var ratio = accumulatedAmount / targetAmount * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &ratio, 0, .down)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    /// The progress bar's fill, from 0 to 1.
    var progressFraction: Double {
        min(Double(progressPercent), 100) / 100
    }

    /// "Not started" or "In progress": money can still go in and out, and the goal can be edited (`GOAL-04`).
    var isActive: Bool {
        status == .notStarted || status == .inProgress
    }

    /// "Deposit" on an active goal (`GOAL-12`).
    var canDeposit: Bool {
        isActive
    }

    /// "Withdraw" on an active goal with money in it (`GOAL-12`).
    var canWithdraw: Bool {
        isActive && accumulatedAmount > 0
    }

    /// "Mark as done" once the target is reached (`GOAL-23`).
    var canMarkDone: Bool {
        isActive && accumulatedAmount >= targetAmount
    }

    /// "Mark as cancelled" while the goal is active (`GOAL-24`).
    var canCancel: Bool {
        isActive
    }

    /// "Delete goal" only without any deposit or withdrawal ever (`GOAL-25`).
    var canDelete: Bool {
        !hasTransfers
    }

    /// "Left to reach the goal", never below zero (`GOAL-11`).
    var remainingAmount: Decimal {
        max(targetAmount - accumulatedAmount, 0)
    }
}
