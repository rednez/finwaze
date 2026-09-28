import Foundation

/// A category of a month's plan as the server has it (`BUD-20…22`): its group, the planned amount and the reference
/// figures. The names are the server's, a fallback for when the reference data does not know the id.
nonisolated struct BudgetPlanLine: Identifiable, Equatable, Sendable {
    let categoryID: Int64
    let categoryName: String
    let groupID: Int64
    let groupName: String
    let planned: Decimal
    let stats: BudgetPlanStats

    var id: Int64 {
        categoryID
    }
}
