import Foundation

/// A goal to create; its account is created with it (`GOAL-20`, `GOAL-21`).
nonisolated struct NewSavingsGoal: Equatable, Sendable {
    let name: String
    let currencyID: Int64
    let targetAmount: Decimal
    /// A calendar day in the device's time zone.
    let targetDate: Date
}

/// What editing a goal may change: the currency stays (`GOAL-20`).
nonisolated struct SavingsGoalUpdate: Equatable, Sendable {
    let name: String
    let targetAmount: Decimal
    /// A calendar day in the device's time zone.
    let targetDate: Date
}

/// Parameters of `create_savings_goal`.
nonisolated struct NewSavingsGoalDto: Encodable, Sendable {
    let name: String
    let currencyID: Int64
    let targetAmount: Decimal
    /// `YYYY-MM-DD`.
    let targetDate: String

    enum CodingKeys: String, CodingKey {
        case name = "p_name"
        case currencyID = "p_currency_id"
        case targetAmount = "p_target_amount"
        case targetDate = "p_target_date"
    }
}

/// Parameters of `update_savings_goal`.
nonisolated struct SavingsGoalUpdateDto: Encodable, Sendable {
    let accountID: Int64
    let name: String
    let targetAmount: Decimal
    /// `YYYY-MM-DD`.
    let targetDate: String

    enum CodingKeys: String, CodingKey {
        case accountID = "p_account_id"
        case name = "p_name"
        case targetAmount = "p_target_amount"
        case targetDate = "p_target_date"
    }
}
