import Foundation
import Observation

/// Analytics' filters (`ANL-01`): the month, the currency and its accounts, and the year of "Budgets vs Expenses"
/// (`ANL-04`). Analytics is pushed onto a tab and gone after "Back", so the main app keeps the filters for the whole
/// session, like the web's root store; signing out starts a new one.
@Observable
final class AnalyticsFilter {
    /// The calendar month shown, the current one at first (`GEN-14`).
    private(set) var month: YearMonth
    /// The currency picked here. `nil` until the user picks one, so Analytics follows the primary currency until
    /// then; from then on a new primary currency does not change it (`DASH-01`).
    private(set) var pickedCurrencyCode: String?
    /// The accounts picked here; empty for all of them.
    private(set) var accountIDs: Set<Int64> = []
    /// The year of "Budgets vs Expenses", the current one at first.
    private(set) var budgetYear: Int

    init(now: Date = .now, calendar: Calendar = .current) {
        let current = YearMonth(now, in: calendar)
        month = current
        budgetYear = current.year
    }

    /// Moves the month by `months` (negative for earlier).
    func shiftMonth(by months: Int) {
        month = month.adding(months: months)
    }

    func shiftBudgetYear(by years: Int) {
        budgetYear += years
    }

    /// Another currency has other accounts, so the choice of accounts starts over, like the web.
    func selectCurrency(_ code: String) {
        guard code != pickedCurrencyCode else { return }
        pickedCurrencyCode = code
        accountIDs = []
    }

    func setAccount(_ id: Int64, isSelected: Bool) {
        if isSelected {
            accountIDs.insert(id)
        } else {
            accountIDs.remove(id)
        }
    }

    func selectAllAccounts() {
        accountIDs = []
    }

    /// The currency shown; see `CurrencySelection` (`GEN-11`).
    func currencyCode(among codes: [String], primary: String?) -> String? {
        CurrencySelection.currencyCode(picked: pickedCurrencyCode, among: codes, primary: primary)
    }

    /// The picked accounts that are still among `accounts` — the currency's regular accounts. One deleted or moved to
    /// another currency drops out; with none left it is all of them again.
    func selectedAccountIDs(among accounts: [Account]) -> Set<Int64> {
        accountIDs.intersection(accounts.map(\.id))
    }
}
