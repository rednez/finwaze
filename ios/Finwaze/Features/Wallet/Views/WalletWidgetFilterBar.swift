import SwiftUI

/// A Wallet widget's own filters (`ACC-06`): "‹ September 2026 ›" and the currency, side by side, or one under the
/// other when they do not fit, e.g. at the largest text sizes.
struct WalletWidgetFilterBar<Value: Equatable & Sendable>: View {
    let widget: WalletWidgetViewModel<Value>
    let currencyCode: String
    /// "Recent transactions" has no month.
    var showsMonth = true

    var body: some View {
        if showsMonth {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    month
                    currency
                }
                VStack(alignment: .leading, spacing: 8) {
                    month
                    currency
                }
            }
        } else {
            currency
        }
    }

    private var month: some View {
        MonthStepper(month: widget.filter.month, font: .subheadline.weight(.semibold), onShift: widget.shiftMonth(by:))
    }

    private var currency: some View {
        CurrencyFilterMenu(
            title: "wallet.filter.currency",
            currencyCodes: widget.currencyCodes,
            selection: currencyCode,
            onSelect: widget.selectCurrency
        )
    }
}

extension View {
    /// Loads the widget when it appears, and again when its month, its currency or the data change (`ACC-06`,
    /// `GEN-26`).
    func loads<Value>(_ widget: WalletWidgetViewModel<Value>, dataVersion: Int) -> some View {
        task(for: widget.key, dataVersion: dataVersion) {
            await widget.load(dataVersion: dataVersion)
        }
    }
}
