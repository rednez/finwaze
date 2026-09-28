import Foundation
import Observation

/// "Daily cash flow" (`ACC-03`): incomes and expenses for every day of the month in a purchase currency.
@Observable
final class DailyCashFlowViewModel {
    let widget: WalletWidgetViewModel<[DailyCashFlow]>
    /// "Incomes on / off": off shows expenses only. Only hides the line, so nothing reloads.
    var includesIncome = true

    init(repository: any WalletRepository, referenceData: ReferenceDataStore, preferences: DevicePreferences) {
        widget = WalletWidgetViewModel(referenceData: referenceData, preferences: preferences) { key in
            try await repository.dailyCashFlow(month: key.month, currencyCode: key.currencyCode)
        }
    }

    /// Whether the chart has nothing to draw: no expense on any day, nor an income while incomes are shown.
    func isEmpty(_ days: [DailyCashFlow]) -> Bool {
        days.allSatisfy { $0.expense == 0 && (!includesIncome || $0.income == 0) }
    }
}
