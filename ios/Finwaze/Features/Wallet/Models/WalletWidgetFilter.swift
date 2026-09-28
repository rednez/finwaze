import Foundation
import Observation

/// One Wallet widget's filters (`ACC-06`): independent of the other widgets and kept by the tab for the whole session,
/// so switching tabs keeps them; signing out starts a new one.
@Observable
final class WalletWidgetFilter {
    /// The calendar month shown, the current one at first (`GEN-14`).
    private(set) var month: YearMonth
    /// The currency picked here. `nil` until the user picks one, so the widget follows the primary currency until
    /// then; from then on a new primary currency does not change it (`DASH-01`).
    private(set) var pickedCurrencyCode: String?

    init(now: Date = .now, calendar: Calendar = .current) {
        month = YearMonth(now, in: calendar)
    }

    /// Moves the month by `months` (negative for earlier).
    func shiftMonth(by months: Int) {
        month = month.adding(months: months)
    }

    func selectCurrency(_ code: String) {
        pickedCurrencyCode = code
    }

    /// The currency shown: the one picked here, else the primary currency, else the first of `codes`. One no account
    /// has any more falls back the same way (`GEN-11`).
    func currencyCode(among codes: [String], primary: String?) -> String? {
        CurrencySelection.currencyCode(picked: pickedCurrencyCode, among: codes, primary: primary)
    }
}
