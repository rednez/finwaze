import Foundation
import Observation

/// The Budget's filters (`BUD-11`), shared by the month's screen and a group's (`BUD-17`). Kept by the tab for the
/// whole session, so switching tabs keeps them; signing out starts a new one.
@Observable
final class BudgetFilter {
    /// The calendar month shown, the current one at first (`GEN-14`).
    private(set) var month: YearMonth
    /// The currency picked here. `nil` until the Budget first loads, which fixes the primary currency here; from then
    /// on a new primary currency does not change it (`DASH-01`).
    var currencyCode: String?
    /// `nil` for every status.
    var status: BudgetStatus?
    /// Empty for every group.
    var groupIDs: Set<Int64> = []

    init(now: Date = .now, calendar: Calendar = .current) {
        month = YearMonth(now, in: calendar)
    }

    /// Moves the month by `months` (negative for earlier).
    func shiftMonth(by months: Int) {
        month = month.adding(months: months)
    }

    /// Whether the status or group filter hides any group card.
    var narrowsGroups: Bool {
        status != nil || !groupIDs.isEmpty
    }

    /// Back to every status and every group; the month and currency stay.
    func clearGroupFilters() {
        status = nil
        groupIDs = []
    }

    /// Whether `item` passes the status and group filters.
    func matches(_ item: BudgetItem) -> Bool {
        (status == nil || item.status == status) && (groupIDs.isEmpty || groupIDs.contains(item.id))
    }
}
