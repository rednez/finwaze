import Foundation
import Observation

/// "Statistics" (`ACC-05`): the month's expenses or incomes in a purchase currency by group, as a ring.
@Observable
final class WalletStatisticsViewModel {
    enum Kind: CaseIterable {
        case expense, income
    }

    let widget: WalletWidgetViewModel<[GroupAmounts]>
    /// Expenses at first; switching only changes what the ring shows, so nothing reloads.
    var kind: Kind = .expense

    init(repository: any WalletRepository, referenceData: ReferenceDataStore, preferences: DevicePreferences) {
        widget = WalletWidgetViewModel(referenceData: referenceData, preferences: preferences) { key in
            try await repository.amountsByGroup(month: key.month, currencyCode: key.currencyCode)
        }
    }

    /// The groups with any amount of the kind, the six largest and "Other categories" beyond seven, with the total.
    func summary(of groups: [GroupAmounts]) -> SliceSummary {
        SliceSummary(groups.compactMap { group in
            let amount = kind == .expense ? group.expense : group.income
            return amount > 0 ? NamedAmount(name: group.name, amount: amount) : nil
        })
    }
}
